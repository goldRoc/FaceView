//
//  FaceView.h
//  FaceView
//
//  Created by Mac on 16/1/12.
//  Copyright © 2016年 耿金鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MyBlock)(NSString *name);

@interface FaceView : UIView

-(instancetype)initWithBlock:(MyBlock)block;

@end


@interface FaceViewItem : UIView

@property(nonatomic,retain)NSArray *dataList;

-(instancetype)initWithBlock:(MyBlock)block;

@end