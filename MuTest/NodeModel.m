//
//  NodeModel.m
//  MuTest
//
//  Created by hs on 2017/7/26.
//  Copyright © 2017年 Trich. All rights reserved.
//

#import "NodeModel.h"

@implementation NodeModel
- (instancetype)init
{
    if (self = [super init]) {
        self.nodes = [NSMutableArray array];
    }
    return self;
}
@end
