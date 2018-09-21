//
//  AMRecorder.m
//  FileShareDemo
//
//  Created by VVM-MAC02 on 1/21/16.
//  Copyright © 2016 vz. All rights reserved.
//

#import "AMRecorder.h"
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioModem.h"
#import "ADSharedMacros.h"
#import "AudioSessionManager.h"

static char strbuf[BIT_RATE] = {'\n'};

static float * barker;
static float * fBuffer;
static float * integral;
static float * corr;

typedef struct {
    __unsafe_unretained id mSelf;
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef mQueue;
    AudioQueueBufferRef mBuffers[kNumberBuffers];
    UInt32 bufferByteSize;
    SInt64 mCurrentPacket;
    bool mIsRunning;
} AQRecordState;


static float barkerbin_record[BARKER_LEN] = {
    +1.0f, +1.0f, +1.0f, +1.0f, +1.0f, -1.0f, -1.0f, +1.0f, +1.0f, -1.0f, +1.0f, -1.0f, +1.0f
};

static float bpf[SAMPLE_PER_BIT+1] = {
    +0.0055491, -0.0060955, +0.0066066, -0.0061506, +0.0033972, +0.0028618,
    -0.0130922, +0.0265188, -0.0409498, +0.0530505, -0.0590496, +0.0557252,
    -0.0414030, +0.0166718, +0.0154256, -0.0498328, +0.0804827, -0.1016295,
    +0.1091734, -0.1016295, +0.0804827, -0.0498328, +0.0154256, +0.0166718,
    -0.0414030, +0.0557252, -0.0590496, +0.0530505, -0.0409498, +0.0265188,
    -0.0130922, +0.0028618, +0.0033972, -0.0061506, +0.0066066, -0.0060955,
    +0.0055491
};

static float lpf[SAMPLE_PER_BIT+1] = {
    0.0025649, 0.0029793, 0.0039200, 0.0054457, 0.0075875, 0.0103454,
    0.0136865, 0.0175452, 0.0218251, 0.0264022, 0.0311308, 0.0358496,
    0.0403893, 0.0445807, 0.0482632, 0.0512926, 0.0535482, 0.0549392,
    0.0554092, 0.0549392, 0.0535482, 0.0512926, 0.0482632, 0.0445807,
    0.0403893, 0.0358496, 0.0311308, 0.0264022, 0.0218251, 0.0175452,
    0.0136865, 0.0103454, 0.0075875, 0.0054457, 0.0039200, 0.0029793,
    0.0025649
};

static const bool ParityTable256_record[256] =
{
#   define P2(n) n, n^1, n^1, n
#   define P4(n) P2(n), P2(n^1), P2(n^1), P2(n)
#   define P6(n) P4(n), P4(n^1), P4(n^1), P4(n)
    P6(0), P6(1), P6(1), P6(0)
};

@interface AMRecorder()

@property (nonatomic, assign) AQRecordState recordState; // sound record
@end

@implementation AMRecorder

// Initializer
- (AMRecorder *)initWithFormat
{
    self = [super init];
    if (self) {
        [self setupAudioFormat];
    }
    
    return self;
}

// setup audio format
- (void)setupAudioFormat
{
    [AudioSessionManager enablePlayingAndRecordMode:nil]; // change category to record, otherwise app will crash
    
    _recordState.mDataFormat.mFormatID = kAudioFormatLinearPCM;
    _recordState.mDataFormat.mSampleRate = 44100.0f;
    _recordState.mDataFormat.mBitsPerChannel = 16;
    _recordState.mDataFormat.mChannelsPerFrame = 1;
    _recordState.mDataFormat.mFramesPerPacket = 1;
    _recordState.mDataFormat.mBytesPerFrame = _recordState.mDataFormat.mBytesPerPacket = _recordState.mDataFormat.mChannelsPerFrame * sizeof(SInt16);
    _recordState.mDataFormat.mReserved = 0;
    _recordState.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsNonInterleaved | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked ;//| kLinearPCMFormatFlagIsBigEndian;
    _recordState.mSelf = self;
}

