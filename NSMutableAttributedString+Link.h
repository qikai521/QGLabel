//
//  NSMutableAttributedString+Link.h
//  QGLabel
//
//  Created by qikai on 16/12/7.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSMutableAttributedString (Link)

/**
 * 设置link的字体和颜色
 */
- (NSArray *)setLinkWithLinkColor:(UIColor *)linkColor
                         linkFont:(UIFont *)linkFont;

/**
 * 添加自定义链接
 */
- (NSArray *)setCustomLink:(NSString *)link
                 linkColor:(UIColor *)linkColor
                  linkFont:(UIFont *)linkFont;

@end
