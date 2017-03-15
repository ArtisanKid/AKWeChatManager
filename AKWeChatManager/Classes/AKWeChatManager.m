//
//  AKWeChatManager.m
//  Pods
//
//  Created by 李翔宇 on 16/3/28.
//
//

#import "AKWeChatManager.h"
#import "AKWeChatManagerMacro.h"
#import <AKWeChatSDK/WXApi.h>
#import <AKWeChatSDK/WXApiObject.h>
#import <AFNetworking/AFNetworking.h>
#import "AKWeChatUser.h"

const NSString * const AKWeChatManagerErrorCodeKey = @"code";
const NSString * const AKWeChatManagerErrorMessageKey = @"message";
const NSString * const AKWeChatManagerErrorDetailKey = @"detail";

static NSString * const AKWeChatManagerAccessTokenURL = @"https://api.weixin.qq.com/sns/oauth2/access_token";
static NSString * const AKWeChatManagerRefreshAccessTokenURL = @"https://api.weixin.qq.com/sns/oauth2/refresh_token";
static NSString * const AKWeChatManagerUserInfoURL = @"https://api.weixin.qq.com/sns/userinfo";

@interface AKWeChatManager () <WXApiDelegate>

@property (nonatomic, assign, getter=isDebug) BOOL debug;

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, strong) NSString *secretKey;

@property (nonatomic, strong) NSString *partnerID;

@property (nonatomic, strong) AKWeChatManagerLoginSuccess loginSuccess;
@property (nonatomic, strong) AKWeChatManagerFailure loginFailure;

@property (nonatomic, strong) AKWeChatManagerSuccess shareSuccess;
@property (nonatomic, strong) AKWeChatManagerFailure shareFailure;

@property (nonatomic, strong) AKWeChatManagerSuccess paySuccess;
@property (nonatomic, strong) AKWeChatManagerFailure payFailure;

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) AKWeChatUser *user;

@end

@implementation AKWeChatManager

+ (AKWeChatManager *)manager {
    static AKWeChatManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
        sharedInstance.user = [[AKWeChatUser alloc] init];
    });
    return sharedInstance;
}

+ (id)alloc {
    return self.manager;
}

+ (id)allocWithZone:(NSZone * _Nullable)zone {
    return self.manager;
}

- (id)copy {
    return self;
}

- (id)copyWithZone:(NSZone * _Nullable)zone {
    return self;
}

#pragma mark- Public Method
+ (void)setDebug:(BOOL)debug {
    self.manager.debug = debug;
}

+ (BOOL)isDebug {
    return self.manager.isDebug;
}

+ (void)setAppID:(NSString *)appID secretKey:(NSString *)secretKey {
    self.manager.appID = appID;
    self.manager.secretKey = secretKey;
    [WXApi registerApp:self.manager.appID withDescription:@"元素战争是一款化学反应为基础的卡牌游戏"];
}

+ (void)setPartnerID:(NSString *)partnerID {
    self.manager.partnerID = partnerID;
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    BOOL handle = [WXApi handleOpenURL:url delegate:self.manager];
}

+ (void)loginSuccess:(AKWeChatManagerLoginSuccess)success
             failure:(AKWeChatManagerFailure)failure {
    //相关文档在这里：https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419317851&token=9b29a057d2b3de7f47472394c3870212ababdc67&lang=zh_CN
    
    if(![self.manager checkAppInstalled]) {
        [self.manager failure:failure message:@"未安装微信"];
        return;
    }
    
    if(![self.manager checkAppVersion]) {
        [self.manager failure:failure message:@"微信版本过低"];
        return;
    }
    
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if(self.manager.user.expiredTime - now >= 60) {
        !success ? : success(self.manager.user);
    } else if(self.manager.user.expiredTime > now && self.manager.user.expiredTime - now < 60) {
        [self.manager refreshAccessTokenSuccess:^{
            [self.manager realLoginSuccess:success failure:failure];
        } failure:failure];
    } else if(self.manager.user.refreshToken.length) {
        [self.manager refreshAccessTokenSuccess:^{
            [self.manager realLoginSuccess:success failure:failure];
        } failure:failure];
    } else {
        NSString *openID = self.manager.appID;
        if(self.manager.user.openID.length) {
            openID = [self.manager.user.openID stringByAppendingString:openID];
        }
        
        SendAuthReq *request = [[SendAuthReq alloc] init];
        request.openID = openID;
        request.scope = @"snsapi_base,snsapi_userinfo,snsapi_friend" ;
        request.state = [self identifier];
        
        BOOL result = [WXApi sendReq:request];
        if(!result) {
            [self.manager failure:failure message:@"Auth请求发送失败"];
            return;
        }
        
        self.manager.loginSuccess = success;
        self.manager.loginFailure = failure;
    }
}

