//
//  CTMVMStyler.m
//  myverizon
//
//  Created by Scott Pfeil on 11/26/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//

#import "CTMVMStyler.h"
#import "CTMVMFonts.h"
#import "CTMVMColor.h"
#import "CTMVMConstants.h"

CGFloat const CT_STANDARD_SMALL_BUFFER = 10;
CGFloat const CT_STANDARD_LARGE_BUFFER = 20;
CGFloat const CT_CT_STANDARD_LARGE_BUFFER_TWO = 30;
CGFloat const CT_CT_STANDARD_LARGE_BUFFER_THREE = 40;
CGFloat const CT_STANDARD_BUFFER_BETWEEN_FIELD_AND_TITLE = 4;
CGFloat const CT_STANDARD_BUFFER_UNDER_SEGMENTED_CONTROL = 2;
CGFloat const CT_STANDARD_CELL_BIG_SPACING = 16;
CGFloat const CT_STANDARD_RELATED_LINK_HEADER_FOOTER_HEIGHT = 2;

@implementation CTMVMStyler

#pragma mark - Fonts

+ (UIFont *)fontForStandardTextField {
    return [CTMVMFonts mvmBookFontOfSize:12];
}

+ (UIFont *)fontForStandardTitleLabel {
    return [CTMVMFonts mvmMediumFontOfSize:18];
}

+ (UIFont *)fontForStandardBoldTitleLabel {
    return [CTMVMFonts mvmBoldFontOfSize:18];
}

+ (UIFont *)fontForStandardMediumTitleLabel {
    return [CTMVMFonts mvmMediumFontOfSize:14];
}

+ (UIFont *)fontForStandardSmallTitleLabel {
    return [CTMVMFonts mvmMediumFontOfSize:12];
}

+ (UIFont *)fontForStandardTinyBoldLabel {
    return [CTMVMFonts mvmBoldFontOfSize:10];
}

+ (UIFont *)fontForStandardTinyTitleLabel {
    return [CTMVMFonts mvmMediumFontOfSize:10];
}


+ (UIFont *)fontForStandardMessageLabel {
    return [CTMVMFonts mvmBookFontOfSize:14];
}

+ (UIFont *)fontForStandardBoldMessageLabel {
    return [CTMVMFonts mvmBoldFontOfSize:14];
}

+ (UIFont *)fontForStandardBitSmallMessageLabel {
    return [CTMVMFonts mvmBookFontOfSize:13];
}

+ (UIFont *)fontForStandardSmallMessageLabel {
    return [CTMVMFonts mvmBookFontOfSize:12];
}

+ (UIFont *)fontForStandardSmallBoldMessageLabel {
    return [CTMVMFonts mvmBoldFontOfSize:12];
}

+ (UIFont *)fontForStandardTinyMessageLabel {
    return [CTMVMFonts mvmBookFontOfSize:10];
}

+ (UIFont *)fontForStandardTinyBoldMessageLabel {
    return [CTMVMFonts mvmBoldFontOfSize:10];
}

+ (UIFont *)fontForTableTitleLabel {
    return [CTMVMFonts mvmMediumFontOfSize:16];
}

+ (UIFont *)fontForBoldTableTitleLabel {
    return [CTMVMFonts mvmBoldFontOfSize:16];
}

+ (UIFont *)fontForRoundedButtons {
    
#if STANDALONE
    return [CTMVMFonts mvmBookFontOfSize:16];
#else
     return [CTMVMFonts mvmBookFontOfSize:16];
#endif
   
}

+ (UIFont *)fontForStandardItalicMessageLabel {
    return [CTMVMFonts mvmBookItalicFontOfSize:14];
}

+ (UIFont *)fontForStandardItalicBoldMessageLabel {
    return [CTMVMFonts mvmBoldItalicFontOfSize:14];
}

+ (UIFont *)fontForStandardItalicSmallMessageLabel {
    return [CTMVMFonts mvmBookItalicFontOfSize:12];
}

