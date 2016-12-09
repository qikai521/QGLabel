//
//  NSMutableAttributedString+Image.m
//  QGLabel
//
//  Created by qikai on 16/12/7.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "NSMutableAttributedString+Image.h"
#import "QGLabelImage.h"
#import "UIImageView+Gif.h"
/**
 * 图片与文字上下左右的间距
 */
#define imageInset UIEdgeInsetsMake(0.f, 1.f, 0.f, 1.f)
/**
 * [/图片名] 的正则表达式
 */
static NSString *kImagePattern = @"\\[.*?\\]";
@implementation NSMutableAttributedString (Image)

/**
 * 获取占位图片的最终大小
 */
static CGSize attributedImageSize(QGLabelImage *imageData)
{
    CGFloat width = imageData.imageSize.width + imageData.imageInsets.left + imageData.imageInsets.right;
    CGFloat height = imageData.imageSize.height+ imageData.imageInsets.top  + imageData.imageInsets.bottom;
    return CGSizeMake(width, height);
}


static CGFloat ascentCallback(void *ref)
{
    QGLabelImage *imageData = (__bridge QGLabelImage *)(ref);
    CGFloat imageHeiht = attributedImageSize(imageData).height;
    
    CGFloat ascent = CTFontGetAscent(imageData.fontRef);
    CGFloat desenct  =CTFontGetAscent(imageData.fontRef);
    
    CGFloat baseHeight = (ascent + desenct)/2.0f - desenct;
    return baseHeight + imageHeiht/2.0f;
}

static CGFloat descentCallBack(void *ref){
    QGLabelImage *imageData = (__bridge QGLabelImage *)(ref);
    CGFloat imageHeight = attributedImageSize(imageData).height;
    
    // 3.获取图片对应占位属性字符串的Ascent和Descent
    CGFloat fontAscent  = CTFontGetAscent(imageData.fontRef);
    CGFloat fontDescent = CTFontGetDescent(imageData.fontRef);
    
    // 4.计算基线->Ascent和Descent分割线
    CGFloat baseLine = (fontAscent + fontDescent) / 2.f - fontDescent;
    
    // 5.获得正确的Ascent
    return imageHeight / 2.f - baseLine;
}

static CGFloat widthCallback(void *ref)
{
    QGLabelImage *imageData = (__bridge QGLabelImage *)(ref);
    CGFloat imageWidth = attributedImageSize(imageData).width;
    return imageWidth;
}

+(NSMutableAttributedString *)getAttributeStringWithImageData:(QGLabelImage *)imageData{
    CTRunDelegateCallbacks callBacks;
    memset(&callBacks, 0, sizeof(CTRunDelegateCallbacks));
    callBacks.version = kCTRunDelegateVersion1;
    callBacks.getAscent = ascentCallback;
    callBacks.getDescent = descentCallBack;
    callBacks.getWidth = widthCallback;
    
    CTRunDelegateRef runDelegateRef = CTRunDelegateCreate(&callBacks, (__bridge void * _Nullable)(imageData));
    //使用空字符 成为占位字符串 比 空格更好
    unichar objectReplacementChar = 0xFFFC;
    NSString *string = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    [str addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id _Nonnull)(runDelegateRef) range:NSMakeRange(0, 1)];
    CFRelease(runDelegateRef);
    return str;
    
}
/**
 * 检查内容中所带的图片，并处理图片相关内容
 * ->返回存放图片对象（QGImage）的数组
 */
- (NSArray *)setImageWithImageSize:(CGSize)imageSize
                              font:(UIFont *)font{
    NSMutableArray *imageDatas = [NSMutableArray array];
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:kImagePattern options:NSRegularExpressionCaseInsensitive error:nil];
    [regex enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSString *resultString = [self.string substringWithRange:result.range];
        QGLabelImage *labelImage = [[QGLabelImage alloc] init];
        NSString *imageName = [[resultString substringFromIndex:2] substringToIndex:resultString.length - 3];
        labelImage.imageName = imageName;
        [imageDatas addObject:labelImage];
    }];
    // 4.遍历图片数组，处理图片相关内容
    // 4.0获取图片所在位置的fontRef
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    for (QGLabelImage *qgImage in imageDatas) {
        NSString *imageName = qgImage.imageName;
        if (![UIImage imageNamed:imageName]) {
            // 4.1.2移除数据
            [imageDatas removeObject:qgImage];
            // 4.1.3退出循环
            continue;
        }
        if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
            //如果传入的size为0 的时候 默认图片的大小为字体的大小
            qgImage.imageSize = CGSizeMake(font.pointSize, font.pointSize);
        }else{
            qgImage.imageSize = imageSize;
        }
        qgImage.fontRef = fontRef;
        qgImage.imageInsets = imageInset;
        qgImage.imageType = [NSString contentTypeForImageName:qgImage.imageName];
        NSMutableAttributedString *rpStr = [NSMutableAttributedString getAttributeStringWithImageData:qgImage];
        NSString *imageRealStr  = [NSString stringWithFormat:@"[/%@]",imageName];
        NSRange range  = [self.string rangeOfString:imageRealStr];
        qgImage.position = range.location;
        [self replaceCharactersInRange:range withAttributedString:rpStr];
    }
    return imageDatas;
}




@end