+ (void)share:(id<AKWeChatShareProtocol>)item
        scene:(AKWeChatShareScene)scene
      success:(AKWeChatManagerSuccess)success
      failure:(AKWeChatManagerFailure)failure {
    //相关文档在这里：https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419317851&token=&lang=zh_CN
    
    if(![self.manager checkAppInstalled]) {
        [self.manager failure:failure message:@"未安装微信"];
        return;
    }
    
    if(![self.manager checkAppVersion]) {
        [self.manager failure:failure message:@"微信版本过低"];
        return;
    }
    
    NSString *openID = self.manager.appID;
    if(self.manager.user.openID.length) {
        openID = [self.manager.user.openID stringByAppendingString:openID];
    }
    
    SendMessageToWXReq *request = [item requestToScene:scene];
    request.openID = openID;
    
    BOOL result = [WXApi sendReq:request];
    if(!result) {
        [self.manager failure:failure message:@"Share请求发送失败"];
        return;
    }
    
    self.manager.shareSuccess = success;
    self.manager.shareFailure = failure;
}

+ (void)pay:(NSString *)orderID
       sign:(NSString *)sign
    success:(AKWeChatManagerSuccess)success
    failure:(AKWeChatManagerFailure)failure {
    //相关文档在这里：https://pay.WeChat.qq.com/wiki/doc/api/app/app.php?chapter=9_12&index=2
    
    AKWXM_String_Nilable_Return(self.manager.appID, NO, {
        [self.manager failure:failure message:@"未设置appID"];
    });
    
    AKWXM_String_Nilable_Return(self.manager.partnerID, NO, {
        [self.manager failure:failure message:@"未设置partnerID"];
    });
    
    AKWXM_String_Nilable_Return(orderID, NO, {
        [self.manager failure:failure message:@"orderID类型错误或nil"];
    });
    
    AKWXM_String_Nilable_Return(sign, NO, {
        [self.manager failure:failure message:@"sign类型错误或nil"];
    });
    
    if(![self.manager checkAppInstalled]) {
        [self.manager failure:failure message:@"未安装微信"];
        return;
    }
    
    if(![self.manager checkAppVersion]) {
        [self.manager failure:failure message:@"微信版本过低"];
        return;
    }
    
    NSString *openID = self.manager.appID;
    if(self.manager.user.openID.length) {
        openID = [self.manager.user.openID stringByAppendingString:openID];
    }
    
    PayReq *request = [[PayReq alloc] init];
    request.openID = openID;
    request.partnerId = self.manager.partnerID;
    request.prepayId = orderID;
    request.package = @"Sign=WXPay";
    request.nonceStr = [self identifier];
    request.timeStamp = [NSDate date].timeIntervalSince1970;
    request.sign = sign;
    
    BOOL result = [WXApi sendReq:request];
    if(!result) {
        [self.manager failure:failure message:@"Pay请求发送失败"];
        return;
    }
    
    self.manager.paySuccess = success;
    self.manager.payFailure = failure;
}

#pragma mark- WXApiDelegate
/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
/*
 WXSuccess           = 0,    //< 成功
 WXErrCodeCommon     = -1,   //< 普通错误类型
 WXErrCodeUserCancel = -2,   //< 用户点击取消并返回
 WXErrCodeSentFail   = -3,   //< 发送失败
 WXErrCodeAuthDeny   = -4,   //< 授权失败
 WXErrCodeUnsupport  = -5,   //< 微信不支持
 */
