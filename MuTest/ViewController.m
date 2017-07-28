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
#import "SelectedBar.h"
#import <AVFoundation/AVFoundation.h>
#import "MyPicView.h"
#import "TZImagePickerController.h"


@interface ViewController ()<UITextViewDelegate, MyTextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TZImagePickerControllerDelegate, MyPicViewDelegate>

@property (nonatomic, strong) MyTextView *contentTextView;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) NSMutableArray *objList;
@property (nonatomic, strong) MyTextView *currentView;
@property (nonatomic, strong) BottomBar *bottomBar;
@property (nonatomic, strong) SelectedBar *selectedBar;

@property (nonatomic, assign) CGPoint rects;

@property (nonatomic, assign) BOOL isDelete;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, ScreenHeight - 50)];
    _scroll.userInteractionEnabled = YES;
    _scroll.contentSize = CGSizeMake(ScreenWidth, _scroll.height);
    [self.view addSubview:_scroll];
    
    self.bottomBar = [[BottomBar alloc] initWithFrame:CGRectMake(0, ScreenHeight - 30, ScreenWidth, 30)block:^(NSInteger index, NSInteger state) {
        if (index == 1) {
            [self bolder];
        }
        if (index == 2) {
            [self yinyong:state];
        }
        if (index == 3) {
            [self liebiao:state];
        }
        if (index == 0) {
            [self image];
        }
    }];
    [self.view addSubview:_bottomBar];
    
    self.selectedBar = [[SelectedBar alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 30) callBack:^(NSInteger index, NSInteger state) {
        if (index == 0) {
            [self bold];
        }
        if (index == 1) {
            [self xieti:state];
        }
        if (index == 2) {
            [self link:state];
        }
    }];
    [self.view addSubview:_selectedBar];
    _selectedBar.hidden = YES;
    
    self.contentTextView = [[MyTextView alloc] initWithFrame:CGRectMake(20, 20, ScreenWidth - 40, 40)];
    _contentTextView.delegate = self;
    _contentTextView.delegateF = self;
    [self.scroll addSubview:_contentTextView];
    _contentTextView.tag = 100;
    self.objList = [NSMutableArray array];
    [_objList addObject:_contentTextView];
    
    _currentView = self.contentTextView;
    
    
}

- (void)changeToBottomBar
{
    if (!_bottomBar.hidden) {
        return;
    }
    _bottomBar.y = _selectedBar.bottom;
    _bottomBar.hidden = NO;
    [self.view bringSubviewToFront:_bottomBar];
    [UIView animateWithDuration:0.25f animations:^{
        _bottomBar.y = _selectedBar.y;
    } completion:^(BOOL finished) {
        _selectedBar.hidden = YES;
    }];
}
- (void)changeToSelectBar
{
    if (!_selectedBar.hidden) {
        return;
    }
    self.selectedBar.y = _bottomBar.bottom;
    _selectedBar.hidden = NO;
    [self.view bringSubviewToFront:_selectedBar];
    [UIView animateWithDuration:0.25f animations:^{
        self.selectedBar.y = _bottomBar.y;
    } completion:^(BOOL finished) {
        _bottomBar.hidden = YES;
    }];
}

// 加粗的位置坐标
NSInteger _loc;
NSInteger _len;
NSRange lastRange;
CGFloat currentLength;
#pragma mark - TextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSLog(@"%@-----%@", NSStringFromRange(textView.selectedRange), textView.selectedTextRange);
    _loc = textView.selectedRange.location;
    _len = textView.selectedRange.length;
//    if (textView.selectedRange.location < 4) {
//        if (currentLength == 0) {
//            currentLength = textView.selectedRange.length;
//        }
//        
//        
//    }
    if (_len == 0 && textView.attributedText.length) {
        [self changeToBottomBar];
    }
    if (_len > 0)
    {
        [self changeToSelectBar];
    }
    if ([(MyTextView *)textView listState] == TextViewListStateNormal) {
        return;
    }
    if (_isDelete == YES) {
        _isDelete = NO;
        return;
    }
    NSRange limit = [(MyTextView *)textView selectRangeLimit:textView.selectedRange];
    if (textView.selectedRange.location < limit.location) {
        textView.selectedRange = NSMakeRange(limit.location, textView.selectedRange.length);
    }
    if (textView.selectedRange.location + textView.selectedRange.length > limit.location + limit.length) {
        textView.selectedRange = NSMakeRange(textView.selectedRange.location, limit.length - textView.selectedRange.location);
    }
    
}



