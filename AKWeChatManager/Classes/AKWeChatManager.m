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

static NSString * const AKWeChatManagerAccessTokenURL = @"https://api.WeChat.qq.com/sns/oauth2/access_token";
static NSString * const AKWeChatManagerUserInfoURL = @"https://api.WeChat.qq.com/sns/userinfo";

@interface AKWeChatManager () <WXApiDelegate>

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, strong) NSString *secretKey;

@property (nonatomic, strong) NSString *partnerID;

@property (nonatomic, strong) AKWeChatManagerLoginSuccess loginSuccess;
@property (nonatomic, strong) AKWeChatManagerFailure loginFailure;

@property (nonatomic, strong) AKWeChatManagerSuccess shareSuccess;
@property (nonatomic, strong) AKWeChatManagerFailure shareFailure;

@property (nonatomic, strong) AKWeChatManagerSuccess paySuccess;
@property (nonatomic, strong) AKWeChatManagerFailure payFailure;

@end

@implementation AKWeChatManager

+ (AKWeChatManager *)manager {
    static AKWeChatManager *weiboManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        weiboManager = [[super allocWithZone:NULL] init];
    });
    return weiboManager;
}

+ (id)alloc {
    return [self manager];
}

+ (id)allocWithZone:(NSZone * _Nullable)zone {
    return [self manager];
}

- (id)copy {
    return self;
}

- (id)copyWithZone:(NSZone * _Nullable)zone {
    return self;
}

#pragma mark- Private Method
- (AFHTTPSessionManager *)sessionManager {
    if(!_sessionManager) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
        
        _sessionManager.responseSerializer.acceptableContentTypes =  [_sessionManager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:[NSSet setWithObjects:@"application/json", @"application/xml", @"text/json", @"text/xml", @"text/javascript", @"text/html", @"text/plain", @"application/atom+xml", @"image/png", @"image/jpeg", nil]];
    }
    return _sessionManager;
}