-(void)onResp:(BaseResp *)resp {
    if(resp.errCode != WXSuccess) {
        NSString *message = [self alert:resp.errCode];
        if ([resp isKindOfClass:[SendAuthResp class]]) {
            [self failure:self.loginFailure code:resp.errCode message:message detail:resp.errStr];
            
            self.loginSuccess = nil;
            self.loginFailure = nil;
        } else if([resp isKindOfClass:[SendMessageToWXResp class]]) {
            [self failure:self.shareFailure code:resp.errCode message:message detail:resp.errStr];
            
            self.shareSuccess = nil;
            self.shareFailure = nil;
        } else if([resp isKindOfClass:[PayResp class]]) {
            [self failure:self.payFailure code:resp.errCode message:message detail:resp.errStr];
            
            self.paySuccess = nil;
            self.payFailure = nil;
        } else if([resp isKindOfClass:[OpenWebviewResp class]]) {
        } else if([resp isKindOfClass:[OpenTempSessionResp class]]) {
        } else if([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {
        }
        return;
    }
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *loginResponse = (SendAuthReq *)resp;
        AKWeChatManagerLoginSuccess success = self.loginSuccess;
        AKWeChatManagerFailure failure = self.loginFailure;
        
        [self getAccessTokenWithTempCode:loginResponse.code success:^{
            [self realLoginSuccess:success failure:failure];
        } failure:failure];
        
        self.loginSuccess = nil;
        self.loginFailure = nil;
    } else if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        !self.shareSuccess ? : self.shareSuccess();
        
        self.shareSuccess = nil;
        self.shareFailure = nil;
    } else if([resp isKindOfClass:[PayResp class]]) {
        !self.paySuccess ? : self.paySuccess();
        
        self.paySuccess = nil;
        self.payFailure = nil;
    }
}

#pragma mark- Private Method
- (AFHTTPSessionManager *)sessionManager {
    if(_sessionManager) {
        return _sessionManager;
    }
    
    _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    
    _sessionManager.responseSerializer.acceptableContentTypes =  [_sessionManager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:[NSSet setWithObjects:@"application/json", @"application/xml", @"text/json", @"text/xml", @"text/javascript", @"text/html", @"text/plain", @"application/atom+xml", @"image/png", @"image/jpeg", nil]];
    return _sessionManager;
}

- (NSString *)alert:(int)stateCode {
    NSString *alert = nil;
    switch (stateCode) {
        case WXErrCodeCommon: { alert = @"错误"; break; }
        case WXErrCodeUserCancel: { alert = @"取消发送"; break; }
        case WXErrCodeSentFail: { alert = @"发送失败"; break; }
        case WXErrCodeAuthDeny: { alert = @"授权失败"; break; }
        case WXErrCodeUnsupport: { alert = @"微信不支持"; break; }
        default: break;
    }
    return alert;
}

+ (NSString *)identifier {
    NSTimeInterval timestamp = [NSDate date].timeIntervalSince1970;
    return @(timestamp).description;
}

