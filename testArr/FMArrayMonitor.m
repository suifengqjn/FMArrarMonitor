//
//  FMArrayMonitor.m
//  testArr
//
//  Created by qianjn on 2016/12/22.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "FMArrayMonitor.h"

#import <objc/runtime.h>

static IMP array_old_func_imap_object = NULL;
static IMP muarray_old_func_imap_object = NULL;
static IMP muarray_old_func_imap_addobject = NULL;
static IMP muarray_old_func_imap_insetobject = NULL;
static IMP muarray_old_func_imap_removeobject = NULL;
static IMP muarray_old_func_imap_replaceobject = NULL;

@implementation FMArrayMonitor

+(void)load
{
    [super load];
    [FMArrayMonitor sharedInstance];
}

#pragma mark - NSArray
- (id)fm_objectAtIndex:(NSUInteger)index {
    if (index < [(NSArray*)self count]) {
        return ((id(*)(id, SEL, NSUInteger))array_old_func_imap_object)(self, @selector(objectAtIndex:), index);
    }
    NSLog(@"NArray objectAtIndex 失败--%@", [NSThread callStackSymbols]);
    return nil;
}


#pragma mark - NSMutableArray
- (id)fm_muobjectAtIndex:(NSUInteger)index {
    if (index < [(NSMutableArray*)self count]) {
        return ((id(*)(id, SEL, NSUInteger))muarray_old_func_imap_object)(self, @selector(objectAtIndex:), index);
    }
    NSLog(@"NSMutableArray objectAtIndex 失败--%@", [NSThread callStackSymbols]);
    return nil;
}

- (void)fm_addObject:(id)anObject {
    if (anObject != nil && [anObject isKindOfClass:[NSNull class]] == NO) {
        ((void(*)(id, SEL, id))muarray_old_func_imap_addobject)(self, @selector(addObject:), anObject);
    } else {
        NSLog(@"NSMutableArray addObject 失败--%@", [NSThread callStackSymbols]);
    }
}

- (void)fm_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (index <= [(NSMutableArray*)self count] && anObject != nil && [anObject isKindOfClass:[NSNull class]] == NO) {
        ((void(*)(id, SEL,id, NSUInteger))muarray_old_func_imap_insetobject)(self, @selector(insertObject:atIndex:), anObject,index);
    } else {
        NSLog(@"NSMutableArray insertObject:atIndex: 失败--%@", [NSThread callStackSymbols]);
    }
}

- (void)fm_removeObjectAtIndex:(NSUInteger)index {
    if (index < [(NSMutableArray*)self count]) {
        ((id(*)(id, SEL, NSUInteger))muarray_old_func_imap_removeobject)(self, @selector(removeObject:), index);
    } else {
        NSLog(@"NSMutableArray removeObject: 失败--%@", [NSThread callStackSymbols]);
    }
}
- (void)fm_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (index < [(NSMutableArray*)self count] && anObject != nil && [anObject isKindOfClass:[NSNull class]] == NO) {
        ((void(*)(id, SEL, NSUInteger,id))muarray_old_func_imap_replaceobject)(self, @selector(replaceObjectAtIndex:withObject:), index,anObject);
    } else {
        NSLog(@"NSMutableArray replaceObjectAtIndex:withObject: 失败--%@", [NSThread callStackSymbols]);
    }
}


static dispatch_once_t onceToken;
static FMArrayMonitor *sharedInstance;

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FMArrayMonitor alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // NSArray
        {
            Method old_func_imap_object = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:));
            array_old_func_imap_object = method_getImplementation(old_func_imap_object);
            method_setImplementation(old_func_imap_object, [self methodForSelector:@selector(fm_objectAtIndex:)]);
        }
        //NSMutableArray
        {
            Method mold_func_imap_object = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndex:));
            muarray_old_func_imap_object = method_getImplementation(mold_func_imap_object);
            method_setImplementation(mold_func_imap_object, [self methodForSelector:@selector(fm_muobjectAtIndex:)]);
        }
        {
            Method old_func_imap_addobject = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(addObject:));
            muarray_old_func_imap_addobject = method_getImplementation(old_func_imap_addobject);
            method_setImplementation(old_func_imap_addobject, [self methodForSelector:@selector(fm_addObject:)]);
        }
        {
            Method old_func_imap_insetobject = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(insertObject:atIndex:));
            muarray_old_func_imap_insetobject = method_getImplementation(old_func_imap_insetobject);
            method_setImplementation(old_func_imap_insetobject, [self methodForSelector:@selector(fm_insertObject:atIndex:)]);
        }
        {
            Method old_func_imap_removeobject = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(removeObjectAtIndex:));
            muarray_old_func_imap_removeobject = method_getImplementation(old_func_imap_removeobject);
            method_setImplementation(old_func_imap_removeobject, [self methodForSelector:@selector(fm_removeObjectAtIndex:)]);
        }
        {
            Method old_func_imap_replaceobject = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(replaceObjectAtIndex:withObject:));
            muarray_old_func_imap_replaceobject = method_getImplementation(old_func_imap_replaceobject);
            method_setImplementation(old_func_imap_replaceobject, [self methodForSelector:@selector(fm_replaceObjectAtIndex:withObject:)]);
        }
        
    }
    return self;
}

@end
