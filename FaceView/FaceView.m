//
//  FaceView.m
//  FaceView
//
//  Created by Mac on 16/1/12.
//  Copyright © 2016年 耿金鹏. All rights reserved.
//

#import "FaceView.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width

@implementation FaceView
{
    NSArray *_dataList;
    UIScrollView *_scrollView;
    MyBlock _block;
}

-(instancetype)initWithBlock:(MyBlock)block{

    self = [super initWithFrame:CGRectMake(0, 0, kScreenW, kScreenW/7*4)];
    
    if (self) {
    
        _block = block;
        
        //1.加载数据
        [self loadData];
        
        //加载子控件
        [self creataView];
    }
    return self;
}

//加载数据
-(void)loadData{

    //1、获取文件路径
    NSString *path = [[NSBundle mainBundle]pathForResource:@"emoticons" ofType:@"plist"];

    //解析plist文件
    _dataList = [NSArray arrayWithContentsOfFile:path];
    
}

//加载子控件
-(void)creataView{

    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenW/7*4)];
    
    _scrollView.pagingEnabled = YES;
    
    NSLog(@"_dataList,count is %ld",_dataList.count);
    
    
    //根据数据计算分页的页数
    NSInteger count = _dataList.count/28 +((_dataList.count %28)?1:0);

    //设置scrollView的内容尺寸
    _scrollView.contentSize = CGSizeMake(kScreenW *count, self.bounds.size.height);
    
    [self addSubview:_scrollView];
    
    for (int i = 0; i < count; i ++) {
        
        FaceViewItem *item = [[FaceViewItem alloc]initWithBlock:_block];
        
        item.frame = CGRectMake(kScreenW *i , 0, kScreenW, self.bounds.size.height);
        
        //获取每个子控件对应的数组数据
        NSArray *subArr = [_dataList subarrayWithRange:NSMakeRange(28 *i, (_dataList.count-28*i)>28?28:_dataList.count%28)];
        
        item.dataList = subArr;
        
        [_scrollView addSubview:item];
    }
    
}


@end

#define kSpace (kScreenW-210)/8

@implementation FaceViewItem
{
    UIImageView *_magnifierV;//放大镜视图
    UIImageView *_itemV;
    MyBlock _block;
}
//图片的宽高
CGFloat itemW = 30;
CGFloat itemH = 30;


-(instancetype)initWithBlock:(MyBlock)block{

    self = [super initWithFrame:CGRectMake(0, 0, kScreenW, kScreenW/7*4)];
    
    if (self) {
        
        _block = block;
    }
    return self;
}

-(void)setDataList:(NSArray *)dataList{

    _dataList = dataList;
    
    //让系统调用drawReck方法(刷新视图)
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{

    //绘制背景图
    UIImage *bgImg = [UIImage imageNamed:@"emoticon_keyboard_background"];

    [bgImg drawInRect:self.bounds];

    for (int i = 0; i<_dataList.count; i ++) {
        
        NSString *imgName = [_dataList[i] objectForKey:@"png"];
        
        UIImage *img = [UIImage imageNamed:imgName];
        
        [img drawInRect:[self frameWithIndex:i]];
    }
    

}

//通过下表获取frame
-(CGRect)frameWithIndex:(int)index{

    //获取前方图片个数
    int x = index %7;
    //获取上方图片个数
    int y = index /7;
    
    return CGRectMake(itemW*x + kSpace *(x +1), itemW*y + kSpace *(y +1), itemW, itemW);
}

//通过触摸的点获取下表
-(NSInteger)indexFromPoint:(CGPoint)point{

    //根据x轴坐标计算列
    int x = (point.x -kSpace)/(kSpace + itemW);
    //根据y轴坐标计算行
    int y = (point.y -kSpace)/(kSpace + itemH);

    return x + y*7;
}

//开始触摸
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    //获取触摸的点
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    //根据触摸的点的位置获取下表
    NSInteger index = [self indexFromPoint:point];

    if (index >= _dataList.count) {
        
        return;
    }
    
    if (!_magnifierV) {
        
        //创建放大镜视图
        _magnifierV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 64, 92)];
        
        _magnifierV.image = [UIImage imageNamed:@"emoticon_keyboard_magnifier"];
        
        _magnifierV.hidden = YES;
        
        [self addSubview:_magnifierV];
        
        //放大镜中的图像
        _itemV = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 60, 60)];
        
        [_magnifierV addSubview:_itemV];
    }
    //确定放大镜的位置
    CGRect indexFrame = [self frameWithIndex:(int)index];

    CGFloat centerX = indexFrame.origin.x + indexFrame.size.width/2;
    CGFloat centerY = indexFrame.origin.y + indexFrame.size.height/2 - _magnifierV.frame.size.height/2;
    
    _magnifierV.center = CGPointMake(centerX, centerY);
    
    _magnifierV.hidden = NO;
    
    _itemV.image = [UIImage imageNamed:[_dataList[index] objectForKey:@"png"]];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //移动时关闭scollView的滑动功能
    ((UIScrollView*)self.superview).scrollEnabled = NO;
    
    //获取触摸的点
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    //获取点对应的图片下标
    NSInteger index = [self indexFromPoint:point];
    
    if (index >=_dataList.count) {
        
        return;
    }
    
    //确定放大镜的位置
    CGRect indexFrame = [self frameWithIndex:(int)index];
    
    CGFloat centerX = indexFrame.origin.x + indexFrame.size.width/2;
    CGFloat centerY = indexFrame.origin.y + indexFrame.size.height/2 - _magnifierV.frame.size.height/2;
    
    _magnifierV.center = CGPointMake(centerX, centerY);
    
    //重新设置放大镜中的图片
    _itemV.image = [UIImage imageNamed:[_dataList[index] objectForKey:@"png"]];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //开启scrollview的滑动功能
    ((UIScrollView *)self.superview).scrollEnabled = YES;
    
    //当触摸停止时隐藏放大镜
    _magnifierV.hidden = YES;
    
    //获取触摸的点
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    //获取点对应的图片下标
    NSInteger index = [self indexFromPoint:point];
    
    if (index>=_dataList.count) {
        return;
    }
    
    NSString *name = [_dataList[index] objectForKey:@"chs"];
    
    
    _block(name);
//    NSLog(@"name is:%@",name);
    
}


@end

