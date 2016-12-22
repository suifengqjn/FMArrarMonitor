//
//  ViewController.m
//  testArr
//
//  Created by qianjn on 2016/12/22.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *array = @[@"1", @"2", @"3"];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
    
    
    //读取操作
    id va = array[10];
    id ra = mutableArray[12];
    NSLog(@"---%@- %@", va,ra);
    
    //添加操作
    NSString *addStr = nil;
    [mutableArray addObject:addStr];

    
    //插入操作
    [mutableArray insertObject:addStr atIndex:0];
    [mutableArray insertObject:@"4" atIndex:3];
    [mutableArray insertObject:addStr atIndex:8];
    
    //删除操作
    [mutableArray removeObjectAtIndex:2];
    [mutableArray removeObjectAtIndex:7];
    
    //替换操作
    [mutableArray replaceObjectAtIndex:0 withObject:addStr];
    [mutableArray replaceObjectAtIndex:0 withObject:@"abc"];
    [mutableArray replaceObjectAtIndex:2 withObject:@"4"];
    [mutableArray replaceObjectAtIndex:10 withObject:addStr];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
