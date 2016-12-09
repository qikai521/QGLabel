//
//  QGLabel+Util.m
//  QGLabel
//
//  Created by qikai on 16/12/7.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "QGLabel+Util.h"
#import "UIView+frameAdjust.h"
#import "NSMutableAttributedString+Frame.h"
#import "QGLabelLink.h"
#import "QGLabelImage.h"
@implementation QGLabel (Util)
@dynamic frameRef;
@dynamic linkArr;
@dynamic imageArr;

- (QGLabelLink *)touchLinkInPosition:(CGPoint)position
{
    if (!self.linkArr || !self.linkArr.count) return nil;
    CFIndex index = [self touchPosition:position];
        if (index == -1) return nil;
    
    return [self linkAtIndex:index];
}

-(QGLabelImage *)touchImageInPosition:(CGPoint )position{
    
    CFIndex index = [self touchPosition:position];
    if (index == -1) return nil;
    
    // 3.判断index在哪个图片上
    // 3.1准备谓词查询语句
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"position == %@", @(index)];
    NSArray *resultArr = [self.imageArr filteredArrayUsingPredicate:predicate];
    // 3.2获取符合条件的对象
    QGLabelImage *imageData = [resultArr firstObject];
    return imageData;

}



//获取点击位置设置成字符串的偏移量
-(CFIndex )touchPosition:(CGPoint )position{
    CFArrayRef lines = CTFrameGetLines(self.frameRef);
    //coreText -- 需要翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    if (lines == nil) {
        return -1;
    }
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);
    //遍历所有的lines 每次处理一个line 就会对应不同的偏移值
    CFIndex index = -1;
    for (int i = 0 ; i < lineCount; i++) {
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, i);
        CGRect lineRect = CTLineGetTypographicBoundsAsRect(lineRef, lineOrigins[i]);
        CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
        if (CGRectContainsPoint(rect, position)) {
            CGPoint relativePoint = CGPointMake(position.x - CGRectGetMinX(rect),
                                                position.y - CGRectGetMinY(rect));
            index = CTLineGetStringIndexForPosition(lineRef, relativePoint);
        }
    }
    return index;
}

/**
 * 返回被选中的链接所对应的数据模型
 * 如果没选中SXTAttributedLink为nil
 */
- (QGLabelLink *)linkAtIndex:(CFIndex)index
{
    QGLabelLink *link = nil;
    for (QGLabelLink *linkdd in self.linkArr) {
        // 如果index在data.range中，这证明点中链接
        if (NSLocationInRange(index, linkdd.range)) {
            link = linkdd;
            break;
        }
    }
    return link;
}



@end
