//
//  VZCTProgressView.m
//  contenttransfer
//
//  Created by Sun, Xin on 7/6/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "CTCustomAlertView.h"

//#import "CDActivityIndicatorView.h"
#import "UIImage+Helper.h"
#import "CTMFLoadingSpinner.h"
#import "CTRoundCheckMarkView.h"

@interface CTCustomAlertView ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) CTMFLoadingSpinner *spinner;
@property (strong, nonatomic) UILabel *infoLbl;
@property (strong, nonatomic) CTRoundCheckMarkView *icon;
@property (strong, nonatomic) UIButton *cancelBtn;

@property (nonatomic, assign) enum CTAlertViewOritation oritation;
@end

@implementation CTCustomAlertView

- (instancetype)initCustomAlertViewWithText:(NSString *)text withOritation:(enum CTAlertViewOritation)oritation {
    
    self = [super init];
    
    if (self) {
        [self _addBackgroundView]; // add background transparent view
        
        [self initAlertViewWithText:text oritation:oritation];
    }
    
    return self;
}

- (void)initAlertViewWithText:(NSString *)text oritation:(enum CTAlertViewOritation)oritation {
    
    _progressView = [[UIView alloc] init];
    if (_progressView) {
        _oritation = oritation;
        _progressView.alpha = 1.f;
        _progressView.backgroundColor = [UIColor whiteColor];
        
        CGFloat labelH = [self _getLabelHeight:text];
        if (labelH < 37.f) {
            labelH = 37.f;
        }
        if (oritation == CTAlertViewOritation_VERTICAL) {
            _progressView.frame = CGRectMake(0, 0, 270, labelH + 30 + 37 + 25 + 25);
        } else {
            _progressView.frame = CGRectMake(0, 0, 270, labelH + 25 + 25);
        }
        
        [self _makeViewRoundedCorner];
        
        [self _addSpinner];
        [self _addTextLbl:text];
    }
}

- (void)_addBackgroundView {
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    _backgroundView.backgroundColor = [UIColor darkGrayColor];
    _backgroundView.alpha = 0.4f;
}

- (void)_addSpinner {
    if (_oritation == CTAlertViewOritation_VERTICAL) {
        self.spinner = [[CTMFLoadingSpinner alloc] initWithFrame:CGRectMake(_progressView.frame.size.width/2-18.5f, 25, 37.f, 37.f)];
    } else {
        self.spinner = [[CTMFLoadingSpinner alloc] initWithFrame:CGRectMake(25, _progressView.frame.size.height/2-18.5f, 37.f, 37.f)];
    }
    self.spinner.backgroundColor = [UIColor clearColor];
    
    [_progressView addSubview:self.spinner];
    [_progressView bringSubviewToFront:self.spinner];
}

- (void)_addTextLbl:(NSString *)text {
    self.infoLbl = [[UILabel alloc] init];
    self.infoLbl.numberOfLines = 0;
    if (_oritation == CTAlertViewOritation_VERTICAL) {
        self.infoLbl.textAlignment = NSTextAlignmentCenter;
    } else {
        self.infoLbl.textAlignment = NSTextAlignmentLeft;
    }
    self.infoLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    
    self.infoLbl.text = text;
    
    //    self.infoLbl.backgroundColor = [UIColor lightGrayColor];
    
    // Constraints for label
    [self.infoLbl setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (_oritation == CTAlertViewOritation_VERTICAL) {
        [self.infoLbl addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLbl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:21]];
        
        [_progressView addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLbl attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeLeading multiplier:1 constant:10]];
        [_progressView addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLbl attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10]];
        [_progressView addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLbl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [_progressView addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLbl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.spinner attribute:NSLayoutAttributeBottom multiplier:1 constant:30]];
    } else {
        [self.infoLbl addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLbl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:37]];
        
        [_progressView addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLbl attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeLeading multiplier:1 constant:50+37]];
        [_progressView addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLbl attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10]];
        
        [_progressView addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLbl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    
    [_progressView addSubview:self.infoLbl];
    [_progressView bringSubviewToFront:self.infoLbl];
    
    [self.infoLbl setNeedsLayout];
}

