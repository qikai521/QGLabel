//
//  NSMutableAttributedString+Attribute.m
//  QGLabel
//
//  Created by qikai on 16/12/6.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "NSMutableAttributedString+Attribute.h"
#import "QGLabelLink.h"
static CGFloat klineSpacing = 3.f;

static CGFloat kParagraphSpacing = 5.f;

@implementation NSMutableAttributedString (Attribute)
/**
 * 设置字体大小
 */
- (void)setFont:(UIFont *)font
{
    [self setFont:font range:NSMakeRange(0, self.string.length)];
}

- (void)setFont:(UIFont *)font range:(NSRange)range
{
    // 移除以前的字体大小
    [self removeAttribute:NSFontAttributeName range:range];
    // 设置字体颜色
    [self addAttribute:NSFontAttributeName value:font range:range];
}

- (void)setFont:(UIFont *)font links:(NSArray *)links
{
    for (QGLabelLink *linkData in links) {
        // 设置字体
        [self setFont:font range:linkData.range];
    }
}

-(void)setTextColor:(UIColor *)textColor{
    [self setTextColor:textColor range:NSMakeRange(0, self.length)];
}

-(void)setTextColor:(UIColor *)textColor links:(NSArray *)links{
    for (QGLabelLink *linkData in links) {
        [self setTextColor:textColor range:linkData.range];
    }
}

-(void)setTextColor:(UIColor *)textColor range:(NSRange)range{
    [self removeAttribute:NSForegroundColorAttributeName range:range];
    [self addAttribute:NSForegroundColorAttributeName value:textColor range:range];
}


+ (NSAttributedString *)attributedString:(NSString *)string
                               textColor:(UIColor *)textColor
                                    font:(UIFont *)font
{
    // 设置段落样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = klineSpacing;
    paragraphStyle.paragraphSpacing = kParagraphSpacing;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByCharWrapping;
    
    // 设置文本属性字典
    NSDictionary *attributes = @{
                                 NSFontAttributeName : font,
                                 NSForegroundColorAttributeName : textColor,
                                 NSParagraphStyleAttributeName : paragraphStyle
                                 };
    // 初始化可变字符串
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    
    return attString;
}


@end