+ (UIFont *)fontForStandardItalicSmallBoldMessageLabel {
    return [CTMVMFonts mvmBoldItalicFontOfSize:12];
}

+ (UIFont *)fontForStandardItalicTinyMessageLabel {
    return [CTMVMFonts mvmBookItalicFontOfSize:10];
}

#pragma mark - Styles

+ (void)styleStaticTextView:(UITextView *)textView withAttributedString:(NSAttributedString *)string {
    textView.attributedText = string;
    textView.textContainer.lineFragmentPadding = 0;
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.scrollEnabled = NO;
    textView.editable = NO;
    [textView sizeToFit];
}

+ (void)styleStandardTextField:(UITextField *)textField {
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [CTMVMStyler fontForStandardTextField];
    textField.layer.cornerRadius = 3.0f;
    textField.layer.masksToBounds = YES;
    textField.layer.borderColor = [CTMVMColor mvmWayfinderLightTextColor].CGColor;
    textField.layer.borderWidth = 1.0f;
}

+ (void)styleStandardTitleLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardTitleLabel];
}

+ (void)styleStandardBoldTitleLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardBoldTitleLabel];
}

+ (void)styleStandardMediumTitleLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardMediumTitleLabel];
}

+ (void)styleStandardSmallTitleLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardSmallTitleLabel];
}

+ (void)styleStandardTinyTitleLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardTinyTitleLabel];
}


+ (void)styleStandardMessageLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardMessageLabel];
}

+ (void)styleStandardBoldMessageLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardBoldMessageLabel];
}

+ (void)styleStandardSmallMessageLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardSmallMessageLabel];
}

+ (void)styleStandardSmallBoldMessageLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardSmallBoldMessageLabel];
}

+ (void)styleStandardTinyMessageLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardTinyMessageLabel];
}

+ (void)styleTableTitleLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForTableTitleLabel];
}

+ (void)styleBoldTableTitleLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForBoldTableTitleLabel];
}

+ (void)styleStandardSegmentedControl:(UISegmentedControl *)segmentedControl {
    [segmentedControl setTintColor:[CTMVMColor mvmPrimaryBlueColor]];
    [segmentedControl setTitleTextAttributes:@{NSFontAttributeName:[CTMVMStyler fontForStandardTinyTitleLabel],NSKernAttributeName:[CTMVMStyler kernForTinySizeFont]} forState:UIControlStateNormal];
}

+ (void)styleStandardSeparatorView:(UIView *)view {
    [view setBackgroundColor:[CTMVMColor mvmSecondaryGreyColor]];
}

// rounded corners with lightgray border and background
+ (void)styleStandardRoundedContainer:(UIView *)view
{
    view.layer.cornerRadius = CORNER_RADIUS_TEXT_FEILD;
    view.layer.borderWidth = 1.0f;
    UIColor *borderColor = [UIColor lightGrayColor];
    view.layer.borderColor = borderColor.CGColor;
    view.backgroundColor = borderColor;
}

+ (void)styleStandardItalicMessageLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardItalicMessageLabel];
}

+ (void)styleStandardItalicBoldMessageLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardItalicBoldMessageLabel];
}

+ (void)styleStandardItalicSmallMessageLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardItalicSmallMessageLabel];
}

+ (void)styleStandardItalicSmallBoldMessageLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardItalicSmallBoldMessageLabel];
}

+ (void)styleStandardItalicTinyMessageLabel:(UILabel *)label {
    label.font = [CTMVMStyler fontForStandardItalicTinyMessageLabel];
}

#pragma mark - Attributed Strings

+ (NSAttributedString *)styleGetAttributedString:(NSString *)string font:(UIFont *)font color:(UIColor *)color kern:(NSNumber *)kern {
    NSAttributedString *attributedString = nil;
    if (string.length > 0) {
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:@{
                                                                          NSFontAttributeName:font,
                                                                          NSForegroundColorAttributeName:color,
                                                                          NSKernAttributeName:kern
                                                                          }];
    } else {
        attributedString = [[NSAttributedString alloc] initWithString:@""];
    }
    
    return attributedString;
}

