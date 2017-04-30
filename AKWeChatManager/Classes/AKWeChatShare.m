//
//  AKWeChatShare.m
//  Pods
//
//  Created by 李翔宇 on 2017/1/17.
//
//

#import "AKWeChatShare.h"

@implementation AKWeChatShareText

- (SendMessageToWXReq *)requestToScene:(AKWeChatShareScene)scene {
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.scene = scene;
    request.bText = YES;
    request.text = self.text;
    return request;
}

@end

@implementation AKWeChatShareImage

- (void)complete:(WXMediaMessage *)message {
    if([self.thumbImage isKindOfClass:[UIImage class]]) {
        message.thumbImage = self.thumbImage;
    }
    
    WXImageObject *image = [WXImageObject object];
    NSData *imageData = nil;
    imageData = UIImageJPEGRepresentation(self.image, 1.);
    if(!imageData.length) {
        imageData = UIImagePNGRepresentation(self.image);
    }
    if(imageData.length) {
        image.imageData = imageData;
    }
    message.mediaObject = image;
}

- (SendMessageToWXReq *)requestToScene:(AKWeChatShareScene)scene {
    WXMediaMessage *message = [WXMediaMessage message];
    [self complete:message];
    
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.scene = scene;
    request.message = message;
    return request;
}

@end

@implementation AKWeChatShareURL

/**
 子类重载此方法
 
 @return WXMediaMessage
 */
- (WXMediaMessage *)message {
    return nil;
}

- (void)complete:(WXMediaMessage *)message {
    if([self.title isKindOfClass:[NSString class]]
       && self.title.length) {
        message.title = self.title;
    }
    
    if([self.detail isKindOfClass:[NSString class]]
       && self.detail.length) {
        message.description = self.detail;
    }
    
    if([self.thumbImage isKindOfClass:[UIImage class]]) {
        message.thumbImage = self.thumbImage;
    }
    
    if([self.mediaID isKindOfClass:[NSString class]]
       && self.mediaID.length) {
        message.mediaTagName = self.mediaID;
    }
}

- (SendMessageToWXReq *)requestToScene:(AKWeChatShareScene)scene {
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.scene = scene;
    request.message = [self message];
    return request;
}

@end

@implementation AKWeChatShareWeb

- (WXMediaMessage *)message {
    WXMediaMessage *message = [WXMediaMessage message];
    [self complete:message];
    return message;
}

- (void)complete:(WXMediaMessage *)message {
    [super complete:message];
    
    WXWebpageObject *web =  [WXWebpageObject object];
    if([self.URL isKindOfClass:[NSString class]]
       && self.URL.length) {
        web.webpageUrl = self.URL;
    }
    message.mediaObject = web;
}

@end

@implementation AKWeChatShareAudio

- (WXMediaMessage *)message {
    WXMediaMessage *message = [WXMediaMessage message];
    [self complete:message];
    return message;
}

- (void)complete:(WXMediaMessage *)message {
    [super complete:message];
    
    WXMusicObject *music =  [WXMusicObject object];
    if([self.URL isKindOfClass:[NSString class]]
       && self.URL.length) {
        music.musicUrl = self.URL;
    }
    if([self.lowBandURL isKindOfClass:[NSString class]]
       && self.lowBandURL.length) {
        music.musicLowBandUrl = self.lowBandURL;
    }
    if([self.streamURL isKindOfClass:[NSString class]]
       && self.streamURL.length) {
        music.musicDataUrl = self.streamURL;
    }
    if([self.lowBandStreamURL isKindOfClass:[NSString class]]
       && self.lowBandStreamURL.length) {
        music.musicLowBandDataUrl = self.lowBandStreamURL;
    }
    message.mediaObject = music;
}

@end

@implementation AKWeChatShareVideo

- (WXMediaMessage *)message {
    WXMediaMessage *message = [WXMediaMessage message];
    [self complete:message];
    return message;
}

- (void)complete:(WXMediaMessage *)message {
    [super complete:message];
    
    WXMusicObject *music =  [WXMusicObject object];
    if([self.URL isKindOfClass:[NSString class]]
       && self.URL.length) {
        music.musicUrl = self.URL;
    }
    if([self.lowBandURL isKindOfClass:[NSString class]]
       && self.lowBandURL.length) {
        music.musicLowBandUrl = self.lowBandURL;
    }
    message.mediaObject = music;
}

@end