- (void)getAccessTokenWithTempCode:(NSString *)tempCode
                           success:(AKWeChatManagerSuccess)success
                           failure:(AKWeChatManagerFailure)failure {
    AKWXM_String_Nilable_Return(self.appID, NO, {
        [self failure:failure message:@"未设置appID"];
    });
    
    AKWXM_String_Nilable_Return(self.secretKey, NO, {
        [self failure:failure message:@"未设置secretKey"];
    });
    
    AKWXM_String_Nilable_Return(tempCode, NO, {
        [self failure:failure message:@"tempCode类型错误或nil"];
    });
    
    [self.sessionManager
     GET:AKWeChatManagerAccessTokenURL
     parameters:@{ @"appid" : self.appID,
                   @"secret" : self.secretKey,
                   @"grant_type" : @"authorization_code",
                   @"code" : tempCode }
     progress:^(NSProgress * _Nonnull downloadProgress) {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSDictionary *userInfo = nil;
         
         /* {"errcode":40029,"errmsg":"invalid code"} */
         
         NSInteger code = [responseObject[@"errcode"] integerValue];
         if(code != 0) {
             NSString *detail = responseObject[@"errmsg"];
             [self failure:failure code:code message:@"accessToken接口请求失败" detail:detail];
             [self.user invalid];
             return;
         }
         
         /* {
          "access_token":"ACCESS_TOKEN",
          "expires_in":7200,
          "refresh_token":"REFRESH_TOKEN",
          "openid":"OPENID",
          "scope":"SCOPE",
          "unionid":"o6_bmasdasdsad6_2sgVt7hMZOPfL"
          } */
         
         NSString *accessToken = responseObject[@"access_token"];
         if(![accessToken isKindOfClass:[NSString class]]
            || !accessToken.length) {
             [self failure:failure message:@"accessToken获取失败"];
             return;
         }
         
         NSString *refreshToken = responseObject[@"refresh_token"];
         if(![refreshToken isKindOfClass:[NSString class]]
            || !refreshToken.length) {
             [self failure:failure message:@"refreshToken获取失败"];
             return;
         }
         
         id expiresIn = responseObject[@"expires_in"];
         if(![expiresIn respondsToSelector:@selector(doubleValue)]) {
             [self failure:failure message:@"expiresIn获取失败"];
             return;
         }
         
         NSString *openID = responseObject[@"openid"];
         if(![openID isKindOfClass:[NSString class]]
            || !openID.length) {
             [self failure:failure message:@"openID获取失败"];
             return;
         }
         
         NSString *unionID = responseObject[@"unionid"];
         if(![unionID isKindOfClass:[NSString class]]
            || !unionID.length) {
             [self failure:failure message:@"unionID获取失败"];
             return;
         }
         
         self.user.accessToken = accessToken;
         self.user.refreshToken = refreshToken;
         self.user.expiredTime = [NSDate date].timeIntervalSince1970 + [expiresIn doubleValue];
         self.user.openID = openID;
         self.user.unionID = unionID;
         
         !success ? : success();
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         if(self.isDebug) {
             AKWeChatManagerLog(@"%@", error);
         }
         !failure ? : failure(error);
     }];
}

- (void)refreshAccessTokenSuccess:(AKWeChatManagerSuccess)success
                          failure:(AKWeChatManagerFailure)failure {
    AKWXM_String_Nilable_Return(self.appID, NO, {
        [self failure:failure message:@"未设置appID"];
    });
    
    AKWXM_String_Nilable_Return(self.user.refreshToken, NO, {
        [self failure:failure message:@"refreshToken类型错误或nil"];
    });
    
    [self.sessionManager
     GET:AKWeChatManagerRefreshAccessTokenURL
     parameters:@{ @"appid" : self.appID,
                   @"grant_type" : @"refresh_token",
                   @"refresh_token" : self.user.refreshToken }
     progress:^(NSProgress * _Nonnull downloadProgress) {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSDictionary *userInfo = nil;
         
         /* {"errcode":40030,"errmsg":"invalid refresh_token"}*/
         
         NSInteger code = [responseObject[@"errcode"] integerValue];
         if(code != 0) {
             NSString *detail = responseObject[@"errmsg"];
             [self failure:failure code:code message:@"refreshAccessToken接口请求失败" detail:detail];
             [self.user invalid];
             return;
         }
         
         /*{
          "access_token":"ACCESS_TOKEN",
          "expires_in":7200,
          "refresh_token":"REFRESH_TOKEN",
          "openid":"OPENID",
          "scope":"SCOPE"
          }*/
         
         NSString *accessToken = responseObject[@"access_token"];
         if(![accessToken isKindOfClass:[NSString class]]
            || !accessToken.length) {
             [self failure:failure message:@"accessToken获取失败"];
             return;
         }
         
         id expiresIn = responseObject[@"expires_in"];
         if(![expiresIn respondsToSelector:@selector(doubleValue)]) {
             [self failure:failure message:@"expiresIn获取失败"];
             return;
         }
         
         self.user.accessToken = accessToken;
         self.user.expiredTime = [NSDate date].timeIntervalSince1970 + [expiresIn doubleValue];
         
         !success ? : success();
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         if(self.isDebug) {
             AKWeChatManagerLog(@"%@", error);
         }
         !failure ? : failure(error);
     }];
}

