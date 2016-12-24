# iOS数组防止越界crash
有时候项目中总是出现一些无法预知的情况，导致数组越界是程序crash，如果这种意外情况无法避免，那么只能从侧面采取保护措施。我先从网上找答案，我想其他人也肯定遇到过相同的情况，如果有好的解决方案，直接采用就可以了。但是实际上，网上搜索的结果令人有些失望。下面还是记录一下我自己的解决方案，以及和网上解决方案的差异。

### crash的具体几种情况
- 取值：index超出array的索引范围
- 添加：插入的object为nil或者Null
- 插入：index大于count、插入的object为nil或者Null
- 删除：index超出array的索引范围
- 替换：index超出array的索引范围、替换的object为nil或者Null

### 解决思路
任何代码都需要围绕"高内聚，低耦合"的思想来实现，尤其是这种工具类的代码，更是应该对原代码入侵越少越好。一个很容易想到的方法，就是采用runtime, 把array中的以上几种情况的方法替换成自己的方法，然后再执行方法的时候加以判断。而我在网上搜到的结果全是以这种方案解决的，不排除有更好的方法我没找到。附上一个我找到的代码比较详细的[demo](https://github.com/wanyakun/YKIntercepter)。我试了一下，效果是可以达到，不过我还是毫不犹豫的拒绝这种方式。直接替换了系统的方法必然会导致更多无法预知的问题。这些问题，我在后面会讲几个我遇到的。而我准备解决：

- 这是系统原本的调用方式
![这是系统原本的调用方式](https://raw.githubusercontent.com/suifengqjn/demoimages/master/iOS%E9%98%B2%E6%AD%A2%E6%95%B0%E6%8D%AE%E8%B6%8A%E7%95%8Ccrash/12.png)

- 这是改变之后的调用方式
![这是改变之后的调用方式](https://raw.githubusercontent.com/suifengqjn/demoimages/master/iOS%E9%98%B2%E6%AD%A2%E6%95%B0%E6%8D%AE%E8%B6%8A%E7%95%8Ccrash/13.png)

我是先勾住array自带的方法，进行判断，如果没有越界等几种情况，再继续执行它自身的方法，相当于在执行方法前多了一步判断，而网上是直接把方法替换成自己的方法了，这里还是有本质的区别。

### 具体实现原理
这里举例说明 `NSArray` 的 `addObject:` 方法，其他也类似。
#### 先定义一个静态变量
`static IMP array_old_func_imap_object = NULL;`
这个变量用来记录array自带方法的指针地址
#### 获取方法，然后记录方法的指针地址
```
Method old_func_imap_object = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:));
            array_old_func_imap_object = method_getImplementation(old_func_imap_object);
```
#### 改变原方法的指针地址，并指向自定义方法
`method_setImplementation(old_func_imap_object, [self methodForSelector:@selector(fm_objectAtIndex:)]);`
#### 自定义方法的实现
```
- (id)fm_objectAtIndex:(NSUInteger)index {
    if (index < [(NSArray*)self count]) {
        return ((id(*)(id, SEL, NSUInteger))array_old_func_imap_object)(self, @selector(objectAtIndex:), index);
    }
    NSLog(@"NArray objectAtIndex 失败--%@", [NSThread callStackSymbols]);
    return nil;
}
```
#### 最后一步
到这里已经差不多完成了，就剩最后一个问题了，就是怎么运用到项目中，让这个工具类继承自NSObject，把这个工具类写成一个单例，然后在load方法中调用单例。load 方法会在本类第一次使用的时候调用一次，所以，把这个工具类拖到项目中，不用写其他代码，就实现了以上的功能。
```
+ (void)load {
    [FMDetecter sharedInstance];
}

static dispatch_once_t onceToken;
static FMDetecter *sharedInstance;

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FMDetecter alloc] init];
    });
    return sharedInstance;
}
```


