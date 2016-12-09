//
//  ViewController.m
//  QGLabel
//
//  Created by qikai on 16/12/6.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "ViewController.h"
#import "QGLabel.h"

@interface ViewController ()

@property (nonatomic ,strong )QGLabel *showLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _showLabel = [[QGLabel alloc] initWithFrame:CGRectMake(10, 100, 300, 400)];
    _showLabel.text =@"今日下午，楚天都市报记者@大欢 来到解放公园内的征婚角，悬挂着上百张征婚启事，有很多市民或是帮子女，或是帮朋友找寻合适的对象(找对象上淘宝：www.taobao.com [/haha.gif])。记者找到了严先生觉得很奇葩的征婚[/haqian.gif]启事，在启事择偶要求一栏，征婚者胡先生要求女方“能生男孩”[/haha]。并且，在启事的最后，@胡先生还说明“#本人爸爸是局长#”";
    _showLabel.imageSize = CGSizeMake(40, 40);
    _showLabel.hightLightColor = [UIColor yellowColor];
    
    [self.view addSubview:_showLabel];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
