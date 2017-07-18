//
//  ViewController.m
//  MuTest
//
//  Created by hs on 2017/7/13.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "MyTextView.h"
#import "BottomBar.h"
#import <CoreText/CoreText.h>


@interface ViewController ()<UITextViewDelegate, MyTextViewDelegate>

@property (nonatomic, strong) MyTextView *contentTextView;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) NSMutableArray *objList;
@property (nonatomic, strong) MyTextView *currentView;
@property (nonatomic, strong) BottomBar *bottomBar;

@property (nonatomic, assign) CGPoint rects;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, ScreenHeight - 50)];
    _scroll.userInteractionEnabled = YES;
    _scroll.contentSize = CGSizeMake(ScreenWidth, _scroll.height);
    [self.view addSubview:_scroll];
    
    self.bottomBar = [[BottomBar alloc] initWithFrame:CGRectMake(0, ScreenHeight - 30, ScreenWidth, 30)block:^(NSInteger index, BOOL selected) {
        if (index == 1) {
            [self bolder];
        }
        if (index == 2) {
            [self yinyong:selected];
        }
        if (index == 3) {
            [self liebiao:selected];
        }
    }];
    [self.view addSubview:_bottomBar];
    
    self.contentTextView = [[MyTextView alloc] initWithFrame:CGRectMake(20, 20, ScreenWidth - 40, 40)];
    _contentTextView.delegate = self;
    _contentTextView.delegateF = self;
    [self.scroll addSubview:_contentTextView];
    _contentTextView.tag = 100;
    self.objList = [NSMutableArray array];
    [_objList addObject:_contentTextView];
    
    
}

// 加粗的位置坐标
NSInteger _loc;
NSInteger _len;
NSString *lastStr;
NSRange lastRange;

#pragma mark - TextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    _loc = textView.selectedRange.location;
    _len = textView.selectedRange.length;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (lastRange.length != 0 || lastRange.location != 0) {
        [(MyTextView *)textView insertParagraphHeader:lastRange];
        lastRange = NSMakeRange(0, 0);
    }
    
    CGFloat fixW = textView.textContainerInset.left + textView.textContainerInset.right;
    CGFloat fixH = textView.textContainerInset.top + textView.textContainerInset.bottom;
    NSAttributedString *s = textView.attributedText ? textView.attributedText : [[NSAttributedString alloc] initWithString:textView.text];
    // 这里减去的8, 是textView的文字内边距
    CGRect rect = [s boundingRectWithSize:CGSizeMake(ScreenWidth - 40 - fixW - 8, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading context:nil];
    textView.height = ceilf( rect.size.height + fixH) > 40 ? ceilf( rect.size.height + fixH) : 40;
    
    [self layoutTextView];
    
    [textView setNeedsDisplay];
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length == 0) {
        if (!textView.attributedText.length && !textView.text.length && textView.tag != 100) {
            [self removeTextView:(MyTextView *)textView];
        }
        for (NSValue *v in [(MyTextView *)textView rangeArray]) {
            NSRange temp = [v rangeValue];
            if (NSLocationInRange(range.location, temp)) {
                NSMutableAttributedString *s =[textView.attributedText mutableCopy];
                [s deleteCharactersInRange:NSMakeRange(temp.location, temp.length - 1)];
                textView.attributedText = s;
                [[(MyTextView *)textView rangeArray] removeObject:v];
                return YES;
            }
        }
    }
    
    // 点击换行创建新的输入框
    if ([(MyTextView *)textView listState] == TextViewListStateNormal) {
        if ([text isEqualToString:@"\n"]) {
            
            [self addTextView:(MyTextView *)textView];
            
            return NO;
        }
    }else{
        
        if (textView.selectedRange.location == [[[(MyTextView *)textView rangeArray] lastObject] rangeValue].location + [[[(MyTextView *)textView rangeArray] lastObject] rangeValue].length && [text isEqualToString:@"\n"]) {
            [(MyTextView *)textView deleteLastParagraph];
//            [self caculateTextHeight:textView];
            [self addTextView:(MyTextView *)textView];
            
            return NO;
        }
        
//        if ([text isEqualToString:@"\n"] && [lastStr isEqualToString:@"\n"]) {
//            
//            [(MyTextView *)textView deleteLastParagraph];
////            [self caculateTextHeight:textView];
//            [self addTextView:(MyTextView *)textView];
//            
//            return NO;
//        }
        if ([text isEqualToString:@"\n"]){
//            [(MyTextView *)textView insertParagraphHeader:range];
            lastStr = text;
            
            lastRange = range;
            return YES;
        }
        lastStr = text;
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.currentView = (MyTextView *)textView;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    
    return YES;
}

