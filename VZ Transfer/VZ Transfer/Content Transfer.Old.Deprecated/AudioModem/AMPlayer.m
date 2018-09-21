//
//  AMPlayer.m
//  FileShareDemo
//
//  Created by VVM-MAC02 on 1/20/16.
//  Copyright © 2016 vz. All rights reserved.
//

#import "AMPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioModem.h"
#import "ADSharedMacros.h"
#import "AudioSessionManager.h"

typedef struct {
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef mQueue;
    AudioQueueBufferRef mBuffers[kNumberBuffers];
    SInt64 mCurrentPacket;
    UInt32 mNumPacketsToRead;
    UInt32 bufferByteSize;
    bool mIsRunning;
    const char * mMessage;
    UInt32 mMessageLength;
    float mTheta;
    __unsafe_unretained id *mSelf;
} AQPlayState;

static unsigned char barkerbin[BARKER_LEN] = {
    0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0
};

static const unsigned char ParityTable256[256] =
{
#   define P2(n) n, n^1, n^1, n
#   define P4(n) P2(n), P2(n^1), P2(n^1), P2(n)
#   define P6(n) P4(n), P4(n^1), P4(n^1), P4(n)
    P6(0), P6(1), P6(1), P6(0)
};

@interface AMPlayer ()

@property (nonatomic, assign) AQPlayState playState; // sound play property
//@property (nonatomic, assign) NSString *playInfo; // save the string need to be played

@end

@implementation AMPlayer

//@synthesize playInfo;

// Init funciton for AMPlayer
- (AMPlayer *)initWithFormat
{
    self = [super init];
    if (self) {
        [self setupAudioFormat]; // setting up audio format
    }
    
    return self;
}

// Audio queue is playing or not
- (BOOL)isRunning
{
    return self.playState.mIsRunning;
}

// Audio queue should play
- (void)play
{
    OSStatus status = noErr;
    
    _playState.mIsRunning = YES;
    for (int i = 0; i < kNumberBuffers; i++) {
        AudioQueueAllocateBuffer(_playState.mQueue, _playState.bufferByteSize, &_playState.mBuffers[i]);
        HandleOutputBuffer(&_playState, _playState.mQueue, _playState.mBuffers[i]);
    }
    
    ADAssert(noErr == status, @"Could not allocate buffers.");
    
    status = AudioQueueStart(_playState.mQueue, NULL);
    
    ADAssert(noErr == status, @"Could not start playing.");
}

- (void)stop
{
    AudioQueueStop(_playState.mQueue, YES);
    _playState.mIsRunning = NO;
}

// Setup string to be played
- (void)setupPlayInfo:(NSString *)info
{
    //self.playInfo = info;
    [self _encodeMessage:info];
}

// Setup audio format
- (void)setupAudioFormat {
    [AudioSessionManager enablePlayingSoundInSlientMode:nil]; // allow app to play sound even in slient mode
    
    _playState.mDataFormat.mFormatID = kAudioFormatLinearPCM;
    _playState.mDataFormat.mSampleRate = 44100.0f;
    _playState.mDataFormat.mBitsPerChannel = 16;
    _playState.mDataFormat.mChannelsPerFrame = 1;
    _playState.mDataFormat.mFramesPerPacket = 1;
    _playState.mDataFormat.mBytesPerFrame = _playState.mDataFormat.mBytesPerPacket = _playState.mDataFormat.mChannelsPerFrame * sizeof(SInt16);
    _playState.mDataFormat.mReserved = 0;
    _playState.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsNonInterleaved | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked ;//| kLinearPCMFormatFlagIsBigEndian;
    
    _playState.mCurrentPacket = 0;
    
    [self _deriveBufferSize:1.0f];
    
    OSStatus status = noErr;
    status = AudioQueueNewOutput(&_playState.mDataFormat,
                                 HandleOutputBuffer,
                                 &_playState,
                                 NULL,
                                 NULL,
                                 0,
                                 &_playState.mQueue);
    
    ADAssert(noErr == status, @"Could not create queue.");
}

