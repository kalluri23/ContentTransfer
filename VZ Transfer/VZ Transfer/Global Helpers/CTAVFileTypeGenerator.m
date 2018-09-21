//
//  CTAVFileTypeGenerator.m
//  contenttransfer
//
//  Created by Sun, Xin on 9/26/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTAVFileTypeGenerator.h"

@implementation CTAVFileTypeGenerator

+ (AVFileType)getProperAVFileTypeForFile:(NSURL *)url {
    // Get extension of the file
    NSString *pathExtension = url.pathExtension;
    
    // Return proper AVFileType value based on extension.
    if ([[pathExtension lowercaseString] isEqualToString:@"mov"] || [[pathExtension lowercaseString] isEqualToString:@"qt"]) {
        return AVFileTypeQuickTimeMovie;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"mp4"]) {
        return AVFileTypeMPEG4;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"m4v"]) {
        return AVFileTypeAppleM4V;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"m4a"]) {
        return AVFileTypeAppleM4A;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"3gp"] || [[pathExtension lowercaseString] isEqualToString:@"3gpp"]) {
        return AVFileType3GPP;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"3g2"] || [[pathExtension lowercaseString] isEqualToString:@"3gp2"]) {
        return AVFileType3GPP2;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"caf"]) {
        return AVFileTypeCoreAudioFormat;
    }  else if ([[pathExtension lowercaseString] isEqualToString:@"wav"] || [[pathExtension lowercaseString] isEqualToString:@"wave"] || [[pathExtension lowercaseString] isEqualToString:@"bwf"]) {
        return AVFileTypeWAVE;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"aif"] || [[pathExtension lowercaseString] isEqualToString:@"aiff"]) {
        return AVFileTypeAIFF;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"aifc"] || [[pathExtension lowercaseString] isEqualToString:@"cdda"]) {
        return AVFileTypeAIFC;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"amr"]) {
        return AVFileTypeAMR;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"mp3"]) {
        return AVFileTypeMPEGLayer3;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"au"] || [[pathExtension lowercaseString] isEqualToString:@"snd"]) {
        return AVFileTypeSunAU;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"ac3"]) {
        return AVFileTypeAC3;
    } else if ([[pathExtension lowercaseString] isEqualToString:@"eac3"]) {
        return AVFileTypeEnhancedAC3;
    } else {
        if (@available(iOS 11.0, *)) {
            // iOS 11 newly available file type
            if ([[pathExtension lowercaseString] isEqualToString:@"jpg"] || [[pathExtension lowercaseString] isEqualToString:@"jpeg"]) {
            } else if ([[pathExtension lowercaseString] isEqualToString:@"dng"]) {
                return AVFileTypeDNG;
            } else if ([[pathExtension lowercaseString] isEqualToString:@"heic"]) {
                return AVFileTypeHEIC;
            } else if ([[pathExtension lowercaseString] isEqualToString:@"avci"]) {
                return AVFileTypeAVCI;
            } else if ([[pathExtension lowercaseString] isEqualToString:@"heif"]) {
                return AVFileTypeHEIF;
            } else if ([[pathExtension lowercaseString] isEqualToString:@"tiff"] || [[pathExtension lowercaseString] isEqualToString:@"tif"]) {
                return AVFileTypeTIFF;
            }
        }
        
        return nil;
    }
}

@end
