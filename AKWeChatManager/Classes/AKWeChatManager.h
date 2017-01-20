//
//  AKWeChatManager.h
//  Pods
//
//  Created by 李翔宇 on 16/3/28.
//
//

#import <Foundation/Foundation.h>
#import "AKWeChatUserProtocol.h"
#import "AKWeChatShareProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^AKWeChatManagerSuccess)();
typedef void (^AKWeChatManagerLoginSuccess)(id<AKWeChatUserProtocol> user);
typedef void (^AKWeChatManagerFailure)(NSError *error);

@interface AKWeChatManager : NSObject

+ (void)setAppID:(NSString *)appID secretKey:(NSString *)secretKey;

//设置商家ID
+ (void)setPartnerID:(NSString *)partnerID;

/**
 标准单例模式
 
 @return AKWeChatManager
 */
+ (AKWeChatManager *)manager;

//处理从Application回调方法获取的URL
+ (BOOL)handleOpenURL:(NSURL *)url;

+ (void)loginSuccess:(AKWeChatManagerLoginSuccess)success
             failure:(AKWeChatManagerFailure)failure;

+ (void)share:(id<AKWeChatShareProtocol>)item
        scene:(AKWeChatShareScene)scene
      success:(AKWeChatManagerSuccess)success
      failure:(AKWeChatManagerFailure)failure;

+ (void)pay:(NSString *)orderID
       sign:(NSString *)sign
    success:(AKWeChatManagerSuccess)success
    failure:(AKWeChatManagerFailure)failure;

@end

NS_ASSUME_NONNULL_END
