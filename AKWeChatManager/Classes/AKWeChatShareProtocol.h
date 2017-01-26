//
//  AKWeChatShareProtocol.h
//  Pods
//
//  Created by 李翔宇 on 2017/1/17.
//
//

#import <Foundation/Foundation.h>
#import <AKWeChatSDK/WXApiObject.h>

typedef NS_ENUM(NSUInteger, AKWeChatShareScene) {
    AKWeChatShareSceneSession = WXSceneSession,//会话
    AKWeChatShareSceneTimeline = WXSceneTimeline//朋友圈
};

@protocol AKWeChatShareProtocol <NSObject>

- (SendMessageToWXReq *)requestToScene:(AKWeChatShareScene)scene;

@end
