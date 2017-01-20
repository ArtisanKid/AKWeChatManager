//
//  AKWeChatShare.m
//  Pods
//
//  Created by 李翔宇 on 2017/1/17.
//
//

#import "AKWeChatShare.h"

@implementation AKWeChatShare

@end

@implementation AKWeChatShareText

- (SendMessageToWXReq *)messageToScene:(AKWeChatShareScene)scene {
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.bText = YES;
    request.scene = scene;
    return request;
}

@end

@implementation AKWeChatShareImage

- (SendMessageToWXReq *)messageToScene:(AKWeChatShareScene)scene {
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.scene = scene;
    return request;
}

@end

@implementation AKWeChatShareMedia

@end

@implementation AKWeChatShareWeb

- (SendMessageToWXReq *)messageToScene:(AKWeChatShareScene)scene {
    WXWebpageObject *web =  [WXWebpageObject object];
    web.webpageUrl = self.URL;
    
    WXMediaMessage *media = [WXMediaMessage message];
    media.title = self.title;
    media.description = self.description;
    media.thumbImage = self.thumbImage;
    media.mediaTagName = self.mediaID;
    media.mediaObject = web;
    
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.message = media;
    request.scene = scene;
    return request;
}

@end

@implementation AKWeChatShareMusic

- (SendMessageToWXReq *)messageToScene:(AKWeChatShareScene)scene {
    WXMusicObject *music =  [WXMusicObject object];
    music.musicUrl = self.URL;
    music.musicLowBandUrl = self.mediaLowBandURL;
    music.musicDataUrl = self.dataURL;
    music.musicLowBandDataUrl = self.lowBandDataURL;
    
    WXMediaMessage *media = [WXMediaMessage message];
    media.title = self.title;
    media.description = self.description;
    media.thumbImage = self.thumbImage;
    media.mediaTagName = self.mediaID;
    media.mediaObject = music;
    
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.message = media;
    request.scene = scene;
    return request;
}

@end

@implementation AKWeChatShareVideo

- (SendMessageToWXReq *)messageToScene:(AKWeChatShareScene)scene {
    WXVideoObject *video =  [WXVideoObject object];
    video.videoUrl = self.URL;
    video.videoLowBandUrl = self.mediaLowBandURL;
    
    WXMediaMessage *media = [WXMediaMessage message];
    media.title = self.title;
    media.description = self.description;
    media.thumbImage = self.thumbImage;
    media.mediaTagName = self.mediaID;
    media.mediaObject = video;
    
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.message = media;
    request.scene = scene;
    return request;
}

@end
