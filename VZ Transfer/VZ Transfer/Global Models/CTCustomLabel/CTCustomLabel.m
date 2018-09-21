//
//  CTCustomLabel.m
//  contenttransfer
//
//  Created by Snehal on 8/11/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTCustomLabel.h"
#import "CTMVMColor.h"
#import "CTMVMFonts.h"
#import "CTColor.h"

@implementation CTCustomLabel

@end

@implementation CTBoldFontLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0")) {
        self.font = [CTMVMFonts mvmBoldFontOfSize:self.font.pointSize];
    }
}

- (void)traitCollectionDidChange: (UITraitCollection *) previousTraitCollection {
    [super traitCollectionDidChange: previousTraitCollection];
    self.font = [CTMVMFonts mvmBoldFontOfSize:self.font.pointSize];
}

@end

@implementation CTPrimaryMessageLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textColor = [CTColor blackColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0")) {
        self.textColor = [CTColor blackColor];
    }
}

- (void)traitCollectionDidChange: (UITraitCollection *) previousTraitCollection {
    [super traitCollectionDidChange: previousTraitCollection];
}

@end


@implementation CTSecondaryInstructionLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textColor = [CTMVMColor blackColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0")) {
        self.font = [CTMVMFonts mvmMediumFontOfSize:self.font.pointSize];
        self.adjustsFontSizeToFitWidth=YES;
        self.minimumScaleFactor = 0.7;
    }
}

- (void)traitCollectionDidChange: (UITraitCollection *) previousTraitCollection {
    [super traitCollectionDidChange: previousTraitCollection];
    self.font = [CTMVMFonts mvmMediumFontOfSize:self.font.pointSize];
    self.adjustsFontSizeToFitWidth=YES;
    self.minimumScaleFactor = 0.7;
}

@end

@implementation CTSubheadThreeLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textColor = [CTMVMColor blackColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0")) {
        self.font = [CTMVMFonts mvmMediumFontOfSize:self.font.pointSize];
    }
}

- (void)traitCollectionDidChange: (UITraitCollection *) previousTraitCollection {
    [super traitCollectionDidChange: previousTraitCollection];
    self.font = [CTMVMFonts mvmMediumFontOfSize:self.font.pointSize];
}

@end

@implementation CTRomanFontLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textColor = [CTMVMColor mvmDarkGrayColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0")) {
        self.font = [CTMVMFonts mvmBookFontOfSize:self.font.pointSize];
    }
}

- (void)traitCollectionDidChange: (UITraitCollection *) previousTraitCollection {
    [super traitCollectionDidChange: previousTraitCollection];
    self.font = [CTMVMFonts mvmBookFontOfSize:self.font.pointSize];
}

@end

@implementation CTNHaasGroteskDSStd65MdLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textColor = [CTMVMColor mvmDarkGrayColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0")) {
        self.font = [CTMVMFonts mvmNHaasGroteskDSStd65Md:self.font.pointSize];
    }
}

- (void)traitCollectionDidChange: (UITraitCollection *) previousTraitCollection {
    [super traitCollectionDidChange: previousTraitCollection];
    self.font = [CTMVMFonts mvmNHaasGroteskDSStd65Md:self.font.pointSize];
}

@end
