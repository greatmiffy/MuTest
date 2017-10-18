//
//  BottomBar.m
//  MuTest
//
//  Created by hs on 2017/7/13.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import "BottomBar.h"

@interface BottomBar ()

@property (nonatomic, copy) BottomBarBlock bottomBlock;

@end

@implementation BottomBar

- (instancetype)initWithFrame:(CGRect)frame block:(BottomBarBlock)bottomBlock
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = MUColor(250, 250, 250);
        
        UIButton *img = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 40, 20)];
        [self addSubview:img];
        img.backgroundColor = [UIColor grayColor];
        [img addTarget:self action:@selector(imgClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(60, 10, 40, 20)];
        [self addSubview:b];
        [b setTitle:@"B" forState:UIControlStateNormal];
        [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(bClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *yinyong = [[UIButton alloc] initWithFrame:CGRectMake(120, 10, 40, 20)];
        [self addSubview:yinyong];
        [yinyong setTitle:@"\"\"" forState:UIControlStateNormal];
        [yinyong setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [yinyong addTarget:self action:@selector(yinyongClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *liebiao = [[UIButton alloc] initWithFrame:CGRectMake(160, 10, 40, 20)];
        [self addSubview:liebiao];
        liebiao.tag = 33;
        [liebiao setTitle:@"list" forState:UIControlStateNormal];
        [liebiao setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [liebiao addTarget:self action:@selector(liebiaoClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *keyDown = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 30, 10, 30, 20)];
        [self addSubview:keyDown];
        [keyDown setTitle:@"down" forState:UIControlStateNormal];
        keyDown.titleLabel.font = [UIFont systemFontOfSize:14];
        [keyDown setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [keyDown addTarget:self action:@selector(downClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //增加监听，当键盘出现或改变时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
        //增加监听，当键退出时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        self.bottomBlock = bottomBlock;
        @"newMap";
        
    }
    return self;
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

- (void)imgClick:(UIButton *)btn
{
    
    self.bottomBlock(0, btn.selected);
}
- (void)bClick:(UIButton *)btn
{
    self.bottomBlock(1, btn.selected);
}
- (void)yinyongClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    self.bottomBlock(2, btn.selected);
}

- (void)liebiaoClick:(UIButton *)btn
{
    if (btn.tag != 35) {
        btn.tag += 1;
    }else
    {
        btn.tag = 33;
    }
    self.bottomBlock(3, btn.tag - 33);
}

- (void)downClick:(UIButton *)btn
{
    [self.superview endEditing:YES];
}

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
