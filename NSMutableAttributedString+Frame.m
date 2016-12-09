//
//  NSMutableAttributedString+Frame.m
//  QGLabel
//
//  Created by qikai on 16/12/6.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "NSMutableAttributedString+Frame.h"

@implementation NSMutableAttributedString (Frame)

NSRange NSRangeFromCFRange(CFRange range){
    return NSMakeRange(range.location, range.length);
}
// 判断 lineRef 的range范围内是否有超链接
BOOL CTLineContainCharacterFromStringRange(CTLineRef lineRef,NSRange range){
    CFRange lineCRange = CTLineGetStringRange(lineRef);
    NSRange lineNRange = NSRangeFromCFRange(lineCRange);
    NSRange containRange = NSIntersectionRange(lineNRange, range);
    return containRange.length > 0 ?0:1;
}

BOOL CTRunContainCharacterFromStringRange(CTRunRef runRef,NSRange range){
    CFRange runRange = CTRunGetStringRange(runRef);
    NSRange runNRange = NSRangeFromCFRange(runRange);
    NSRange containRange = NSIntersectionRange(runNRange, range);
    return containRange.length > 0 ? 0:1;
}
//获取中点linker 的rect
CGRect CTLineGetTypeGraphicBoundsForLinkRect(CTLineRef lineRef,NSRange range ,CGPoint lineOrigin){
    // 0.link的rect
    CGRect highlightRect = CGRectZero;
    
    // 1.判断linkRange是否在当前行的runRef中
    // 1.1获取runRef所在的数组
    CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
    // 1.2获取runRef的个数
    CFIndex runCount = CFArrayGetCount(runs);
    // 1.3循环遍历当前行的runRef，确定link的位置
    for (CFIndex idx = 0; idx < runCount; idx ++) {
        // 1.3.1获取对应位置的ranRef
        CTRunRef runRef = CFArrayGetValueAtIndex(runs, idx);
        // 1.3.2判断当run(CTRunRef)中是否有包含link
        if (CTRunContainCharacterFromStringRange(runRef, range)) continue;
        CGRect linkRect = CTRunGetTypeGraphicBoundsForRunRect(runRef, lineRef, lineOrigin);
        // 1.3.4把runRef中的rect拼接在一起
        // CGRectUnion-> 返回两个矩形的并集
        highlightRect = CGRectIsEmpty(highlightRect) ? linkRect : CGRectUnion(highlightRect, linkRect);
    }
    
    return highlightRect;
}

CGRect CTLineGetTypographicBoundsAsRect(CTLineRef lineRef, CGPoint lineOrigin)
{
    // 上行高度
    CGFloat ascent;
    // 下行高度
    CGFloat descent;
    // 宽度
    CGFloat width = CTLineGetTypographicBounds(lineRef, &ascent, &descent, NULL);
    // 高度
    CGFloat height = ascent + descent;
    
    return CGRectMake(lineOrigin.x,
                      lineOrigin.y - descent,
                      width,
                      height);
}

CGRect CTRunGetTypeGraphicBoundsForRunRect(CTRunRef runRef,CTLineRef lineRef ,CGPoint lineOrigin){
    CGFloat ascent;
    CGFloat descent;
    CGFloat width = CTRunGetTypographicBounds(runRef, CFRangeMake(0, 0), &ascent, &descent, NULL);
    CGFloat height = ascent + descent;
    CGFloat offsetX = CTLineGetOffsetForStringIndex(lineRef, CTRunGetStringRange(runRef).location, NULL);
    return CGRectMake(lineOrigin.x +offsetX, lineOrigin.y - descent, width, height);
}


CGRect CTRunGetTypographicBoundsForImageRect(CTRunRef runRef, CTLineRef lineRef, CGPoint lineOrigin, QGLabelImage *imageData){
    // 获取对应runRef的rect
    CGRect rect = CTRunGetTypeGraphicBoundsForRunRect(runRef, lineRef, lineOrigin);
    return UIEdgeInsetsInsetRect(rect, imageData.imageInsets);
}

/**
 * 获取frameRef
 */
- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect
{
    // 获取framesetterRef
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    
    // 获取frameRef
    CTFrameRef frameRef = [self prepareFrameRefWithRect:rect framesetterRef:framesetterRef];
    
    // 释放framesetterRef
    CFRelease(framesetterRef);
    
    return frameRef;
}

/**
 * 根据传入的宽高来获取CTFrameRef
 */
- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect
                       framesetterRef:(CTFramesetterRef)framesetterRef
{
    // 创建路径
    CGMutablePathRef path = CGPathCreateMutable();
    // 添加路径
    CGPathAddRect(path, NULL, rect);
    
    // 获取frameRef
    // CFRangeMake(0,0) 表示绘制全部文字
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), path, NULL);
    
    // 释放内存
    CFRelease(path);
    
    return frameRef;
}

/**
 * 根据属性字符串、宽度和展示行数，计算其所占用的size
 */
- (CGSize)sizeWithWidth:(CGFloat)width
          numberOfLines:(NSUInteger)numberOfLines{
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef )self);
    CFRange stringRange;
    if (numberOfLines > 0 && frameSetterRef != nil) {
        CGRect rect = CGRectMake(0, 0, width, MAXFLOAT);
        CTFrameRef frameRef = [self prepareFrameRefWithRect:rect framesetterRef:frameSetterRef];
        CFArrayRef lines = CTFrameGetLines(frameRef);
        if (lines != nil && CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleIndex = MIN(numberOfLines, CFArrayGetCount(lines));
            
            CTLineRef lastVisibleLineRef = CFArrayGetValueAtIndex(lines, lastVisibleIndex - 1);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLineRef);
            
            // 获取最后显示一行文字在字符串中的位置
            stringRange = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
            
        }
    }
    
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, 0), NULL, CGSizeMake(width, MAXFLOAT), NULL);
    CFRelease(frameSetterRef);
    return size;
}







@end
