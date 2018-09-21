//
//  CTCustomButton.m
//  contenttransfer
//
//  Created by Development on 8/12/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTCustomButton.h"
#import "CTColor.h"
#import "CTMVMFonts.h"


@implementation CTCustomButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation CTCommonRedButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configure];
}

- (void)configure
{
    [self setTitleColor:[CTColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [CTMVMFonts mvmBookFontOfSize:14.0];
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    colorView.backgroundColor = [CTColor mvmPrimaryRedColor];
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:colorImage forState:UIControlStateNormal];
    
    colorView.backgroundColor = [CTColor buttonColorHighlighted];
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:colorImage forState:UIControlStateHighlighted];
    
    [self setTitleColor:[CTColor buttonTitleColorInactive] forState:UIControlStateDisabled];
    colorView.backgroundColor = [CTColor buttonColorInactive];
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:colorImage forState:UIControlStateDisabled];
    
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.layer.masksToBounds = YES;
}

@end

@implementation CTCommonBlackButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configure];
}

- (void)configure
{
    [self setTitleColor:[CTColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [CTMVMFonts mvmBoldFontOfSize:13.0];
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    colorView.backgroundColor = [CTColor blackColor];
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:colorImage forState:UIControlStateNormal];
    
    [self setTitleColor:[CTColor buttonTitleColorInactive] forState:UIControlStateDisabled];
    colorView.backgroundColor = [CTColor buttonColorInactive];
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:colorImage forState:UIControlStateDisabled];
    
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.layer.masksToBounds = YES;
}

@end

@implementation CTRedBorderedButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configure];
}

- (void) configure
{
    [self setTitleColor:[CTColor mvmPrimaryRedColor] forState:UIControlStateNormal];
    self.titleLabel.font = [CTMVMFonts mvmBookFontOfSize:14.0];
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [CTColor mvmPrimaryRedColor].CGColor;
    
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.layer.masksToBounds = YES;
}

- (void)simulateCommonRedButton {
    [self setTitleColor:[CTColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [CTMVMFonts mvmBookFontOfSize:14.0];
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    colorView.backgroundColor = [CTColor mvmPrimaryRedColor];
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:colorImage forState:UIControlStateNormal];
    
    colorView.backgroundColor = [CTColor buttonColorHighlighted];
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:colorImage forState:UIControlStateHighlighted];
    
    [self setTitleColor:[CTColor buttonTitleColorInactive] forState:UIControlStateDisabled];
    colorView.backgroundColor = [CTColor buttonColorInactive];
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:colorImage forState:UIControlStateDisabled];
    
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.layer.masksToBounds = YES;
}

@end

@implementation CTBlackBorderedButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configure];
}

- (void) configure
{
    [self setTitleColor:[CTColor blackColor] forState:UIControlStateNormal];
    self.titleLabel.font = [CTMVMFonts mvmBoldFontOfSize:13.0];
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [CTColor blackColor].CGColor;
    
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.layer.masksToBounds = YES;
}

- (void)simulateCommonBlackButton {
    [self setTitleColor:[CTColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [CTMVMFonts mvmBoldFontOfSize:13.0];
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    colorView.backgroundColor = [CTColor blackColor];
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:colorImage forState:UIControlStateNormal];
    
    [self setTitleColor:[CTColor buttonTitleColorInactive] forState:UIControlStateDisabled];
    colorView.backgroundColor = [CTColor buttonColorInactive];
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:colorImage forState:UIControlStateDisabled];
    
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.layer.masksToBounds = YES;
}

@end
