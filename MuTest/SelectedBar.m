//
//  SelectedBar.m
//  MuTest
//
//  Created by hs on 2017/7/26.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import "SelectedBar.h"

@interface SelectedBar ()

@property (nonatomic, copy) SelectedBarBlock  selectBarBlock;

@end

@implementation SelectedBar

- (instancetype)initWithFrame:(CGRect)frame callBack:(SelectedBarBlock)selectBarBlock
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = MUColor(250, 250, 250);
        
        UIButton *B = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
        B.centerX = ScreenWidth / 4;
        [B setTitle:@"B" forState:UIControlStateNormal];
        [B setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [B addTarget:self action:@selector(bord:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:B];
        
        UIButton *T = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
        T.centerX = ScreenWidth / 2;
        [T setTitle:@"T" forState:UIControlStateNormal];
        [T setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [T addTarget:self action:@selector(italic:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:T];
        
        UIButton *link = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
        link.centerX = ScreenWidth * 3 / 4;
        [link setTitle:@"link" forState:UIControlStateNormal];
        [link setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [link addTarget:self action:@selector(link:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:link];
        //增加监听，当键盘出现或改变时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
        //增加监听，当键退出时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification
                                                   object:nil];
        self.selectBarBlock = selectBarBlock;
    }
    return self;
}

- (void)bord:(UIButton *)btn
{
    self.selectBarBlock(0, btn.selected);
}

- (void)italic:(UIButton *)btn
{
    self.selectBarBlock(1, btn.selected);
}

- (void)link:(UIButton *)btn
{
    self.selectBarBlock(2, btn.selected);
}


//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    self.bottom = ScreenHeight - height;
    
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    self.bottom = ScreenHeight;
    
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