- (NSString *)alert:(int)stateCode {
    NSString *alert = nil;
    switch (stateCode) {
        case WXErrCodeCommon: { alert = @"普通错误"; break; }
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

#pragma mark- Public Method
+ (void)setAppID:(NSString *)appID secretKey:(NSString *)secretKey {
    self.manager.appID = appID;
    self.manager.secretKey = secretKey;
}

+ (void)setPartnerID:(NSString *)partnerID {
    self.manager.partnerID = partnerID;
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    BOOL handle = [WXApi handleOpenURL:url delegate:[self manager]];
}

+ (void)loginSuccess:(AKWeChatManagerLoginSuccess)success
             failure:(AKWeChatManagerFailure)failure {
    //相关文档在这里：https://open.WeChat.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419317851&token=&lang=zh_CN
    
    self.manager.loginSuccess = success;
    self.manager.loginFailure = failure;
    
    SendAuthReq *request = [[SendAuthReq alloc] init];
    request.openID = self.manager.appID;
    request.scope = @"snsapi_userinfo,snsapi_friend" ;
    request.state = [self identifier];
    [WXApi sendReq:request];
}

+ (void)share:(id<AKWeChatShareProtocol>)item
        scene:(AKWeChatShareScene)scene
      success:(AKWeChatManagerSuccess)success
      failure:(AKWeChatManagerFailure)failure {
    //相关文档在这里：https://open.WeChat.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419317332&token=&lang=zh_CN
    
    AK_WXM_Nilable_Class_Return(self.manager.appID, NO, NSString, {})
    AK_WXM_Nilable_Class_Return(self.manager.partnerID, NO, NSString, {})
    
    self.manager.shareSuccess = success;
    self.manager.shareFailure = failure;
    
    SendMessageToWXReq *request = [item requestToScene:scene];
    [WXApi sendReq:request];
}

+ (void)pay:(NSString *)orderID
       sign:(NSString *)sign
    success:(AKWeChatManagerSuccess)success
    failure:(AKWeChatManagerFailure)failure {
    //相关文档在这里：https://pay.WeChat.qq.com/wiki/doc/api/app/app.php?chapter=9_12&index=2
    
    AK_WXM_Nilable_Class_Return(self.manager.appID, NO, NSString, {})
    AK_WXM_Nilable_Class_Return(self.manager.partnerID, NO, NSString, {})
    AK_WXM_Nilable_Class_Return(orderID, NO, NSString, {})
    AK_WXM_Nilable_Class_Return(sign, NO, NSString, {})
    
    self.manager.paySuccess = success;
    self.manager.payFailure = failure;
    
    PayReq *request = [[PayReq alloc] init];
    request.openID = self.manager.appID;
    request.partnerId = self.manager.partnerID;
    request.prepayId= orderID;
    request.package = @"Sign=WXPay";
    request.nonceStr= [self identifier];
    request.timeStamp= [NSDate date].timeIntervalSince1970;
    request.sign= sign;
    [WXApi sendReq:request];
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
-(void)onResp:(BaseResp*)resp {
    AKWeChatManagerLog(@"上下文:%@", resp.errStr);
    
    if(resp.errCode != WXSuccess) {
        NSMutableDictionary *userInfo = [@{@"errCode" : @(resp.errCode), @"errStr" : resp.errStr,  @"type" : @(resp.type)} mutableCopy];
        NSString *alert = [self alert:resp.errCode];
        if(alert) {
            userInfo[@"alert"] = alert;
        }
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:resp.errCode userInfo:userInfo];
        
        if ([resp isKindOfClass:[SendAuthResp class]]) {
            !self.loginFailure ? : self.loginFailure(error);
            
            self.loginSuccess = nil;
            self.loginFailure = nil;
        } else if([resp isKindOfClass:[SendMessageToWXResp class]]) {
            !self.shareFailure ? : self.shareFailure(error);
            
            self.shareSuccess = nil;
            self.shareFailure = nil;
        } else if([resp isKindOfClass:[PayResp class]]) {
            !self.payFailure ? : self.payFailure(error);
            
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
        [self loginWithTempCode:loginResponse.code];
    } else if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        !self.shareSuccess ? : self.shareSuccess();
        
        self.shareSuccess = nil;
        self.shareFailure = nil;
    } else if([resp isKindOfClass:[PayResp class]]) {
        !self.paySuccess ? : self.shareSuccess();
        
        self.paySuccess = nil;
        self.payFailure = nil;
    }
}

- (void)loginWithTempCode:(NSString *)tempCode {
    AK_WXM_Nilable_Class_Return(self.appID, NO, NSString, {})
    AK_WXM_Nilable_Class_Return(self.secretKey, NO, NSString, {})
    AK_WXM_Nilable_Class_Return(tempCode, NO, NSString, {})
    
    [self.sessionManager
     GET:AKWeChatManagerAccessTokenURL
     parameters:@{ @"appid" : self.appID,
                   @"secret" : self.secretKey,
                   @"code" : tempCode,
                   @"grant_type" : @"authorization_code" }
     progress:^(NSProgress * _Nonnull downloadProgress) {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable accessTokenResponseObject) {
         /* {
          "access_token":"ACCESS_TOKEN",
          "expires_in":7200,
          "refresh_token":"REFRESH_TOKEN",
          "openid":"OPENID",
          "scope":"SCOPE",
          "unionid":"o6_bmasdasdsad6_2sgVt7hMZOPfL"
          } */
         [self.sessionManager
          GET:AKWeChatManagerUserInfoURL
          parameters:@{@"access_token" : accessTokenResponseObject[@"access_token"] ? : @"",
                       @"openid" : self.appID}
          progress:^(NSProgress * _Nonnull downloadProgress) {
              
          } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
              
              AKWeChatUser *user = [[AKWeChatUser alloc] init];
              user.accessToken = accessTokenResponseObject[@"access_token"];
              user.refreshToken = accessTokenResponseObject[@"refresh_token"];
              user.expiredTime = [NSDate date].timeIntervalSince1970 + [accessTokenResponseObject[@"refresh_token"] doubleValue];
              user.openID = accessTokenResponseObject[@"openid"];
              user.unionID = accessTokenResponseObject[@"unionid"];
              user.nickname = responseObject[@"nickname"];
              user.portrait = responseObject[@"headimgurl"];
              
              !self.loginSuccess ? : self.loginSuccess(user);
              
              self.loginSuccess = nil;
              self.loginFailure = nil;
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              !self.loginFailure ? : self.loginFailure(error);
              
              self.loginSuccess = nil;
              self.loginFailure = nil;
          }];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         !self.loginFailure ? : self.loginFailure(error);
         
         self.loginSuccess = nil;
         self.loginFailure = nil;
     }];
}

@end
