//
//  CTColor.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/18/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTColor.h"
#import "CTContentTransferConstant.h"


@implementation CTColor

+ (UIColor *)darkSkyBlueColor {
    return [UIColor colorWithRed:.62 green:.85 blue:.95 alpha:1.0];
}

+ (UIColor *)progressColor {
    return [UIColor colorWithRed:(116.0/255.0) green:(118.0/255.0) blue:(118.0/255.0) alpha:1];
}

+ (UIColor *)trackColor {
    return [UIColor colorWithRed:(243.0/255.0) green:(243.0/255.0) blue:(243.0/255.0) alpha:1];
}

//#CD040B
+ (CTColor *)primaryRedColor {
    return (CTColor *)[CTColor getColorForHex:@"#CD040B"];
}

//#F6F6F6
+ (CTColor *)buttonColorInactive {
    return (CTColor *)[CTColor getColorForHex:@"#F6F6F6"];
}

//#959595
+ (CTColor *)buttonTitleColorInactive {
    return (CTColor *)[CTColor getColorForHex:@"#959595"];
}

//#990308
+ (CTColor *)buttonColorHighlighted {
    return (CTColor *)[CTColor getColorForHex:@"#990308"];
}

//#333333
+ (CTColor *)charcoalColor {
    return (CTColor *)[CTColor getColorForHex:@"#333333"];
}

//#82ceac
+ (CTColor *)progressGreenColor {
    return (CTColor *)[CTColor getColorForHex:@"#82CEAC"];
}

@end
