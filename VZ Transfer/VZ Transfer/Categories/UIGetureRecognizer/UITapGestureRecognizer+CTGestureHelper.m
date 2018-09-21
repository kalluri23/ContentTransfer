//
//  UITapGestureRecognizer+CTGestureHelper.m
//  contenttransfer
//
//  Created by Sun, Xin on 4/27/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "UITapGestureRecognizer+CTGestureHelper.h"

@implementation UITapGestureRecognizer (CTGestureHelper)

- (BOOL)didTapAttributedTextInLabel:(UILabel *)label inRange:(NSRange)targetRange alignment:(NSTextAlignment)aliment {
    NSParameterAssert(label != nil);
    
    CGSize labelSize = label.bounds.size;
    // create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:label.attributedText];
    
    // configure layoutManager and textStorage
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    // configure textContainer for the label
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = label.lineBreakMode;
    textContainer.maximumNumberOfLines = label.numberOfLines;
    textContainer.size = labelSize;
    
    // find the tapped character location and compare it to the specified range
    CGFloat fractor = 0.0;
    if (aliment == NSTextAlignmentCenter) {
        fractor = 0.5;
    } else if (aliment == NSTextAlignmentRight) {
        fractor = 1.0;
    }
    CGPoint locationOfTouchInLabel = [self locationInView:label];
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * fractor - textBoundingBox.origin.x, (labelSize.height - textBoundingBox.size.height) * fractor - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x, locationOfTouchInLabel.y - textContainerOffset.y);
    NSInteger indexOfCharacter = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    
    if (NSLocationInRange(indexOfCharacter, targetRange)) {
        return YES;
    } else {
        return NO;
    }
}

@end
