//
//  QGLabel+Draw.h
//  QGLabel
//
//  Created by qikai on 16/12/8.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "QGLabel.h"
#import "QGLabelLink.h"
#import <CoreText/CoreText.h>

@interface QGLabel (Draw)
@property (nonatomic, strong, readonly) NSMutableAttributedString *attributeString;
@property (nonatomic, assign, readonly) CTFrameRef frameRef;
@property (nonatomic, strong, readonly) QGLabelLink *selectedLink;

-(void)drawImages;
-(void)frameLineDraw;
-(void)drawHighLightColor;

@end
