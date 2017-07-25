//
//  MyPicView.h
//  MuTest
//
//  Created by hs on 2017/7/25.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyTextViewDelegate <NSObject>

- (void)beginMoveAction:(NSInteger)tag;//移动前
- (void)moveViewAction:(NSInteger)tag gesture:(UIGestureRecognizer *)gesture;//移动中
- (void)endMoveViewAction:(NSInteger)tag;//结束移动

@end

@interface MyPicView : UIView
@property (nonatomic, weak) id<MyTextViewDelegate>delegateF;

@end