- (void)_encodeMessage:(NSString *)message {
    const char * str = [message cStringUsingEncoding:NSASCIIStringEncoding];
    UInt32 length = (UInt32)message.length;
    UInt32 encodedLength = length * 12 + BARKER_LEN + 1;
    unsigned char * encodedMessage = (unsigned char *)calloc(encodedLength, sizeof(unsigned char));
    char * bpsk = (char *)calloc(encodedLength * BIT_RATE, sizeof(char));
    
    encodedMessage[0] = 1;
    for (int i = 1; i < BARKER_LEN+1; i++) {
        encodedMessage[i] = 1& ~(barkerbin[i-1] ^ encodedMessage[i-1]);
    }
    for (int i = BARKER_LEN+1; i < encodedLength; i++) {
        switch ((i-BARKER_LEN-1)%12) {
            case 0:
            case 10:
            case 11:
                encodedMessage[i] = 1& ~(0 ^ encodedMessage[i-1]);
                break;
            case 9:
                encodedMessage[i] = 1& ~(ParityTable256[str[(i-BARKER_LEN-1)/12]] ^ encodedMessage[i-1]);
                break;
            default:
                encodedMessage[i] = 1& ~((((unsigned char)str[(i-BARKER_LEN-1)/12] >> (8-((i-BARKER_LEN-1)%12)) & 0x01)) ^ encodedMessage[i-1]);
                break;
        }
    }
    
#ifdef SHOW_ENCODED
    for (int i = 0; i < encodedLength; i++) {
        printf("%d", encodedMessage[i]);
    }
    printf("\n");
#endif
    
    for (int i = 0; i < encodedLength; i++) {
        for (int j = 0; j < SAMPLE_PER_BIT; j++) {
            bpsk[i*SAMPLE_PER_BIT+j] = 2* encodedMessage[i] - 1;
        }
    }
    
#ifdef SHOW_BASEBAND
    for (int i = 0; i < SAMPLE_PER_BIT * encodedLength; i++) {
        printf("%+d\n", bpsk[i]);
    }
#endif
    
    _playState.mMessageLength = encodedLength * SAMPLE_PER_BIT;
    _playState.mMessage = bpsk;
    
    free(encodedMessage);
}

- (void)_deriveBufferSize:(Float64)seconds {
    static const int maxBufferSize = 0x50000;
    
    int maxPacketSize = _playState.mDataFormat.mBytesPerPacket;
    
    if (maxPacketSize == 0) {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty(_playState.mQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize, &maxVBRPacketSize);
    }
    
    Float64 numBytesForTime = round(_playState.mDataFormat.mSampleRate * maxPacketSize * seconds);
    
    _playState.bufferByteSize = (UInt32) MIN(numBytesForTime, maxBufferSize);
}

// C style output handler to handle the output sound track
void HandleOutputBuffer(void * inUserData,
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer) {
    AQPlayState * pPlayState = (AQPlayState *)inUserData;
    
    if ( !pPlayState->mIsRunning) {
        return;
    }
    
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    UInt32 numBytesToPlay = inBuffer->mAudioDataBytesCapacity;
    UInt32 numPackets = numBytesToPlay/pPlayState->mDataFormat.mBytesPerPacket;
    
    SInt16 * buffer = (SInt16 *)inBuffer->mAudioData;
    
    printf("playing from : %1.5f (#%lld)\n", pPlayState->mCurrentPacket/(float)SR, pPlayState->mCurrentPacket);
    printf("message length: %u samples\n", (unsigned int)pPlayState->mMessageLength);
    
    for(long long i = pPlayState->mCurrentPacket; i < pPlayState->mCurrentPacket + numPackets; i++) {
        long idx = i % pPlayState->mMessageLength;
        short encoding =  pPlayState->mMessage[idx];
        buffer[i-pPlayState->mCurrentPacket] = (SInt16) (sin(2 * M_PI * FREQ * i / SR) * SHRT_MAX * encoding);
    }
    
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    inBuffer->mAudioDataByteSize = numPackets * 2;
    AudioQueueEnqueueBuffer(pPlayState->mQueue, inBuffer, 0, NULL);
    pPlayState->mCurrentPacket += numPackets;
}

- (void)updateRelativeVolumeForPlayer:(float)newVolume
{
    OSStatus status = AudioQueueSetParameter(_playState.mQueue, kAudioQueueParam_Volume, newVolume); //Chane relative volume for audio queue
    ADAssert(noErr == status, @"Could not set up volume for audio queue.");
}

@end