+ (NSAttributedString *)styleGetAttributedStringForStandardTitleLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardTitleLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForStandardTitleSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardBoldTitleLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardBoldTitleLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForStandardTitleSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardMediumTitleLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardMediumTitleLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForStandardMessageSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardSmallTitleLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardSmallTitleLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForSmallSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardTinyTitleLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardTinyTitleLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForTinySizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardMessageLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardMessageLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForStandardMessageSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardBoldMessageLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardBoldMessageLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForStandardMessageSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardSmallMessageLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardSmallMessageLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForSmallSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardSmallBoldMessageLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardSmallBoldMessageLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForSmallSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardTinyMessageLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardTinyMessageLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForTinySizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardTinyBoldMessageLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardTinyBoldMessageLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForTinySizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForTableTitleLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForTableTitleLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForStandardTitleSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForBoldTableTitleLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForBoldTableTitleLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForStandardTitleSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForLinkButtonLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardSmallBoldMessageLabel] color:[CTMVMColor mvmPrimaryBlueColor] kern:[CTMVMStyler kernForSmallSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForUnderlinedLinkButtonLabel:(NSString *)string {
    NSAttributedString *attributedString = nil;
    if (string.length > 0) {
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:@{
                                                                                          NSFontAttributeName:[CTMVMStyler fontForStandardMessageLabel],
                                                                                          NSForegroundColorAttributeName:[CTMVMColor mvmTertiaryBlueColor],
                                                                                          NSKernAttributeName:[CTMVMStyler kernForSmallSizeFont],
                                                                                          NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)
                                                                                          }];
    } else {
        attributedString = [[NSAttributedString alloc] initWithString:@""];
    }
    
    return attributedString;
}

// Style title text with small bold front and standard small font for body
+ (NSAttributedString *)styleGetAttributedStringWithSmallTitle:(NSString *)titleString body:(NSString *)bodyString
{
    NSMutableAttributedString *msgString = [[NSMutableAttributedString alloc] initWithAttributedString:[CTMVMStyler styleGetAttributedStringForStandardSmallBoldMessageLabel:titleString]];
    [msgString appendAttributedString:[CTMVMStyler styleGetAttributedStringForStandardSmallMessageLabel:@"  "]];
    [msgString appendAttributedString:[CTMVMStyler styleGetAttributedStringForStandardSmallMessageLabel:bodyString]];
    return msgString;
}

+ (NSAttributedString *)styleGetAttributedLinkString:(NSString *)string  withLink:(NSString *)link;
{
    NSURL *url = [NSURL URLWithString:link];
    
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithAttributedString:[CTMVMStyler styleGetAttributedStringForUnderlinedLinkButtonLabel:string]];
        [attributedString2 addAttribute:NSLinkAttributeName value:link range:(NSMakeRange(0, attributedString2.string.length))];
        return attributedString2;
    }
    else
    {
        return [CTMVMStyler styleGetAttributedStringForStandardSmallMessageLabel:string];
    }
}

+ (NSAttributedString *)styleGetAttributedButtonLinkString:(NSString *)string  withLink:(NSString *)link;
{
    NSURL *url = [NSURL URLWithString:link];
    
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithAttributedString:[CTMVMStyler styleGetAttributedStringForLinkButtonLabel:string]];
        [attributedString2 addAttribute:NSLinkAttributeName value:link range:(NSMakeRange(0, attributedString2.string.length))];
        return attributedString2;
    }
    else
    {
        return [CTMVMStyler styleGetAttributedStringForStandardSmallMessageLabel:string];
    }
}