- (void)_addCancelButton {
    _cancelBtn = [[UIButton alloc] init];
    [_cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_cancelBtn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:0.4f]] forState:UIControlStateHighlighted];
    
    [_cancelBtn setTitleColor:self.tintColor forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]+3];
    
    [_cancelBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.cancelBtn addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:42]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self addSubview:_cancelBtn];
    [self bringSubviewToFront:_cancelBtn];
    
    UIView *singleLine = [[UIView alloc] init];
    [singleLine setTranslatesAutoresizingMaskIntoConstraints:NO];
    [singleLine setBackgroundColor:[UIColor colorWithRed:210/255.0f green:210/255.0f blue:210/255.0f alpha:1.0f]];
    
    [singleLine addConstraint:[NSLayoutConstraint constraintWithItem:singleLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:0.5f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:singleLine attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:singleLine attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:singleLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_cancelBtn attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [self addSubview:singleLine];
    [self bringSubviewToFront:singleLine];
    
    [_cancelBtn setNeedsLayout];
    [singleLine setNeedsLayout];
}

- (void)cancelClicked:(UIButton *)button
{
    [self.delegate cancelButtonDidClicked];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)_makeViewRoundedCorner
{
    // border radius
    [_progressView.layer setCornerRadius:14.0f];
    _progressView.layer.masksToBounds = YES;
    
    // drop shadow
    [_progressView.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [_progressView.layer setShadowOpacity:0.5];
    [_progressView.layer setShadowRadius:2.0];
    [_progressView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
}

- (CGFloat)_getLabelHeight:(NSString *)text {
    CGSize constraint = CGSizeMake(183.f, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes:@{NSFontAttributeName:[CTMVMFonts mvmBookFontOfSize:15]}
                                            context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

- (void)updateLbelText:(NSString *)text oritation:(enum CTAlertViewOritation)oritation {
    
    if ([text isEqualToString:self.infoLbl.text]) {
        return;
    }
    
    self.infoLbl.text = text;
    
    CGFloat labelH = [self _getLabelHeight:text];
    if (labelH < 37.f) {
        labelH = 37.f;
    }
    CGFloat newH = 0;
    if (_oritation == CTAlertViewOritation_VERTICAL) {
        newH = labelH + 30 + 37 + 25 + 25;
        if (newH > _progressView.frame.size.height) {
            _progressView.frame = CGRectMake(_progressView.frame.origin.x, _progressView.frame.origin.y, 270, newH);
        }
    } else {
        newH = labelH + 25 + 25;
        if (newH > _progressView.frame.size.height) {
            _progressView.frame = CGRectMake(_progressView.frame.origin.x, _progressView.frame.origin.y, 270, newH);
            self.spinner.frame = CGRectMake(25, _progressView.frame.size.height/2-18.5f, 37.f, 37.f);
        }
    }
    
    [self.infoLbl layoutIfNeeded];
    [self.spinner layoutIfNeeded];
    [_progressView layoutIfNeeded];
}

- (void)becomeFinishView:(BOOL)saving {
    _icon = [[CTRoundCheckMarkView alloc] initWithSize:self.spinner.frame.size.height andCenter:self.spinner.center andColor:vCheckMarkViewColorGreen];
    _icon.withAnimate = YES;
    
    [self.spinner pauseSpinner];
    self.spinner.hidden = YES;
    
    CGFloat labelH = 0;
    if (saving) {
        self.infoLbl.text = CTLocalizedString(CT_SAVE_FINISHED, nil);
        
        labelH = [self _getLabelHeight:CTLocalizedString(CT_SAVE_FINISHED, nil)];
        
        [_cancelBtn removeFromSuperview];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, labelH + 30 + 37 + 25 + 25);
    } else {
        self.infoLbl.text = CTLocalizedString(CT_DELETE_FINISHED, nil);
        
        labelH = [self _getLabelHeight:CTLocalizedString(CT_DELETE_FINISHED, nil)];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, labelH + 30 + 37 + 25 + 25);
    }
    
    [self.infoLbl setNeedsLayout];
    
    [_progressView addSubview:_icon];
    [_progressView bringSubviewToFront:_icon];
    
    [_icon setNeedsLayout];
    [_progressView setNeedsLayout];
    
    [_icon startDrawLine];
}

- (void)show {
    [self show:nil];
}

- (void)show:(void(^)(void))handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        _backgroundView.alpha = 0.4f;
        [[[UIApplication sharedApplication] keyWindow] addSubview:_backgroundView];
        
        _progressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
        [[[UIApplication sharedApplication] keyWindow] addSubview:_progressView];
        _progressView.center = _backgroundView.center;
        
        [UIView animateWithDuration:.25f animations:^{
            _progressView.alpha = 1;
            _progressView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _visible = YES;
            [self.spinner resumeSpinner];
            if (handler) {
                handler();
            }
        }];
    });
}

- (void)hide:(void(^)(void))handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.2f animations:^{
            _progressView.alpha = 0;
            _progressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            _backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            _visible = NO;
            [_progressView removeFromSuperview];
            [_backgroundView removeFromSuperview];
            [self.spinner pauseSpinner];
            
            if (handler) {
                handler();
            }
        }];
    });
}

@end
