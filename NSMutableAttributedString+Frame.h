//
//  NSMutableAttributedString+Frame.h
//  QGLabel
//
//  Created by qikai on 16/12/6.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "QGLabelImage.h"
@interface NSMutableAttributedString (Frame)
//获取line中的是否包含超文本链接
BOOL CTLineContainCharacterFromStringRange(CTLineRef lineRef,NSRange range);
//获取run中是否包含超文本链接
BOOL CTRunContainCharacterFromStringRange(CTRunRef runRef,NSRange range);

//获取点中link 的rect
CGRect CTLineGetTypeGraphicBoundsForLinkRect(CTLineRef lineRef,NSRange range ,CGPoint lineOrigin);

//获取每一行的rect
CGRect CTLineGetTypographicBoundsAsRect(CTLineRef lineRef, CGPoint lineOrigin);

//获取对应run的  的rect
CGRect CTRunGetTypeGraphicBoundsForRunRect(CTRunRef runRef,CTLineRef lineRef ,CGPoint lineOrigin);
/**
 * 获取图片的rect
 */
CGRect CTRunGetTypographicBoundsForImageRect(CTRunRef runRef, CTLineRef lineRef, CGPoint lineOrigin, QGLabelImage *imageData);

//获取frameRef
- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect;


/**
 * 根据属性字符串、宽度和展示行数，计算其所占用的size
 */
- (CGSize)sizeWithWidth:(CGFloat)width
          numberOfLines:(NSUInteger)numberOfLines;


@end
