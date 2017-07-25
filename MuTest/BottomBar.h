//
//  BottomBar.h
//  MuTest
//
//  Created by hs on 2017/7/13.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  void(^BottomBarBlock)(NSInteger index, NSInteger state);

@interface BottomBar : UIView

- (instancetype)initWithFrame:(CGRect)frame block:(BottomBarBlock)bottomBlock;

@end