// C style init receiver method
void initReceiver(void)
{
    memset(strbuf, 0, BIT_RATE); // reset the string buffer
    long bufSize = SR;
    fBuffer = (float *)calloc(bufSize, sizeof(float));
    integral = (float *)calloc(bufSize/SAMPLE_PER_BIT, sizeof(float));
    corr = (float *)calloc(bufSize + BARKER_LEN*SAMPLE_PER_BIT, sizeof(float));
    barker = (float *)calloc(BARKER_LEN*SAMPLE_PER_BIT, sizeof(float));
    
    for (int i = 0; i < BARKER_LEN; i++) {
        vDSP_vfill(barkerbin_record+i, barker+i*SAMPLE_PER_BIT, 1, SAMPLE_PER_BIT);
    }
}

// derive the buffer size for recorder
- (void)_deriveBufferSize:(Float64)seconds {
    static const int maxBufferSize = 0x50000;
    
    int maxPacketSize = _recordState.mDataFormat.mBytesPerPacket;
    
    if (maxPacketSize == 0) {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty(_recordState.mQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize, &maxVBRPacketSize);
    }
    
    Float64 numBytesForTime = round(_recordState.mDataFormat.mSampleRate * maxPacketSize * seconds);
    _recordState.bufferByteSize = (UInt32) MIN(numBytesForTime, maxBufferSize);
}

// check if recording is running.
- (BOOL)isRunning
{
    return self.recordState.mIsRunning;
}

// stop recording...
- (void)stop
{
    AudioQueueStop(_recordState.mQueue, YES);
    _recordState.mIsRunning = NO;
}

// start recording...
- (void)startRecording
{
    _recordState.mCurrentPacket = 0;
    initReceiver();
    
    [self _deriveBufferSize:1.0f];
    
    OSStatus status = noErr;
    status = AudioQueueNewInput(&_recordState.mDataFormat,
                                HandleInputBuffer,
                                &_recordState,
                                NULL,
                                NULL,
                                0,
                                &_recordState.mQueue);
    
    ADAssert(noErr == status, @"Could not create queue.");
    
    for (int i = 0; i < kNumberBuffers; i++) {
        AudioQueueAllocateBuffer(_recordState.mQueue, _recordState.bufferByteSize, &_recordState.mBuffers[i]);
        AudioQueueEnqueueBuffer(_recordState.mQueue, _recordState.mBuffers[i], 0, NULL);
    }
    
    ADAssert(noErr == status, @"Could not allocate buffers.");
    
    _recordState.mIsRunning = YES;
    status = AudioQueueStart(_recordState.mQueue, NULL);
    
    ADAssert(noErr == status, @"Could not start recording.");
}

