//
//  AKWeChatShare.m
//  Pods
//
//  Created by 李翔宇 on 2017/1/17.
//
//

#import "AKWeChatShare.h"

@implementation AKWeChatShareText

- (SendMessageToWXReq *)messageToScene:(AKWeChatShareScene)scene {
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.bText = YES;
    request.text = self.text;
    request.scene = scene;
    return request;
}

@end

@implementation AKWeChatShareImage

- (SendMessageToWXReq *)messageToScene:(AKWeChatShareScene)scene {
    NSData *imageData = nil;
    imageData = UIImageJPEGRepresentation(self.image, 1.);
    if(!imageData.length) {
        imageData = UIImagePNGRepresentation(self.image);
    }
    
    WXImageObject *image = [WXImageObject object];
    image.imageData = imageData;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.thumbImage = self.thumbImage;
    message.mediaObject = image;
    
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.scene = scene;
    request.message = message;
    return request;
}

@end

@implementation AKWeChatShareBaseMedia

/**
 子类重载此方法
 
 @return WXMediaMessage
 */
- (WXMediaMessage *)message {
    return nil;
}

- (SendMessageToWXReq *)messageToScene:(AKWeChatShareScene)scene {
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.message = [self message];
    request.scene = scene;
    return request;
}

@end

@implementation AKWeChatShareWeb

- (WXMediaMessage *)message {
    WXWebpageObject *web =  [WXWebpageObject object];
    web.webpageUrl = self.URL;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.title;
    message.description = self.description;
    message.thumbImage = self.thumbImage;
    message.mediaTagName = self.mediaID;
    message.mediaObject = web;
    return message;
}

@end

@implementation AKWeChatShareMusic

- (WXMediaMessage *)message {
    WXMusicObject *music =  [WXMusicObject object];
    music.musicUrl = self.URL;
    music.musicLowBandUrl = self.lowBandURL;
    music.musicDataUrl = self.streamURL;
    music.musicLowBandDataUrl = self.lowBandStreamURL;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.title;
    message.description = self.description;
    message.thumbImage = self.thumbImage;
    message.mediaTagName = self.mediaID;
    message.mediaObject = music;
    return message;
}

@end

@implementation AKWeChatShareVideo

- (WXMediaMessage *)message {
    WXVideoObject *video =  [WXVideoObject object];
    video.videoUrl = self.URL;
    video.videoLowBandUrl = self.lowBandURL;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.title;
    message.description = self.description;
    message.thumbImage = self.thumbImage;
    message.mediaTagName = self.mediaID;
    message.mediaObject = video;
    return message;
}

@end
