//
//  LeftRightTextButtonHeaderFooterView.m
//  myverizon
//
//  Created by Scott Pfeil on 1/30/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "LeftRightTextButtonHeaderFooterView.h"
#import "MVMButtons.h"
#import "MVMStyler.h"

@implementation LeftRightTextButtonHeaderFooterView

- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    if (!self.leftButton) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
            
        UIButton *leftButton = [MVMButtons primaryLinkButon:nil constrainHeight:YES];
        leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:leftButton];
        self.leftButton = leftButton;
        
        UIButton *rightButton = [MVMButtons primaryLinkButon:nil constrainHeight:YES];
        rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:rightButton];
        self.rightButton = rightButton;
            
        NSDictionary *horizontalMetrics = @{@"horizontal":@(STANDARD_LARGE_BUFFER)};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontal-[leftButton]->=horizontal-[rightButton]-horizontal@900-|" options:NSLayoutFormatAlignAllCenterY metrics:horizontalMetrics views:NSDictionaryOfVariableBindings(leftButton,rightButton)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0@900-[leftButton]-10-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(leftButton)]];
    }
}

@end