- (void)realLoginSuccess:(AKWeChatManagerLoginSuccess)success
                 failure:(AKWeChatManagerFailure)failure {
    AKWXM_String_Nilable_Return(self.user.accessToken, NO, {
        [self failure:failure message:@"accessToken类型错误或nil"];
    });
    
    AKWXM_String_Nilable_Return(self.user.openID, NO, {
        [self failure:failure message:@"openID类型错误或nil"];
    });
    
    [self.sessionManager
     GET:AKWeChatManagerUserInfoURL
     parameters:@{@"access_token" : self.user.accessToken,
                  @"openid" : self.user.openID}
     progress:^(NSProgress * _Nonnull downloadProgress) {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSDictionary *userInfo = nil;
         
         /* {"errcode":40003,"errmsg":"invalid openid"} */
         
         NSInteger code = [responseObject[@"errcode"] integerValue];
         if(code != 0) {
             NSString *detail = responseObject[@"errmsg"];
             [self failure:failure code:code message:@"login接口请求失败" detail:detail];
             [self.user invalid];
             return;
         }
         
         /* {
          "openid":"OPENID",
          "nickname":"NICKNAME",
          "sex":1,
          "province":"PROVINCE",
          "city":"CITY",
          "country":"COUNTRY",
          "headimgurl": "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0",
          "privilege":[
          "PRIVILEGE1",
          "PRIVILEGE2"
          ],
          "unionid": " o6_bmasdasdsad6_2sgVt7hMZOPfL"
          } */
         
         NSString *nickname = responseObject[@"nickname"];
         if(![nickname isKindOfClass:[NSString class]]
            || !nickname.length) {
             [self failure:failure message:@"nickname获取失败"];
             return;
         }
         
         NSString *portrait = responseObject[@"headimgurl"];
         if(![portrait isKindOfClass:[NSString class]]
            || !portrait.length) {
             [self failure:failure message:@"portrait获取失败"];
             return;
         }
         
         self.user.nickname = nickname;
         self.user.portrait = portrait;
         
         !success ? : success(self.user);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         if(self.isDebug) {
             AKWeChatManagerLog(@"%@", error);
         }
         !failure ? : failure(error);
     }];
}

- (BOOL)checkAppInstalled {
    if([WXApi isWXAppInstalled]) {
        return YES;
    }
    
    [self showAlert:@"当前您还没有安装微信，是否安装微信？"];
    return NO;
}

- (BOOL)checkAppVersion {
    if([WXApi isWXAppSupportApi]) {
        return YES;
    }
    
    [self showAlert:@"当前微信版本过低，是否升级？"];
    return NO;
}

- (void)showAlert:(NSString *)alertMessage {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"提示"
                                          message:alertMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:@"下载"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [rootViewController dismissViewControllerAnimated:YES completion:^{
                                                                   NSString *appStoreURL = [WXApi getWXAppInstallUrl];
                                                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreURL]];
                                                               }];
                                                           }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消登录"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [rootViewController dismissViewControllerAnimated:YES completion:^{}];
                                                         }];
    [alertController addAction:downloadAction];
    [alertController addAction:cancleAction];
    [rootViewController presentViewController:alertController animated:YES completion:^{}];
}

- (void)failure:(AKWeChatManagerFailure)failure message:(NSString *)message {
    if(self.isDebug) {
        AKWeChatManagerLog(@"%@", message);
    }
    
    NSDictionary *userInfo = nil;
    if([message isKindOfClass:[NSString class]]
       && message.length) {
        userInfo = @{AKWeChatManagerErrorMessageKey : message};
    }
    
    NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:0
                                     userInfo:userInfo];
    !failure ? : failure(error);
}
    
- (void)failure:(AKWeChatManagerFailure)failure code:(NSInteger)code message:(NSString *)message detail:(NSString *)detail {
    if(self.isDebug) {
        AKWeChatManagerLog(@"%@", message);
        AKWeChatManagerLog(@"%@", detail);
    }
    
    NSMutableDictionary *userInfo = [@{AKWeChatManagerErrorCodeKey : @(code)} mutableCopy];
    if([message isKindOfClass:[NSString class]]
       && message.length) {
        userInfo[AKWeChatManagerErrorMessageKey] = message;
    }
    
    if([detail isKindOfClass:[NSString class]]
       && detail.length) {
        userInfo[AKWeChatManagerErrorDetailKey] = detail;
    }
    
    NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:0
                                     userInfo:[userInfo copy]];
    !failure ? : failure(error);
}

@end
