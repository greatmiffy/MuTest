//
//  MyTextView.h
//  MuTest
//
//  Created by hs on 2017/7/13.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger,TextViewListState){
    TextViewListStateNormal = 0,
    TextViewListStateUnorder,
    TextViewListStateOrder
};


@protocol MyTextViewDelegate <NSObject>

- (void)beginMoveAction:(NSInteger)tag;//移动前
- (void)moveViewAction:(NSInteger)tag gesture:(UIGestureRecognizer *)gesture;//移动中
- (void)endMoveViewAction:(NSInteger)tag;//结束移动

@end

@interface MyTextView : UITextView

- (void)list;
- (void)insertParagraphHeader:(NSRange)range;
- (void)deleteLastParagraph;


@property (nonatomic, weak) id<MyTextViewDelegate>delegateF;
@property (nonatomic, strong) UIView *quoteBar;

@property (nonatomic, assign) TextViewListState listState;

@property (nonatomic, strong) NSMutableArray *rangeArray;

@end
