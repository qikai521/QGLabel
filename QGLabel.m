//
//  QGLabel.m
//  QGLabel
//
//  Created by qikai on 16/12/6.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "QGLabel.h"
#import "NSMutableAttributedString+Link.h"
#import "NSMutableAttributedString+Frame.h"
#import "NSMutableAttributedString+Image.h"
#import "NSMutableAttributedString+Attribute.h"
#import "QGLabel+Util.h"
#import "QGLabel+Draw.h"

@interface QGLabel ()

@property (nonatomic ,copy)NSString *array;
@property (nonatomic ,strong) NSMutableAttributedString *attributeString;
@property (nonatomic ,strong) NSMutableArray *linkArr;
@property (nonatomic ,strong )NSMutableArray *imageArr;
@property (nonatomic ,assign) CTFrameRef frameRef;
@property (nonatomic ,strong) QGLabelLink *selectedLink;
@property (nonatomic ,strong) QGLabelImage *selectedImage;


@end

@implementation QGLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initProperty];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initProperty];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperty];
    }
    return self;
}

-(void)initProperty{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor grayColor];
    // 设置字体大小
    self.font = [UIFont systemFontOfSize:16];
    // 设置超文本字体大小
    self.linkFont = [UIFont systemFontOfSize:16];
    // 设置字体颜色
    self.textColor = [UIColor blackColor];
    // 设置超文本字体颜色
    self.linkColor = [UIColor blueColor];
    // 设置超文本选中背景颜色
    self.hightLightColor = [UIColor blueColor];
    // 初始化属性字符串
    self.attributeString = [[NSMutableAttributedString alloc] init];
    // 初始化存放link数据模型的数组
    self.linkArr = [NSMutableArray array];
    // 初始化存放图片数据模型的数组
    self.imageArr = [NSMutableArray array];
}

-(void)setText:(NSString *)text{
    NSAttributedString *str = [NSMutableAttributedString attributedString:text textColor:self.textColor font:self.font];
    [self setAttributedText:str];
}

- (void)setAttributedText:(NSAttributedString *)attributedText{
    self.attributeString = [attributedText mutableCopy];
    self.imageArr = [[self.attributeString setImageWithImageSize:self.imageSize font:self.font] mutableCopy];
    self.linkArr = [[self.attributeString setLinkWithLinkColor:self.linkColor linkFont:self.font] mutableCopy];
    [self setNeedsDisplay];
}

#pragma mark -- addCustomLink
-(void)addCustomLink:(NSString *)link{
    [self addCustomLink:link linkColor:self.linkColor linkFont:self.linkFont];
}

-(void)addCustomLink:(NSString *)link linkColor:(UIColor *)linkColor linkFont:(UIFont *)linkFont{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text CONTAINS %@", link];
    //查找是否linkArr中已经有了text=link的对象
    NSArray *resultArr = [self.linkArr filteredArrayUsingPredicate:predicate];
    if (resultArr.count) return;
    NSArray *linkArr = [self.attributeString setCustomLink:link linkColor:self.linkColor linkFont:self.linkFont];
    [self.linkArr addObjectsFromArray:linkArr];
    [self setNeedsDisplay];
}


-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, rect.size.height), 1.0f, -1);
    CGContextConcatCTM(context, transform);
    
    self.frameRef = [self.attributeString prepareFrameRefWithRect:rect];
    [self drawHighLightColor];
    [self frameLineDraw];
    [self drawImages];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [[touches.allObjects lastObject] locationInView:self];
    QGLabelLink *link = [self touchLinkInPosition:point];
    if (link) {
        self.selectedLink = link;
        [self setNeedsDisplay];
        return;
    }
    
    QGLabelImage *image = [self touchImageInPosition:point];
    if (image) {
        self.selectedImage = image;
    }
    
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    // 0.获取手指点中的坐标
    CGPoint position = [[touches anyObject] locationInView:self];
    
    // 1.判断开始触碰的时候是否选中超文本
    if (self.selectedLink) {
        // 1.1获取当前手指选中的超文本
        QGLabelLink *selectedLink = [self touchLinkInPosition:position];
        // 1.2如果当前选中的超文本和触碰开始时选中的超文本不一致
        // -> 取消当前选中
        if (selectedLink != self.selectedLink) {
            // 1.2.1取消当前选中
            self.selectedLink = nil;
            // 1.2.2刷新
            [self setNeedsDisplay];
        }
    }
    
    // 2.判断开始触碰的时候是否选图片
    if (self.selectedImage) {
        // 1.1获取当前手指选中的图片
        QGLabelImage *selectedImage = [self touchImageInPosition:position];
        // 1.2.如果当前选中的图片和触碰开始时选中的图片不一致
        // -> 取消当前选中
        if (selectedImage != self.selectedImage) {
            // 4.1取消当前选中
            self.selectedImage = nil;
        }
    }
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (touches.allObjects.count == 1) {
        //判断当前只有一个手指的时候
        if (self.selectedLink) {
            if (self.delegate) {
                [self.delegate attributedLabel:self selectedLink:self.selectedLink];
            }
            self.selectedLink = nil;
            [self setNeedsDisplay];
        }
        
        if (self.selectedImage) {
            if (self.delegate) {
                [self.delegate attributedLabel:self selectedImage:self.selectedImage];
            }
            self.selectedImage = nil;
            [self setNeedsDisplay];
        }
        
    }
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    _linkFont = font;
    
    // 设置属性字体
    [self.attributeString setFont:font];
    // 刷新
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    _linkColor = textColor;
    
    // 设置颜色
    [self.attributeString setTextColor:textColor];
    // 刷新
    [self setNeedsDisplay];
}

- (void)setLinkFont:(UIFont *)linkFont
{
    _linkFont = linkFont;
    
    // 设置超文本字体
    [self.attributeString setFont:linkFont links:self.linkArr];
}

- (void)setLinkColor:(UIColor *)linkColor
{
    _linkColor = linkColor;
    
    // 设置超文本颜色
    [self.attributeString setTextColor:linkColor links:self.linkArr];
}

/**
 * 重写frameRef的setter方法
 * 此处需要我们手动管理内存
 */
- (void)setFrameRef:(CTFrameRef)frameRef
{
    if (_frameRef != frameRef) {
        if (_frameRef != nil) {
            CFRelease(_frameRef);
        }
        CFRetain(frameRef);
        _frameRef = frameRef;
    }
}

-(void)setImageSize:(CGSize)imageSize{
    if (!CGSizeEqualToSize(_imageSize, imageSize)) {
        if (self.imageArr.count > 0) {
            for (QGLabelImage *labelImage in self.imageArr) {
                labelImage.imageSize = imageSize;
            }
        }
    }
}

/**
 * 手动释放_frameRef内存
 */
- (void)dealloc
{
    if (_frameRef != nil) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
}


@end
