//
//  UIButton+Custom.h
//  myverizon
//
//  Created by kamlesh on 1/8/15.
//  Copyright (c) 2015 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ButtonTapBlock)(id sender);

@interface CTMVMCustomButton: UIButton

@property (nonatomic, strong) id dataPassed;
- (void)addBlock:(ButtonTapBlock) buttonTapBlock forControlEvents:(UIControlEvents)event;

@end