+ (NSAttributedString *)styleGetAttributedStringForStandardItalicMessageLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardItalicMessageLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForStandardMessageSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardItalicBoldMessageLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardItalicBoldMessageLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForStandardMessageSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardItalicSmallMessageLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardItalicSmallMessageLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForSmallSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardItalicSmallBoldMessageLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardItalicSmallBoldMessageLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForSmallSizeFont]];
}

+ (NSAttributedString *)styleGetAttributedStringForStandardItalicTinyMessageLabel:(NSString *)string {
    return [CTMVMStyler styleGetAttributedString:string font:[CTMVMStyler fontForStandardItalicTinyMessageLabel] color:[CTMVMColor mvmDarkGrayColor] kern:[CTMVMStyler kernForTinySizeFont]];
}

#pragma mark - Set Text With Styles

+ (void)styleSetTextWithStandardTitleLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardTitleLabel:text];
}

+ (void)styleSetTextWithStandardBoldTitleLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardBoldTitleLabel:text];
}

+ (void)styleSetTextWithStandardMediumTitleLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardMediumTitleLabel:text];
}

+ (void)styleSetTextWithStandardSmallTitleLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardSmallTitleLabel:text];
}

+ (void)styleSetTextWithStandardTinyTitleLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardTinyTitleLabel:text];
}

+ (void)styleSetTextWithStandardMessageLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardMessageLabel:text];
}

+ (void)styleSetTextWithStandardBoldMessageLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardBoldMessageLabel:text];
}

+ (void)styleSetTextWithStandardSmallMessageLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardSmallMessageLabel:text];
}

+ (void)styleSetTextWithStandardSmallBoldMessageLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardSmallBoldMessageLabel:text];
}

+ (void)styleSetTextWithStandardTinyMessageLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardTinyMessageLabel:text];
}

+ (void)styleSetTextWithTableTitleLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForTableTitleLabel:text];
}

+ (void)styleSetTextWithBoldTableTitleLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForBoldTableTitleLabel:text];
}

+ (void)styleSetTextButton:(UIButton *)button text:(NSString *)text {
    [button setAttributedTitle:[CTMVMStyler styleGetAttributedStringForStandardMessageLabel:text]
                      forState:UIControlStateNormal];
}

+ (void)styleSetTextWithLinkButton:(UIButton *)button text:(NSString *)text {
    [button setAttributedTitle:[CTMVMStyler styleGetAttributedStringForLinkButtonLabel:text] forState:UIControlStateNormal];
}

+ (void)styleSetTextWithUnderlinedLinkButton:(UIButton *)button text:(NSString *)text {
    [button setAttributedTitle:[CTMVMStyler styleGetAttributedStringForUnderlinedLinkButtonLabel:text] forState:UIControlStateNormal];
}

+ (void)styleSetTextWithStandardItalicMessageLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardItalicMessageLabel:text];
}

+ (void)styleSetTextWithStandardItalicBoldMessageLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardItalicBoldMessageLabel:text];
}

+ (void)styleSetTextWithStandardItalicSmallMessageLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardItalicSmallMessageLabel:text];
}

+ (void)styleSetTextWithStandardItalicSmallBoldMessageLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardItalicSmallBoldMessageLabel:text];
}

+ (void)styleSetTextWithStandardItalicTinyMessageLabel:(UILabel *)label text:(NSString *)text {
    label.attributedText = [CTMVMStyler styleGetAttributedStringForStandardItalicTinyMessageLabel:text];
}

#pragma mark - Kerning

+ (NSNumber *)kernForStandardTitleSizeFont {
    return @(-0.7);
}

+ (NSNumber *)kernForStandardMessageSizeFont {
    return @(-0.5);
}

+ (NSNumber *)kernForSmallSizeFont {
    return @(-0.4);
}

+ (NSNumber *)kernForTinySizeFont {
    return @(-0.3);
}

@end
