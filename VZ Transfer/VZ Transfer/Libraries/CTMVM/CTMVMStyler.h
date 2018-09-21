//
//  MVMStyler.h
//  myverizon
//
//  Created by Scott Pfeil on 11/26/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//
//  Styles for mvm.

#import <Foundation/Foundation.h>

// Some standard spacings. Eventually we may move this to a function with a enum passed in so we can get different sizes for different devices.
extern CGFloat const CT_STANDARD_SMALL_BUFFER;
extern CGFloat const CT_STANDARD_SMALL_BUFFER;
extern CGFloat const CT_STANDARD_SMALL_BUFFER_TWO;
extern CGFloat const CT_STANDARD_SMALL_BUFFER_THREE;
extern CGFloat const CT_STANDARD_BUFFER_BETWEEN_FIELD_AND_TITLE;
extern CGFloat const CT_STANDARD_BUFFER_UNDER_SEGMENTED_CONTROL;
extern CGFloat const CT_STANDARD_CELL_BIG_SPACING;
extern CGFloat const CT_STANDARD_RELATED_LINK_HEADER_FOOTER_HEIGHT;

@interface CTMVMStyler : NSObject

// Style guidelines:

// StandardTextField : Should use this style for all text fields.

// StandardTitle : Should use this font for any of the standard titles that are part of the screen. Also used above most text fields. Very common size.
// StandardBoldTitle : Should use this font for any of the standard titles that are part of the screen that are bold.
// StandardMediumTitle : Rarely used. When there is a title that should be the standard message size.
// StandardSmallTitle : Small standard titles. Used for the smallest title style strings in the application.
// StandardTinyTitle : The tiniest title that we display to the screen.

// StandardMessage : Should use this font for any of the standard message strings that are part of the string. This is the most common style.
// StandardBoldMessage : Should use this font for any of the standard bold message strings that are part of the string.
// StandardSmallMessage : Should use this font for any of the small messages that are shown on the screen.
// StandardSmallBoldMessage : Should use this font for any of the small bold messages that are shown on the screen.
// StandardTinyMessage : The tiniest messages that we display to the screen.

// TableTitle : The title size for tables, such as the hamburger menu or related links.
// BoldTableTitle : The bold title size for tables, such as the hamburger menu or related links.

// StandardSegmentedControl : The style for all segmented controls in the application.

// LinkButton : The style for all of the blue link buttons.

// UnderlinedLinkButton : The style for all of the underlined link buttons. Like the privacy policy.

// RoundedButtons : The font for the primary red buttons (and secondary gray).


//-------------------------------------------------
// Returns the fonts for these styles

+ (UIFont *)fontForStandardTextField;

+ (UIFont *)fontForStandardTitleLabel;
+ (UIFont *)fontForStandardBoldTitleLabel;
+ (UIFont *)fontForStandardMediumTitleLabel;
+ (UIFont *)fontForStandardSmallTitleLabel;
+ (UIFont *)fontForStandardTinyTitleLabel;

+ (UIFont *)fontForStandardMessageLabel;
+ (UIFont *)fontForStandardBoldMessageLabel;

// Added to align the font size for lower funnel
+ (UIFont *)fontForStandardBitSmallMessageLabel;

+ (UIFont *)fontForStandardSmallMessageLabel;
+ (UIFont *)fontForStandardSmallBoldMessageLabel;
+ (UIFont *)fontForStandardTinyMessageLabel;
+ (UIFont *)fontForStandardTinyBoldMessageLabel;
+ (UIFont *)fontForStandardTinyBoldLabel;
+ (UIFont *)fontForTableTitleLabel;
+ (UIFont *)fontForBoldTableTitleLabel;

+ (UIFont *)fontForRoundedButtons;

+ (UIFont *)fontForStandardItalicMessageLabel;
+ (UIFont *)fontForStandardItalicBoldMessageLabel;
+ (UIFont *)fontForStandardItalicSmallMessageLabel;
+ (UIFont *)fontForStandardItalicSmallBoldMessageLabel;
+ (UIFont *)fontForStandardItalicTinyMessageLabel;

//-------------------------------------------------
// Applies the styles to the passed in objects.

// TextView that doesn't scroll or edit, mainly for special features like link that labels don't support
+ (void)styleStaticTextView:(UITextView *)textView withAttributedString:(NSAttributedString *)string;

+ (void)styleStandardTextField:(UITextField *)textField;

+ (void)styleStandardTitleLabel:(UILabel *)label;
+ (void)styleStandardBoldTitleLabel:(UILabel *)label;
+ (void)styleStandardMediumTitleLabel:(UILabel *)label;
+ (void)styleStandardSmallTitleLabel:(UILabel *)label;
+ (void)styleStandardTinyTitleLabel:(UILabel *)label;

