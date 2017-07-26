//
//  SelectedBar.h
//  MuTest
//
//  Created by hs on 2017/7/26.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectedBarBlock)(NSInteger index, NSInteger state);

@interface SelectedBar : UIView

- (instancetype)initWithFrame:(CGRect)frame callBack:(SelectedBarBlock)selectBarBlock;

@end