// recorder handler
void HandleInputBuffer(void * inUserData,
                       AudioQueueRef inAQ,
                       AudioQueueBufferRef inBuffer,
                       const AudioTimeStamp * inStartTime,
                       UInt32 inNumPackets,
                       const AudioStreamPacketDescription * inPacketDesc) {
    AQRecordState * pRecordState = (AQRecordState *)inUserData;
    
    if (inNumPackets == 0 && pRecordState->mDataFormat.mBytesPerPacket != 0) {
        inNumPackets = inBuffer->mAudioDataByteSize / pRecordState->mDataFormat.mBytesPerPacket;
    }
    
    if ( ! pRecordState->mIsRunning) {
        return;
    }
    
    long sampleStart = (long)pRecordState->mCurrentPacket;
    long sampleEnd = (long)(pRecordState->mCurrentPacket + inBuffer->mAudioDataByteSize / pRecordState->mDataFormat.mBytesPerPacket - 1);
    printf("buffer received : %1.6f from %1.6f (#%07ld) to %1.6f (#%07ld)\n", (sampleEnd - sampleStart + 1)/44100.0, sampleStart/44100.0, sampleStart, sampleEnd/44100.0, sampleEnd);
    
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    short * samples = (short *)inBuffer->mAudioData;
    long nsamples = sampleEnd - sampleStart + 1;
    //bool found = NO;
    
    // Convert to float
    for (long i = 0; i < nsamples; i++) {
        fBuffer[i] = samples[i] / (float)SHRT_MAX;
    }
    
    // BPF
    vDSP_desamp(fBuffer, 1, bpf, fBuffer, nsamples, SAMPLE_PER_BIT+1);
    
    // Carrier present ?
    float m = 1.0f, max = 0.0f, mean = 0.0f;
    vDSP_meamgv(fBuffer, 1, &mean, nsamples);
    printf("mean %1.9f\n", mean);
    
    bool shouldStop = false;
    if (mean > 10e-5) {
        
        max = mean;
        vDSP_maxmgv(fBuffer, 1, &max, nsamples);
        printf("max  %1.9f\n", max);
        printf("max/mean %1.9f\n", max/mean);
        
        // Delay Multiply
        vDSP_vmul(fBuffer, 1, fBuffer+SAMPLE_PER_BIT, 1, fBuffer, 1, nsamples-SAMPLE_PER_BIT);
        
        // LPF
        vDSP_desamp(fBuffer, 1, lpf, fBuffer, nsamples, SAMPLE_PER_BIT+1);
        
        // Time sync
        m = 1/max;
        vDSP_vsmul(barker, 1, &m, barker, 1, BARKER_LEN*SAMPLE_PER_BIT);
        
#define FILTERS_DELAY (BARKER_LEN+2)*SAMPLE_PER_BIT
        vDSP_conv(fBuffer, 1, barker, 1, corr, 1, nsamples-FILTERS_DELAY, BARKER_LEN*SAMPLE_PER_BIT);
        
#ifdef SHOW_CORR
        for (long i = 0; i < nsamples-FILTERS_DELAY; i++) {
            printf("%+1.8f\n", corr[i]);
        }
#endif
        
        float cc = -1.0f;
        unsigned long cci = 0;
        vDSP_vsmul(corr, 1, &cc, corr, 1, nsamples-FILTERS_DELAY);
        vDSP_maxv(corr, 1, &cc, nsamples-FILTERS_DELAY);
        cc *= CORR_MAX_COEFF;
        vDSP_vthrsc(corr, 1, &cc, &cc, corr, 1, nsamples-FILTERS_DELAY);
        vDSP_maxvi(corr, 1, &cc, &cci, nsamples-FILTERS_DELAY);
        printf("corr %1.9f\n", cc);
        printf("idx  %lu\n", cci);
        
        long j = -1;
        for (long i = 0; i < nsamples; i++) {
            if (corr[i] > 0) {
                if (j != i-1) {
                    printf("Found frame starting at index %ld\n", i);
                }
                j = i;
            }
        }
        
        // Integration
        for (long i = 0; i < nsamples/SAMPLE_PER_BIT; i++) {
            if(cci+i*SAMPLE_PER_BIT < nsamples) {
                vDSP_sve(fBuffer+cci+i*SAMPLE_PER_BIT, 1, integral+i, SAMPLE_PER_BIT);
            }
        }
        
        // Decision
#ifdef SHOW_FRAMES
        for (long i = 13; i < nsamples/SAMPLE_PER_BIT; i += 12) {
            if (integral[i]>0 || integral[i+10]>0 || integral[i+11]>0) {
                break;
            }
            printf("%d ", integral[i]>0);
            for (int j = i+1; j < i+9; j++) {
                printf("%d", integral[j]>0);
            }
            printf(" %d ", integral[i+9]>0);
            printf("%d", integral[i+10]>0);
            printf("%d", integral[i+11]>0);
            printf("\n");
        }
#endif
        
        int i = 13;
        char ch;
        short p;
        while (integral[i]<0 && integral[i+10]<0 && integral[i+11]<0) {
            ch = 0;
            for (int j = i+1; j < i+9; j++) {
                ch |= (integral[j]>0) << (8-j+i);
            }
            p = ParityTable256_record[ch];
            printf("%c", ch);
            strbuf[(i-13)/12] = ch;
            i += 12;
        }
        printf("\n%d characters decoded\n", (i-13)/12);
        strbuf[(i-13)/12] = '\0';
        
        pRecordState->mCurrentPacket += inNumPackets;
        AudioQueueEnqueueBuffer(pRecordState->mQueue, inBuffer, 0, NULL);
        
        // translate strbuf into NSString
        NSString *resultStr = [NSString stringWithCString:strbuf encoding:NSASCIIStringEncoding];
        if (resultStr.length > 0) { // valid sound
//            DebugLog(@"found valid sound");
            
            [(AMRecorder *)pRecordState->mSelf setResult:resultStr];
            [[(AMRecorder *)pRecordState->mSelf delegate] recorderDidFinishRecording]; // check the delegate
            
//            shouldStop = true;
        } else {
            DebugLog(@"Not a valid sound. Still recording until times up.");
        }
    }
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
//    // already got information from a single sound
//    if (pRecordState->mIsRunning && shouldStop) {
//        [(AMRecorder *)pRecordState->mSelf stop]; // stop recorder
//        // call delegate function to send invitation
//        [[(AMRecorder *)pRecordState->mSelf delegate] recorderDidFinishRecording]; // check the delegate
//    }
}

@end