- (void)addTextView:(MyTextView *)textView
{
    MyTextView *newT = [[MyTextView alloc] init];
    
    [self.scroll addSubview:newT];
    newT.delegateF = self;
    newT.tag = textView.tag + 1;
    [_objList insertObject:newT atIndex:textView.tag - 99];
    newT.frame = CGRectMake(20, 0, ScreenWidth - 40, 40);
    newT.delegate = self;
    [newT becomeFirstResponder];
    [self layoutTextView];
    
}

- (void)removeTextView:(MyTextView *)textView
{
    [_objList removeObject:textView];
    [textView removeFromSuperview];
    [self layoutTextView];
}

#pragma mark - MyViewDelegate
// 起始手势
- (void)moveViewAction:(NSInteger)tag gesture:(UIGestureRecognizer *)gesture
{
    // 移动的视图
    MyTextView *myV = _objList[tag - 100];
    // 移动前的tag值
    NSInteger fromtag = myV.tag;
    // 手指的新坐标
    CGPoint newPoint = [gesture locationInView:self.scroll];
    // 手指的旧坐标
    if (CGPointEqualToPoint(_rects, CGPointZero))
        _rects = newPoint;
    // 坐标修正值
    CGFloat fixX = newPoint.x - _rects.x;
    CGFloat fixY = newPoint.y - _rects.y;
    // 视图的新位置
    myV.center = CGPointMake(myV.centerX + fixX, myV.centerY + fixY);
    // 更新手指旧坐标
    _rects = newPoint;
    
//    [self.scroll scrollRectToVisible:myV.frame animated:YES];
    // 目的视图的角标
    NSInteger toIndex = [self indexOfPoint:_rects withUiview:myV singArray:_objList];
//    if (toIndex == _objList.count - 1) {
//        return;
//    }
    // 向上拖动
    if (toIndex < fromtag-100 && toIndex >= 0) {
        NSInteger beginIndex = fromtag-100;
        MyTextView *toView = _objList[toIndex];
//        myV.center = toView.center;
//        rects = toView.center;
//        for (NSInteger j = beginIndex; j > toIndex; j--) {
//            MyTextView *singView1 = self.objList[j];
//            MyTextView *singView2 = self.objList[j-1];
//
//            [UIView animateWithDuration:0.5 animations:^{
//                singView2.center = singView1.center;
//                [self layoutTextView];
//            }];
//        }
        // 处理数组
        [_objList removeObject:myV];
        [_objList insertObject:myV atIndex:toIndex];
        [UIView animateWithDuration:0.25 animations:^{
            [self changeTextViewFrame:myV];
        }];
        
    }
    // 向下拖动
    if (toIndex >= fromtag-100 && toIndex < _objList.count) {
        NSInteger beginIndex = fromtag-100;
        MyTextView *toView = self.objList[toIndex];
//        myV.center = toView.center;
//        rects = toView.center;
//        for (NSInteger j = beginIndex; j < toIndex; j++) {
//            MyTextView *singView1 = self.objList[j];
//            MyTextView *singView2 = self.objList[j+1];
//            [_objList removeObject:myV];
//            [_objList insertObject:myV atIndex:toIndex];
//            [UIView animateWithDuration:0.25 animations:^{
////                singView2.center = singView1.center;
//                [self layoutTextView];
//            }];
//        }
        // 处理数组
        [_objList removeObject:myV];
        [_objList insertObject:myV atIndex:toIndex];
        [UIView animateWithDuration:0.25 animations:^{
//            singView2.center = singView1.center;
            [self changeTextViewFrame:myV];
        }];
        
        
    }
    
}

