//
//  MyTextView.m
//  MuTest
//
//  Created by hs on 2017/7/13.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import "MyTextView.h"

@interface MyTextView ()

@property (nonatomic, strong) NSAttributedString *strings;

@end

@implementation MyTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.bounces = NO;
        self.scrollEnabled = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.font = [UIFont systemFontOfSize:14];
        self.userInteractionEnabled = YES;
    
        self.rangeArray = [NSMutableArray array];
        //长按手势
        NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:[self gestureRecognizers]];
        for (UIGestureRecognizer *ges in arr) {
            if ([ges isKindOfClass:[UILongPressGestureRecognizer class]] || [ges isKindOfClass:NSClassFromString(@"UIVariableDelayLoupeGesture")]) {
                [self removeGestureRecognizer:ges];
            }
        }
        
        // 引用的灰色条
        self.quoteBar = [[UIView alloc] init];
        [self addSubview:_quoteBar];
        _quoteBar.hidden = YES;
        _quoteBar.backgroundColor = [UIColor grayColor];
        [_quoteBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_quoteBar.superview).with.offset(5);
            make.height.mas_equalTo(_quoteBar.superview.height - 10);
            make.leading.equalTo(self);
            make.width.mas_equalTo(8);
        }];

        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewLongPressGesture:)];
        [self addGestureRecognizer:longGesture];
        
    }
    return self;
}

- (void)layoutSubviews
{
    // 在改变计算高度后, 重新布局灰色条的高度
    [_quoteBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_quoteBar.superview).with.offset(5);
        make.height.mas_equalTo(_quoteBar.superview.height - 10);
        make.leading.equalTo(self);
        make.width.mas_equalTo(8);
    }];

}

- (instancetype)init
{
    if (self == [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.bounces = NO;
        self.scrollEnabled = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        //长按手势
//        
//        for (UIGestureRecognizer *ges in self.gestureRecognizers) {
//            if ([ges isKindOfClass:[UILongPressGestureRecognizer class]] || [ges isKindOfClass:NSClassFromString(@"UIVariableDelayLoupeGesture")]) {
//                [self removeGestureRecognizer:ges];
//            }
//        }
        
        // 引用的灰色条
        self.quoteBar = [[UIView alloc] init];
        [self addSubview:_quoteBar];
        _quoteBar.hidden = YES;
        _quoteBar.backgroundColor = [UIColor grayColor];
        [_quoteBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_quoteBar.superview).with.offset(5);
            make.bottom.mas_equalTo(_quoteBar.superview.mas_bottom);
            make.leading.equalTo(self);
            make.width.mas_equalTo(8);
        }];

        // 长按手势
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewLongPressGesture:)];
        [self addGestureRecognizer:longGesture];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor grayColor].CGColor;
    border.fillColor = nil;
    border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    border.frame = self.bounds;
    border.lineWidth = 2.f;
    border.lineCap = @"square";
    border.lineDashPattern = @[@8, @8];

//    for (CAShapeLayer *layer in self.layer.sublayers) {
//        if ([layer respondsToSelector:@selector(lineCap)] && [layer.lineCap isEqualToString:@"square"]) {
//            [layer removeFromSuperlayer];
//        }
//    }
    
    // 该方法会多次调用, 所以在添加前移除原有的layer
    NSMutableArray * arrayTemp = [self.layer.sublayers mutableCopy];
    NSArray * array = [NSArray arrayWithArray: arrayTemp];
    
    for (CAShapeLayer *layer in array) {
        if ([layer respondsToSelector:@selector(lineCap)] && [layer.lineCap isEqualToString:@"square"]){
            [layer removeFromSuperlayer];
        }
    }

    [self.layer addSublayer:border];

    NSLog(@"%@", NSStringFromCGRect(border.frame));
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

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(viewLongPressGesture:)) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (![self isFirstResponder]) {
        if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UITextTapRecognizer")]) {
            NSLog(@"tap");
            // 移除虚线边框(条件是输入了内容之后)
            NSAttributedString *s = self.attributedText ? self.attributedText : [[NSAttributedString alloc] initWithString:self.text];
            if (s.length) {
                        CAShapeLayer *border = [CAShapeLayer layer];
                        border.strokeColor = [UIColor grayColor].CGColor;
                        border.fillColor = nil;
                        border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
                        border.frame = self.bounds;
                        border.lineWidth = 2.f;
                        border.lineCap = @"square";
                        border.lineDashPattern = @[@8, @8];
                        [self.layer addSublayer:border];
            }
        }
        if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UITextTapRecognizer")] || [gestureRecognizer isKindOfClass:NSClassFromString(@"UILongPressGestureRecognizer")]) {
            return YES;
        }
        return YES;
    }
    return YES;
    
}

