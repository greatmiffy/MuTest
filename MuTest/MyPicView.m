//
//  MyPicView.m
//  MuTest
//
//  Created by hs on 2017/7/25.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import "MyPicView.h"

@interface MyPicView ()

@property (nonatomic, strong) UIImageView *picture;
@property (nonatomic, strong) UILabel *tagLabel;

@property (nonatomic, strong) UIButton *notesBtn;
@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation MyPicView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.picture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.picture.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_picture];
        
        self.notesBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 87, 15, 30, 30)];
        [_notesBtn setImage:[UIImage imageNamed:@"btn_mark"] forState:UIControlStateNormal];
        [_notesBtn addTarget:self action:@selector(notesBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _notesBtn.hidden = YES;
        [self addSubview:_notesBtn];
        
        self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(_notesBtn.right + 12, 15, 30, 30)];
        [_deleteBtn setImage:[UIImage imageNamed:@"btn_delete-1"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _deleteBtn.hidden = YES;
        _notesBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
        _deleteBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [self addSubview:_deleteBtn];
        
        // 长按手势
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewLongPressGesture:)];
        [self addGestureRecognizer:longGesture];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapGesture:)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}


- (void)setContentImage:(UIImage *)image
{
    [_picture setImage:image];
}

#pragma 长按手势
- (void)viewLongPressGesture:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
            //移动前
        case UIGestureRecognizerStateBegan:
            if ([self.delegateF respondsToSelector:@selector(beginMoveAction:)]) {
                
                [self.delegateF beginMoveAction:self.tag];
            }
            break;
            //移动中
        case UIGestureRecognizerStateChanged:
            
            if ([self.delegateF respondsToSelector:@selector(moveViewAction:gesture:)]) {
                [self.delegateF moveViewAction:self.tag gesture:gesture];
            }
            break;
            //移动后
        case UIGestureRecognizerStateEnded:
            
            if ([self.delegateF respondsToSelector:@selector(endMoveViewAction:)]) {
                [self.delegateF endMoveViewAction:self.tag];
            }
            break;
        default:
            break;
    }
}

- (void)viewTapGesture:(UITapGestureRecognizer *)gesture
{
    self.isSelected = !self.isSelected;
    if ([_delegate respondsToSelector:@selector(didTapView:)]) {
        [_delegate didTapView:self];
    }
    
    [self didTapView];
//    _notesBtn.hidden = !self.isSelected;
//    _deleteBtn.hidden = !self.isSelected;
}

- (void)didTapView
{
    if (self.isSelected) {
        _notesBtn.hidden = !self.isSelected;
        _deleteBtn.hidden = !self.isSelected;
        [UIView animateWithDuration:0.25f animations:^{
            _notesBtn.transform = CGAffineTransformMakeScale(1, 1);
            _deleteBtn.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            
        }];
    }else
    {
        [UIView animateWithDuration:0.25f animations:^{
            _notesBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
            _deleteBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
        } completion:^(BOOL finished) {
            _notesBtn.hidden = YES;
            _deleteBtn.hidden = YES;
        }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%@",gestureRecognizer);
    return YES;
}

- (void)notesBtnClick:(id)sender
{
    
    
}

- (void)deleteBtnClick:(id)sender
{
    if ([_delegate respondsToSelector:@selector(deletePicture:)]) {
        [_delegate deletePicture:self];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