- (void)textViewDidChange:(UITextView *)textView
{
    // 输入回车后插入一个列表头
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
    // 输入内容为删除键
    if (text.length == 0) {
        _isDelete = YES;
        if (!textView.attributedText.length && !textView.text.length && textView.tag != 100) {
            [self removeTextView:(MyTextView *)textView];
        }
        for (NSValue *v in [(MyTextView *)textView rangeArray]) {
            NSRange temp = [v rangeValue];
            if (NSLocationInRange(range.location, temp)) {
                NSMutableAttributedString *s =[textView.attributedText mutableCopy];
                [s deleteCharactersInRange:NSMakeRange(temp.location, temp.length)];
                textView.attributedText = s;
                // range.location - 4 + 1,因为删除键要删除一个
                textView.selectedRange = NSMakeRange(range.location - 4, 0);
                [(MyTextView *)textView removeRangeFromArray:v];
                return YES;
            }
        }
    }
    
    // 点击换行创建新的输入框
    if ([(MyTextView *)textView listState] == TextViewListStateNormal) {
        NSLog(@"%@",NSStringFromRange(textView.selectedRange));
        if ([text isEqualToString:@"\n"]) {
            [self addTextView:(MyTextView *)textView];
            return NO;
        }
    }else{
        // 列表状态下点击回车
        
        // 在段尾
        if (textView.selectedRange.location == [[[(MyTextView *)textView rangeArray] lastObject] rangeValue].location + [[[(MyTextView *)textView rangeArray] lastObject] rangeValue].length && [text isEqualToString:@"\n"]) {
            [(MyTextView *)textView deleteLastParagraph];
            [self caculateTextHeight:textView];
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
        // 在段中
        if ([text isEqualToString:@"\n"]){
//            [(MyTextView *)textView insertParagraphHeader:range];
            
            lastRange = range;
            return YES;
        }
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
    NSAttributedString *newS = [textView.attributedText attributedSubstringFromRange:NSMakeRange(textView.selectedRange.location, textView.attributedText.length - textView.selectedRange.location)];
    [self.scroll addSubview:newT];
    newT.delegateF = self;
    newT.tag = textView.tag + 1;
    [_objList insertObject:newT atIndex:textView.tag - 99];
    newT.frame = CGRectMake(20, 0, ScreenWidth - 40, 40);
    newT.delegate = self;
    [newT becomeFirstResponder];
    // 截取光标后面的字符串, 给到新的textView
    if (newS.length) {
        textView.attributedText = [textView.attributedText attributedSubstringFromRange:NSMakeRange(0, textView.selectedRange.location)];
        newT.attributedText = newS;
        [self caculateTextHeight:newT];
    }
    [self layoutTextView];
}

- (void)addImageViewWithImage:(UIImage *)image
{
    
    CGFloat height = image.size.height * (ScreenWidth - 40) / image.size.width;
    
    MyPicView *picView = [[MyPicView alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth - 40, height)];
    [picView setContentImage:image];
    [self.scroll addSubview:picView];
    picView.delegateF = self;
    picView.delegate = self;
    picView.tag = _currentView.tag + 1;
    [_objList insertObject:picView atIndex:_currentView.tag - 99];
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
        // 处理数组
        [_objList removeObject:myV];
        [_objList insertObject:myV atIndex:toIndex];
        [UIView animateWithDuration:0.25 animations:^{
            [self changeTextViewFrame:myV];
        }];
        
    }
    // 向下拖动
    if (toIndex >= fromtag-100 && toIndex < _objList.count) {
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
}

- (void)beginMoveAction:(NSInteger)tag
{
    NSLog(@"begin");
    MyTextView *myV = _objList[tag - 100];
    [self.scroll bringSubviewToFront:myV];
    
    [UIView animateWithDuration:0.25f animations:^{
        myV.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        myV.transform = CGAffineTransformMakeScale(1.1, 1.1);
    }];
}



- (void)endMoveViewAction:(NSInteger)tag
{
    NSLog(@"end");
    MyTextView *myV = _objList[tag - 100];
    myV.transform = CGAffineTransformIdentity;
    myV.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:.25f animations:^{
        [self layoutTextView];
    }];
    _rects = CGPointZero;
    
}


- (void)layoutTextView
{
    // 需要设置 x 坐标
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
    if (cur.bottom > _scroll.height) {
        _scroll.contentSize = CGSizeMake(ScreenWidth, cur.bottom);
        _scroll.contentOffset = CGPointMake(0, cur.bottom - _scroll.height);
    }else
    {
        _scroll.contentSize = CGSizeMake(ScreenWidth, _scroll.height);
    }
}

- (void)changeTextViewFrame:(UIView *)currentView
{
    // 不需要设置x坐标, 只需修正y坐标
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


- (void)liebiao:(NSInteger)state
{
    if (state == TextViewListStateNormal) {
        
        _currentView.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
        _currentView.listState = TextViewListStateNormal;
    }else if (state == TextViewListStateUnorder)
    {
        _currentView.textContainerInset = UIEdgeInsetsMake(8, 5, 8, 5);
        _currentView.listState = TextViewListStateUnorder;
    }else{
        _currentView.textContainerInset = UIEdgeInsetsMake(8, 5, 8, 5);
        _currentView.listState = TextViewListStateOrder;

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

- (void)bold
{
    [_currentView boldWithSelectedRange:_currentView.selectedRange];
    [self caculateTextHeight:_currentView];
}
- (void)xieti:(NSInteger)state
{
    [_currentView italicWithSelectedRange:_currentView.selectedRange];
    [self caculateTextHeight:_currentView];
}
- (void)link:(NSInteger)state
{
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.scroll endEditing:YES];
}

- (void)image
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:5 columnNumber:3 delegate:self];
    imagePickerVc.naviBgColor = [UIColor whiteColor];
    imagePickerVc.naviTitleColor = MUColor( 34, 36, 38);
    imagePickerVc.isStatusBarDefault = YES;
    imagePickerVc.barItemTextColor = MUColor(34, 36, 38);
    imagePickerVc.sortAscendingByModificationDate = NO;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
    
    
//    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//    [self presentViewController:imagePicker animated:YES completion:^{
//        
//    }];
//    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    imagePicker.allowsEditing = NO;
//    
//    imagePicker.delegate = self;
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    for (UIImage *img in photos) {
        [self addImageViewWithImage:[self compressImage1280:img]];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"%@",info);
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
//    CGFloat height = image.size.height * (ScreenWidth - 40) / image.size.width;
//    
//    MyPicView *picView = [[MyPicView alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth - 40, height)];
//    [picView setContentImage:image];

    [self addImageViewWithImage:[self compressImage1280:image]];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

+ (void)checkCameraAvalibale:(void (^)(void))success
                     failure:(void (^)(void))failure
{
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
                if (granted) {
                    if (success)
                        success();
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"allow_use_webcam" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil,nil];
                    alertView.delegate = self;
                    [alertView show];
                    if (failure)
                        failure();
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusAuthorized: {
            if (success)
                success();
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"allow_use_webcam" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil,nil];
            alertView.delegate = self;
            [alertView show];
            if (failure)
                failure();
            break;
        }
            
        default: {
            if (success)
                success();
            break;
        }
            
    }
}

#pragma mark - MyPicViewDelegate
- (void)didTapView:(MyPicView *)view
{
    [self.view endEditing:YES];
    for (UIView *v in _objList) {
        if ([v isKindOfClass:[MyPicView class]]) {
            if (![v isEqual:view]) {
                [(MyPicView *)v setIsSelected:NO];
                [(MyPicView *)v didTapView];
            }
        }
    }
}

- (void)deletePicture:(MyPicView *)view
{
    [_objList removeObject:view];
    [view removeFromSuperview];
    [self layoutTextView];
}

- (UIImage*)compressImage1280:(UIImage*)oldimg
{
    if(!oldimg)
        return nil;
    
    CGSize newsize = oldimg.size;
    if(newsize.width && (newsize.width > 1280.0f))
    {
        CGFloat scale = 1280.0f / newsize.width;
        newsize.width *= scale;
        newsize.height *= scale;
    }
    else
    {
        return oldimg;
    }
    UIGraphicsBeginImageContext(newsize);
    //UIGraphicsBeginImageContextWithOptions(newsize, NO, 0.0);
    CGRect rect = CGRectMake(0, 0, newsize.width, newsize.height);
    [oldimg drawInRect:rect];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
