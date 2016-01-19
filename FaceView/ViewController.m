//
//  ViewController.m
//  FaceView
//
//  Created by Mac on 16/1/12.
//  Copyright © 2016年 耿金鹏. All rights reserved.
//

#import "ViewController.h"
#import "FaceView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    FaceView *view = [[FaceView alloc]initWithBlock:^(NSString *name) {
        
        NSLog(@"name %@",name);
    }];
    
    [self.view addSubview:view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