- (NSInteger)indexOfPoint:(CGPoint)point
               withUiview:(UIView *)view
                singArray:(NSMutableArray *)singArray
{
    for (NSInteger i = 0; i < singArray.count; i++) {
        UIView *v = singArray[i];
//        NSLog(@"%f --- %f ---- %zd", point.y, view.y, i);
        if (v != view) {
            if (point.y > v.y && point.y < v.bottom) {
//                NSLog(@"%zd", i);
                return i;
            }
        }
    }
    return -100;
//    for (NSInteger i = 0;i< singArray.count;i++)
//    {
//        UIView *singVi = singArray[i];
//        if (singVi != view)
//        {
//            if (CGRectContainsPoint(singVi.frame, point))
//            {
//                return i;
//            }
//        }
//    }
    return -100;
}

- (void)beginMoveAction:(NSInteger)tag
{
    NSLog(@"begin");
    MyTextView *myV = _objList[tag - 100];
    [self.scroll bringSubviewToFront:myV];
    myV.transform = CGAffineTransformMakeScale(1.1, 1.1);
}



- (void)endMoveViewAction:(NSInteger)tag
{
    NSLog(@"end");
    MyTextView *myV = _objList[tag - 100];
    myV.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:.25f animations:^{
        [self layoutTextView];
    }];
    _rects = CGPointZero;
    
}


- (void)layoutTextView
{
    UIView *last;
    UIView *cur;
    for (int i = 0; i < _objList.count; i++) {
        cur = _objList[i];
        cur.tag = i + 100;
        cur.x = 20;
        if (i == 0) {
            cur.y = 20;
        }
        cur.tag = 100 + i;
        if (last) {
            cur.y = last.bottom + 10;
        }
        last = cur;
    }
    if (cur.bottom > _scroll.contentSize.height) {
        _scroll.contentSize = CGSizeMake(ScreenWidth, cur.bottom);
        _scroll.contentOffset = CGPointMake(0, cur.bottom - _scroll.height);
    }
}

- (void)changeTextViewFrame:(UIView *)currentView
{
    UIView *last;
    UIView *cur;
    for (int i = 0; i < _objList.count; i++) {
        cur = _objList[i];
        cur.tag = i + 100;
        if (cur != currentView) {
            if (i == 0) {
                cur.y = 20;
            }
            if (last) {
                cur.y = last.bottom + 10;
            }

        }else
        {
            NSLog(@"%f",last.bottom);
        }
        last = cur;
    }
    if (cur.bottom > _scroll.contentSize.height) {
        _scroll.contentSize = CGSizeMake(ScreenWidth, cur.bottom);
        _scroll.contentOffset = CGPointMake(0, cur.bottom - _scroll.height);
    }
}

- (void)bolder
{
    NSMutableAttributedString *s = _currentView.attributedText ? [_currentView.attributedText mutableCopy] : [[NSMutableAttributedString alloc] initWithString:_currentView.text];
    if (_len) {
        [s addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(_loc, _len)];
    }else
    {
        [s addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0, s.length)];
    }
    
    _currentView.attributedText = s;
    [self caculateTextHeight:_currentView];
}

- (void)yinyong:(BOOL)selcted
{
    if (selcted) {
        _currentView.quoteBar.hidden = NO;
        _currentView.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15);
    }else
    {
        _currentView.quoteBar.hidden = YES;
        _currentView.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
    }
    [self caculateTextHeight:_currentView];
}


- (void)liebiao:(BOOL)selected
{
    if (!_currentView.listState == TextViewListStateNormal) {
        _currentView.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
        _currentView.listState = TextViewListStateNormal;
    }else
    {
        _currentView.textContainerInset = UIEdgeInsetsMake(8, 5, 8, 5);
        _currentView.listState = TextViewListStateUnorder;
    }
    [_currentView list];
}

#pragma mark - 计算文字高度
- (void)caculateTextHeight:(UITextView *)textView
{
    CGFloat fixW = textView.textContainerInset.left + textView.textContainerInset.right;
    CGFloat fixH = textView.textContainerInset.top + textView.textContainerInset.bottom;
    NSAttributedString *s = textView.attributedText ? textView.attributedText : [[NSAttributedString alloc] initWithString:textView.text];
    CGRect rect = [s boundingRectWithSize:CGSizeMake(ScreenWidth - 40 - fixW - 8, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading context:nil];
    textView.height = ceilf( rect.size.height + fixH) > 40 ? ceilf( rect.size.height + fixH) : 40;
    [self layoutTextView];
    [textView setNeedsDisplay];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.scroll endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end