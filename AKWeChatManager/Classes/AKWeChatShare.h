//
//  AKWeChatShare.h
//  Pods
//
//  Created by 李翔宇 on 2017/1/17.
//
//

#import <Foundation/Foundation.h>
#import "AKWeChatShareProtocol.h"

@interface AKWeChatShare : NSObject<AKWeChatShareProtocol>

@end

@interface AKWeChatShareText : NSObject<AKWeChatShareProtocol>

@property (nonatomic, copy) NSString *text;

@end

@interface AKWeChatShareImage : NSObject<AKWeChatShareProtocol>

/**
缩略图，大小不能超过32K
*/
@property (nonatomic, strong) UIImage *thumbImage;

/**
 图片真实数据内容，大小不能超过10M
 */
@property (nonatomic, strong) UIImage *image;

@end

@interface AKWeChatShareMedia : NSObject

/**
 标题，长度不能超过512字节
 */
@property (nonatomic, retain) NSString *title;

/**
 描述内容，长度不能超过1K
 */
@property (nonatomic, retain) NSString *description;

/**
 缩略图，大小不能超过32K
 */
@property (nonatomic, retain) UIImage *thumbImage;

/**
 媒体标识，长度不能超过64字节
 */
@property (nonatomic, retain) NSString *mediaID;

@end

@interface AKWeChatShareWeb : AKWeChatShareMedia<AKWeChatShareProtocol>

/**
 网页的url地址，长度不能超过10K
 支持普通网页，音乐网页，视频网页等
 */
@property (nonatomic, retain) NSString *URL;

/**
 音乐与视频的低带网页url地址，长度不能超过10K
 */
@property (nonatomic, retain) NSString *mediaLowBandURL;

@end

@interface AKWeChatShareMusic : AKWeChatShareWeb

/**
 音乐数据的url地址，长度不能超过10K
 */
@property (nonatomic, retain) NSString *dataURL;

/**
 音乐数据的url地址，长度不能超过10K
 */
@property (nonatomic, retain) NSString *lowBandDataURL;

@end

@interface AKWeChatShareVideo : AKWeChatShareWeb

@end