+ (void)styleStandardMessageLabel:(UILabel *)label;
+ (void)styleStandardBoldMessageLabel:(UILabel *)label;
+ (void)styleStandardSmallMessageLabel:(UILabel *)label;
+ (void)styleStandardSmallBoldMessageLabel:(UILabel *)label;
+ (void)styleStandardTinyMessageLabel:(UILabel *)label;

+ (void)styleTableTitleLabel:(UILabel *)label;
+ (void)styleBoldTableTitleLabel:(UILabel *)label;

+ (void)styleStandardSegmentedControl:(UISegmentedControl *)segmentedControl;

+ (void)styleStandardSeparatorView:(UIView *)view;

// rounded corners with lightgray border and background
+ (void)styleStandardRoundedContainer:(UIView *)view;

+ (void)styleStandardItalicMessageLabel:(UILabel *)label;
+ (void)styleStandardItalicBoldMessageLabel:(UILabel *)label;
+ (void)styleStandardItalicSmallMessageLabel:(UILabel *)label;
+ (void)styleStandardItalicSmallBoldMessageLabel:(UILabel *)label;
+ (void)styleStandardItalicTinyMessageLabel:(UILabel *)label;

//-------------------------------------------------
// Returns the strings attributed with these styles.

// Returns the string attributed with styles and the passed in font and color and kern.
+ (NSAttributedString *)styleGetAttributedString:(NSString *)string font:(UIFont *)font color:(UIColor *)color kern:(NSNumber *)kern;

+ (NSAttributedString *)styleGetAttributedStringForStandardTitleLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardBoldTitleLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardMediumTitleLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardSmallTitleLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardTinyTitleLabel:(NSString *)string;

+ (NSAttributedString *)styleGetAttributedStringForStandardMessageLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardBoldMessageLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardSmallMessageLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardSmallBoldMessageLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardTinyMessageLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardTinyBoldMessageLabel:(NSString *)string;

+ (NSAttributedString *)styleGetAttributedStringForTableTitleLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForBoldTableTitleLabel:(NSString *)string;

+ (NSAttributedString *)styleGetAttributedStringForLinkButtonLabel:(NSString *)string;

+ (NSAttributedString *)styleGetAttributedStringForUnderlinedLinkButtonLabel:(NSString *)string;

// Style title text with small bold front and standard small font for body
+ (NSAttributedString *)styleGetAttributedStringWithSmallTitle:(NSString *)titleString body:(NSString *)bodyString;

// Get Attributed Link Text that Sets Link Property
+ (NSAttributedString *)styleGetAttributedLinkString:(NSString *)string withLink:(NSString *)link;
+ (NSAttributedString *)styleGetAttributedButtonLinkString:(NSString *)string  withLink:(NSString *)link;

+ (NSAttributedString *)styleGetAttributedStringForStandardItalicMessageLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardItalicBoldMessageLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardItalicSmallMessageLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardItalicSmallBoldMessageLabel:(NSString *)string;
+ (NSAttributedString *)styleGetAttributedStringForStandardItalicTinyMessageLabel:(NSString *)string;

//-------------------------------------------------
// Sets the text with strings attributed with these styles.

+ (void)styleSetTextWithStandardTitleLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardBoldTitleLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardMediumTitleLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardSmallTitleLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardTinyTitleLabel:(UILabel *)label text:(NSString *)text;

+ (void)styleSetTextWithStandardMessageLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardBoldMessageLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardSmallMessageLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardSmallBoldMessageLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardTinyMessageLabel:(UILabel *)label text:(NSString *)text;

+ (void)styleSetTextWithTableTitleLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithBoldTableTitleLabel:(UILabel *)label text:(NSString *)text;

+ (void)styleSetTextWithLinkButton:(UIButton *)button text:(NSString *)text;
+ (void)styleSetTextButton:(UIButton *)button text:(NSString *)text;
+ (void)styleSetTextWithUnderlinedLinkButton:(UIButton *)button text:(NSString *)text;

+ (void)styleSetTextWithStandardItalicMessageLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardItalicBoldMessageLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardItalicSmallMessageLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardItalicSmallBoldMessageLabel:(UILabel *)label text:(NSString *)text;
+ (void)styleSetTextWithStandardItalicTinyMessageLabel:(UILabel *)label text:(NSString *)text;

//-------------------------------------------------
// Gets the kerning for certain sizes.
+ (NSNumber *)kernForStandardTitleSizeFont;
+ (NSNumber *)kernForStandardMessageSizeFont;
+ (NSNumber *)kernForSmallSizeFont;
+ (NSNumber *)kernForTinySizeFont;

@end
