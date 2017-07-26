//
//  TextModel.h
//  MuTest
//
//  Created by hs on 2017/7/26.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextModel : NSObject

@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSMutableArray *marks;



@end
