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
    NSArray *linkArr = [self.attributeString setLinkWithLinkColor:self.linkColor linkFont:self.linkFont];
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

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

@end
