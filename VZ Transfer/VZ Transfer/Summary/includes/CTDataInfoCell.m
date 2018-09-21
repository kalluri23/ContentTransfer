//
//  CTDataInfoCell.m
//  contenttransfer
//
//  Created by Sun, Xin on 4/21/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTDataInfoCell.h"
#import "CTDeviceMarco.h"

@implementation CTDataInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if ([CTDeviceMarco isiPhone4AndBelow]) {
        _iconWidth.constant -= 10;
    }
}

@end
