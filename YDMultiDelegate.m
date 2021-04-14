//
//  YDMultiDelegate.m
//  CommonTools
//
//  Created by 徐亚东 on 2021/4/6.
//

#import "YDMultiDelegate.h"
#import <objc/runtime.h>

@interface WeakProxy : NSProxy
@property (nonatomic, weak, readonly) id target;
+ (instancetype)weakProxyWithTarget:(id)target;
@end


@interface YDMultiDelegate()
@property(strong,nonatomic)NSMutableArray *allDelegates;
@property(strong,nonatomic)NSPointerArray *weakDelegates;
@property(strong,nonatomic)NSArray *testArray;
@end

@implementation YDMultiDelegate

-(id)initWithOriginDelegate:(id)originDelegate{
    self.allDelegates = [[NSMutableArray alloc] init];
    self.weakDelegates = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsWeakMemory];
    [self.allDelegates addObject:[WeakProxy weakProxyWithTarget:originDelegate]];
    [self.weakDelegates addPointer:(__bridge void *)originDelegate];
    return self;
}
- (void)addDelegate:(id)delegate{
    [self.allDelegates addObject:[WeakProxy weakProxyWithTarget:delegate]];
    [self.weakDelegates addPointer:(__bridge void *)delegate];
}
- (void)addDelegates:(NSArray *)delegates{
    for (int i = 0;i < delegates.count;i++){
        [self addDelegate:delegates[i]];
    }
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig;
    
    for (int i = 0;i < self.weakDelegates.count;i++){
        id delegate = (__bridge id)[self.weakDelegates pointerAtIndex:i];
        sig = [delegate methodSignatureForSelector:aSelector];
        if (sig) return  sig;
    }
    
    
//    for ( int i = 0;i<self.allDelegates.count;i++){
//        id delegate = self.allDelegates[i];
//        sig = [delegate methodSignatureForSelector:aSelector];
//        if (sig) return  sig;
//    }
    return sig;
}
 
// Invoke the invocation on whichever real object had a signature for it.
- (void)forwardInvocation:(NSInvocation *)invocation {
    
    for (int i = 0;i < self.weakDelegates.count;i++){
        id delegate = (__bridge id)[self.weakDelegates pointerAtIndex:i];
        id sig = [delegate methodSignatureForSelector:[invocation selector]];
        if (sig){
            if ([delegate respondsToSelector:[invocation selector]]){
                [invocation invokeWithTarget:delegate];
            }
        }
    }
    
//    for ( int i = 0;i<self.allDelegates.count;i++){
//        id delegate = self.allDelegates[i];
//        id sig = [delegate methodSignatureForSelector:[invocation selector]];
//        if (sig){
//            if ([delegate respondsToSelector:[invocation selector]]){
//                [invocation invokeWithTarget:delegate];
//            }
//        }
//    }
}
 
// Override some of NSProxy's implementations to forward them...
- (BOOL)respondsToSelector:(SEL)aSelector {
    
    for (int i = 0;i < self.weakDelegates.count;i++){
        id delegate = (__bridge id)[self.weakDelegates pointerAtIndex:i];
        if ([delegate respondsToSelector:aSelector]) return YES;
    }
    
//    for ( int i = 0;i<self.allDelegates.count;i++){
//        id delegate = self.allDelegates[i];
//        if ([delegate respondsToSelector:aSelector]) return YES;
//    }
    return NO;
}
- (void)dealloc
{
    NSLog(@"YDMultiDelegate Dealloc");
}
@end



//MARK: - Class WeakProxy

@implementation WeakProxy
- (instancetype)initWithTarget:(id)target
{
  if (self) {
    _target = target;
  }
  return self;
}

+ (instancetype)weakProxyWithTarget:(id)target
{
  return [[WeakProxy alloc] initWithTarget:target];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
  return _target;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  return [_target respondsToSelector:aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
  return [_target conformsToProtocol:aProtocol];
}

/// Strangely, this method doesn't get forwarded by ObjC.
- (BOOL)isKindOfClass:(Class)aClass
{
  return [_target isKindOfClass:aClass];
}

- (NSString *)description
{
  return [self.target description];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
  return [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
}
- (void)forwardInvocation:(NSInvocation *)invocation
{
    void *null = NULL;
    [invocation setReturnValue:&null];
}
@end
