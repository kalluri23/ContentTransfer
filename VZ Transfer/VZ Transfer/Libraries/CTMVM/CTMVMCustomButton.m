//
//  UIButton+Custom.m
//  myverizon
//
//  Created by kamlesh on 1/8/15.
//  Copyright (c) 2015 Verizon Wireless. All rights reserved.
//

#import "CTMVMCustomButton.h"

@interface CTMVMCustomButton ()
@property (nonatomic, copy) ButtonTapBlock buttonTapBlock;
@end
@implementation CTMVMCustomButton

- (void)addBlock:(ButtonTapBlock) buttonTapBlock forControlEvents:(UIControlEvents)event {
    self.buttonTapBlock = buttonTapBlock;
    [self addTarget:self action:@selector(callBlock:) forControlEvents:event];
}

-(void)callBlock:(id)sender{
    if (self.buttonTapBlock) {
        self.buttonTapBlock(self);
    }
}


@end
