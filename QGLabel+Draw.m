//
//  QGLabel+Draw.m
//  QGLabel
//
//  Created by qikai on 16/12/8.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "QGLabel+Draw.h"
#import "NSMutableAttributedString+Frame.h"
#import "UIImageView+Gif.h"
#import "UIView+frameAdjust.h"
static CGFloat kRadius = 2.f;

@implementation QGLabel (Draw)
@dynamic frameRef;
@dynamic attributeString;
@dynamic selectedLink;

- (void)drawHighLightColor{
    if (self.selectedLink && self.frameRef) {
        //获取选中的Link的所在范围
        CFArrayRef lines =  CTFrameGetLines(self.frameRef);
        CFIndex lineCount = CFArrayGetCount(lines);
        CGPoint lineOrigins[lineCount];
        CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);
        for (int i = 0 ; i < lineCount; i++) {
            CTLineRef lineRef = CFArrayGetValueAtIndex(lines, i);
            //判断当前行数是否包含link
            if (CTLineContainCharacterFromStringRange(lineRef,self.selectedLink.range )) continue;
                //进行绘制
                CGRect hightlightRect = CTLineGetTypeGraphicBoundsForLinkRect(lineRef, self.selectedLink.range, lineOrigins[i]);
                if (!CGRectIsEmpty(hightlightRect)) {
                    [self drawBackgroundColorWithRect:hightlightRect];
                }
        }
    }
}

-(void)drawBackgroundColorWithRect:(CGRect)hightRect{
    CGFloat pointX =  hightRect.origin.x;
    CGFloat pointY = hightRect.origin.y;
    CGFloat width = hightRect.size.width;
    CGFloat height = hightRect.size.height;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.hightLightColor.CGColor);
    //上
    CGContextMoveToPoint(ctx, pointX, pointY);
    CGContextAddLineToPoint(ctx, pointX-kRadius, pointY);
    CGContextAddArc(ctx, pointX +width - kRadius, pointY + kRadius, kRadius, -0.5*M_PI, 0.0, 0);
    //右
    CGContextAddLineToPoint(ctx, pointX + width, pointY + height - kRadius);
    CGContextAddArc(ctx, pointX + width -kRadius, pointY + height - kRadius, kRadius, -0.5*M_PI, 0.0, 0);
    //下
    CGContextAddLineToPoint(ctx, pointX+kRadius, pointY + height);
    CGContextAddArc(ctx, pointX + kRadius, pointY + height - kRadius, kRadius, -0.5*M_PI, 0.0, 0);
    
    //左
    CGContextAddLineToPoint(ctx, pointX, pointY-kRadius);
    CGContextAddArc(ctx, pointX + kRadius, kRadius, kRadius, -0.5*M_PI, 0.0, 0);
    
    CGContextFillPath(ctx);
    
}
//绘制图片
-(void)drawImages{
    if (!self.frameRef) return;
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    CFArrayRef lines  = CTFrameGetLines(self.frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    NSUInteger numberOfLines = self.numberOfLines != 0 ? MIN(lineCount, self.numberOfLines) : lineCount;
    
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);
    
    for (int i = 0; i < numberOfLines; i++) {
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, i);
        CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
        CGPoint origin = lineOrigins[i];
        CFIndex runCount = CFArrayGetCount(runs);
        for (int j = 0; j< runCount; j++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary *attribute = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegateRef = (__bridge CTRunDelegateRef)([attribute objectForKey:(NSString *)kCTRunDelegateAttributeName]);
            if (!delegateRef) continue;
            QGLabelImage *imageData = CTRunDelegateGetRefCon(delegateRef);
            CGRect imageFrame = CTRunGetTypographicBoundsForImageRect(run, lineRef, origin, imageData);
            if (imageData.imageType == QGImageType_GIF) {
                UIImageView *imageView = [UIImageView imageViewWithGIFName:imageData.imageName frame:imageFrame];
                imageView.backgroundColor = [UIColor orangeColor];
                //因为当前坐标系是翻转的状态 所以需要翻转过来
                imageView.y = self.height - imageView.height - imageView.frame.origin.y;
                [self addSubview:imageView];
            }else{
                UIImage *image = [UIImage imageNamed:imageData.imageName];
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextDrawImage(context, imageFrame, image.CGImage);
            }
        }
    }
}

//绘制文字
-(void)frameLineDraw{
    if (!self.frameRef) return;
    CFArrayRef lines = CTFrameGetLines(self.frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSInteger numberOfLine =self.numberOfLines != 0? MIN(self.numberOfLines, lineCount) :lineCount;
    for (int i = 0; i < numberOfLine; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        //设置绘制的起始位置
        CGContextSetTextPosition(context, lineOrigins[i].x, lineOrigins[i].y);
        BOOL showDrawLine = YES;
        //处理最后一行
        if (i == numberOfLine -1  && self.numberOfLines != 0) {
            [self drawLastLineWithLineRef:line];
            
            // 3.3.2标记不用完整的去绘制一行文字
            showDrawLine = NO;
        }
        if (showDrawLine) {
            CTLineDraw(line, context);
        }
    }
    
}

- (void)drawLastLineWithLineRef:(CTLineRef)lineRef
{
    // 1.获取当前行在文本中的范围
    CFRange lastLineRange = CTLineGetStringRange(lineRef);
    // 2.比较最后显示行的最后一个文字的长度和文本的总长度
    // -> 最后一个文字的长度 < 文本的总长度
    // -> 用户设置了限制文本长度，单独处理最后一个的最后一个字符即可
    if (lastLineRange.location + lastLineRange.length < (CFIndex)self.attributeString.length) {
        // 2.1获取最后一行的属性字符串
        NSMutableAttributedString *truncationString = [[self.attributeString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
        
        if (lastLineRange.length > 0) {
            // 2.2获取最后一个字符
            unichar lastCharacter = [[truncationString string] characterAtIndex:lastLineRange.length - 1];
            
            // 2.3判断Unicode字符集是否包含lastCharacter
            if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:lastCharacter]) {
                // 2.4.1安全的删除truncationString中最后一个字符
                [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
            }
        }
        
        // 2.5获取截断属性的位置
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
        
        // 2.6获取需要截断的属性
        NSDictionary *tokenAttributes = [self.attributeString attributesAtIndex:truncationAttributePosition effectiveRange:NULL];
        
        //  2.7初始化一个带属性字符串 -> “...”
        static NSString* const kEllipsesCharacter = @"\u2026";
        NSMutableAttributedString *tokenString = [[NSMutableAttributedString alloc] initWithString:kEllipsesCharacter attributes:tokenAttributes];
        
        // 2.8把“...”添加到最后一行尾部
        [truncationString appendAttributedString:tokenString];
        
        // 2.9处理最后一行的lineRef
        CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
        CTLineTruncationType truncationType = kCTLineTruncationEnd;
        
        CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)tokenString);
        
        CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, self.frame.size.width, truncationType, truncationToken);
        
        if (!truncatedLine) {
            truncatedLine = CFRetain(truncationToken);
        }
        CFRelease(truncationLine);
        CFRelease(truncationToken);
        
        // 绘制本行文字
        CGContextRef context = UIGraphicsGetCurrentContext();
        CTLineDraw(truncatedLine, context);
        CFRelease(truncatedLine);
    }
}


@end
