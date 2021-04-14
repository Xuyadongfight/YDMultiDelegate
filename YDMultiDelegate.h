//
//  YDMultiDelegate.h
//  CommonTools
//
//  Created by 徐亚东 on 2021/4/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface YDMultiDelegate<T> : NSProxy
-(id)initWithOriginDelegate:(id)originDelegate;
-(void)addDelegate:(id)delegate;
-(void)addDelegates:(NSArray *)delegates;
@end
NS_ASSUME_NONNULL_END