- (BOOL)resignFirstResponder
{
    // 在这里拦截系统的长按手势, 并添加自己的长按手势
    for (UIGestureRecognizer *ges in self.gestureRecognizers) {
        if ([ges isKindOfClass:[UILongPressGestureRecognizer class]] || [ges isKindOfClass:NSClassFromString(@"UIVariableDelayLoupeGesture")]) {
            [self removeGestureRecognizer:ges];
        }
    }
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewLongPressGesture:)];
    [self addGestureRecognizer:longGesture];

    //
    NSAttributedString *s = self.attributedText ? self.attributedText : [[NSAttributedString alloc] initWithString:self.text];
    if (s.length) {
        // 在编辑完成后,去掉虚线边框
        NSMutableArray * arrayTemp = [self.layer.sublayers mutableCopy];
        NSArray * array = [NSArray arrayWithArray: arrayTemp];
        for (CAShapeLayer *layer in array) {
            if ([layer respondsToSelector:@selector(lineCap)] && [layer.lineCap isEqualToString:@"square"]){
                [layer removeFromSuperlayer];
            }
        }
    }
    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}


- (void)list
{
    NSMutableAttributedString *s = self.attributedText ? [self.attributedText mutableCopy] : [[[NSAttributedString alloc] initWithString:self.text] mutableCopy];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    if (self.listState == TextViewListStateNormal){
        [s removeAttribute:NSParagraphStyleAttributeName range:NSMakeRange(0, s.length)];
        if (_rangeArray.count) {
            [s deleteCharactersInRange:NSMakeRange(0, 4)];
        }
    }else{
        style.headIndent = 30;
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@" ·  " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
        [s insertAttributedString:str atIndex:0];
        [s addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, s.length)];
        // 储存列表的分隔符
        [_rangeArray addObject:[NSValue valueWithRange:NSMakeRange(0, 4)]];
    }
    self.attributedText = s;
    
}

- (void)insertParagraphHeader:(NSRange)range
{
    if (self.listState == TextViewListStateUnorder) {
        NSMutableAttributedString *s = self.attributedText ? [self.attributedText mutableCopy] : [[[NSAttributedString alloc] initWithString:self.text] mutableCopy];

        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@" ·  " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
        [s insertAttributedString:str atIndex:range.location + 1];
        self.attributedText = s;
        // 储存列表的分隔符
        NSRange newR = NSMakeRange(range.location + 1, 4);
//        [_rangeArray addObject:[NSValue valueWithRange:newR]];
        
        _rangeArray = [self getRangeStr:self.attributedText.string findText:@"\n"];
        
        
//        
//        
//        [_rangeArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//            if ([obj1 rangeValue].location > [obj2 rangeValue].location) {
//                return NSOrderedDescending;
//            }else
//            {
//                return NSOrderedAscending;
//            }
//        }];
    }
}

- (NSMutableArray *)getRangeStr:(NSString *)text findText:(NSString *)findText
{
    NSMutableArray *arrayRanges = [NSMutableArray arrayWithCapacity:20];
    if (findText == nil && [findText isEqualToString:@""]) {
        return nil;
    }
    NSRange rang = [text rangeOfString:findText];
    if (rang.location != NSNotFound && rang.length != 0) {
        //        [arrayRanges addObject:[NSNumber numberWithInteger:rang.location]];
        [arrayRanges addObject:[NSValue valueWithRange:NSMakeRange(rang.location + 1, 4)]];
        NSRange rang1 = {0,0};
        NSInteger location = 0;
        NSInteger length = 0;
        for (int i = 0;; i++)
        {
            if (0 == i) {
                location = rang.location + rang.length;
                length = text.length - rang.location - rang.length;
                rang1 = NSMakeRange(location, length);
            }else
            {
                location = rang1.location + rang1.length;
                length = text.length - rang1.location - rang1.length;
                rang1 = NSMakeRange(location, length);
            }
            rang1 = [text rangeOfString:findText options:NSCaseInsensitiveSearch range:rang1];
            if (rang1.location == NSNotFound && rang1.length == 0) {
                break;
            }else{
                //                [arrayRanges addObject:[NSNumber numberWithInteger:rang1.location]];
                [arrayRanges addObject:[NSValue valueWithRange:NSMakeRange(rang1.location + 1, 4)]];
            }
        }
        return arrayRanges;
    }
    return nil;
}

- (void)deleteLastParagraph
{
    if (self.listState == TextViewListStateUnorder) {
        NSMutableAttributedString *s = self.attributedText ? [self.attributedText mutableCopy] : [[[NSAttributedString alloc] initWithString:self.text] mutableCopy];
        
        [s deleteCharactersInRange:NSMakeRange(s.length - 5, 5)];
        self.attributedText = s;
        [_rangeArray removeLastObject];
    }
}


- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (![self isFirstResponder] && [gestureRecognizer isKindOfClass:NSClassFromString(@"UIVariableDelayLoupeGesture")])
    {
        return;
    }else
        [super addGestureRecognizer:gestureRecognizer];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc
{

}

@end
