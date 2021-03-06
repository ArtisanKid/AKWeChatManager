//
//  AKWeChatShare.h
//  Pods
//
//  Created by 李翔宇 on 2017/1/17.
//
//

#import <Foundation/Foundation.h>
#import "AKWeChatShareProtocol.h"

/**
 wiki:https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419317332&token=&lang=zh_CN
 */

#pragma mark - AKWeChatShareText

@interface AKWeChatShareText : NSObject<AKWeChatShareProtocol>

@property (nonatomic, copy) NSString *text;

@end

#pragma mark - AKWeChatShareImage

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

#pragma mark - AKWeChatShareURL

@interface AKWeChatShareURL: NSObject<AKWeChatShareProtocol>

/**
 媒体标识，长度不能超过64字节
 */
@property (nonatomic, copy) NSString *mediaID;

/**
 标题，长度不能超过512字节
 */
@property (nonatomic, copy) NSString *title;

/**
 描述内容，长度不能超过1K
 */
@property (nonatomic, copy) NSString *detail;

/**
 缩略图，大小不能超过32K
 */
@property (nonatomic, copy) UIImage *thumbImage;

/**
 网页的url地址，长度不能超过10K
 支持普通网页，音乐网页，视频网页等
 */
@property (nonatomic, copy) NSString *URL;

@end

#pragma mark - AKWeChatShareWeb

@interface AKWeChatShareWeb : AKWeChatShareURL

@end

#pragma mark - AKWeChatShareAudio

@interface AKWeChatShareAudio : AKWeChatShareURL

/**
 音乐与视频的低带网页url地址，长度不能超过10K
 */
@property (nonatomic, copy) NSString *lowBandURL;

/**
 音乐数据的url地址，长度不能超过10K
 */
@property (nonatomic, copy) NSString *streamURL;

/**
 音乐数据的url地址，长度不能超过10K
 */
@property (nonatomic, copy) NSString *lowBandStreamURL;

@end

#pragma mark - AKWeChatShareVideo

@interface AKWeChatShareVideo : AKWeChatShareURL

/**
 音乐与视频的低带网页url地址，长度不能超过10K
 */
@property (nonatomic, copy) NSString *lowBandURL;

@end
