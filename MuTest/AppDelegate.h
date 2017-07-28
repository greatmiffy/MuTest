//
//  AppDelegate.h
//  MuTest
//
//  Created by hs on 2017/7/13.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import <UIKit/UIKit.h>

#define myDelegate AppDelegate.sharedAppDelegate

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate*)sharedAppDelegate;
@end

