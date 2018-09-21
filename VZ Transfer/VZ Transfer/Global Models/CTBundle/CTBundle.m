//
//  CTBundle.m
//  CTTransfer
//
//  Created by Development on 8/9/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTBundle.h"

@implementation CTBundle

+ (nullable NSBundle *)resourceBundle {
    return [NSBundle bundleForClass:[self class]];
}

@end
