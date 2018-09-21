//
//  VolumeConfiguration.h
//  FileShareDemo
//
//  Created by Sun, Xin on 1/28/16.
//  Copyright © 2016 vz. All rights reserved.
//

#ifndef VolumeConfiguration_h
#define VolumeConfiguration_h

/**
 * Volume value set from 0.0 to 1.0, 0.0625 difference for each press as fraction number
 */
#define FRACTION 0.0625

/**
 * Because there is only 16 level of volumes user could set for the device
 * So create a 16 large array to set proper relative volume for each level of the system volume
 *
 * Note: The difference between each level of the volume in float is 0.0625, range from 0.0f to 1.0f
 */
static float volumes[16] = {
    1.0000f,               //1
    0.9400f,               //2
    0.8680f,               //3
    0.6007f,               //4
    0.2100f,               //5
    0.1510f,               //6
    0.0510f,               //7
    0.0360f,               //8
    0.0210f,               //9
    0.0110f,               //10
    0.0100f,               //11
    0.0080f,               //12
    0.0060f,               //13
    0.0055f,               //14
    0.0045f,               //15
    0.0030f                //16
}; // test data for relative volume

static float currentVolumeForReceiver = -1.0f;

#endif /* VolumeConfiguration_h */
