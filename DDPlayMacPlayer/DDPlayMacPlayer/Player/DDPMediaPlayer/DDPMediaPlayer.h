//
//  DDPMediaPlayer.h
//  test
//
//  Created by JimHuang on 16/3/4.
//  Copyright © 2016年 JimHuang. All rights reserved.
//
#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, DDPMediaPlayerStatus) {
    DDPMediaPlayerStatusPlaying,
    DDPMediaPlayerStatusPause,
    DDPMediaPlayerStatusStop,
    DDPMediaPlayerStatusNextEpisode,
//    DDPMediaPlayerStatusBuffering
};

typedef NS_ENUM(NSUInteger, DDPMediaType) {
    DDPMediaTypeLocaleMedia,
    DDPMediaTypeNetMedia,
};

typedef NS_ENUM(NSUInteger, DDPSnapshotType) {
    DDPSnapshotTypeJPG,
    DDPSnapshotTypePNG,
    DDPSnapshotTypeBMP,
    DDPSnapshotTypeTIFF
};


typedef void(^SnapshotCompleteBlock)(NSImage *image, NSError *error);


/**
 转换秒数为指定格式

 @param totalSeconds 秒数
 @return 指定格式
 */
CG_INLINE NSString *ddp_mediaFormatterTime(NSInteger totalSeconds) {
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds - seconds) / 60;
    
    return [NSString stringWithFormat:@"%.2ld:%.2ld", (long)minutes, (long)seconds];
}

@class DDPMediaPlayer;
@protocol DDPMediaPlayerDelegate <NSObject>
@optional
/**
 *  监听时间变化
 *
 *  @param player    Player
 *  @param currentTime  当前时间
 *  @param totalTime 总时间
 */
- (void)mediaPlayer:(DDPMediaPlayer *)player currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

- (void)mediaPlayer:(DDPMediaPlayer *)player statusChange:(DDPMediaPlayerStatus)status;

- (void)mediaPlayer:(DDPMediaPlayer *)player rateChange:(float)rate;

- (void)mediaPlayer:(DDPMediaPlayer *)player userJumpWithTime:(NSTimeInterval)time;
@end


@interface DDPMediaPlayer : NSObject
@property (strong, nonatomic) NSView *mediaView;
@property (strong, nonatomic) NSURL *mediaURL;
@property (assign, nonatomic) CGFloat volume;
@property (assign, nonatomic) NSInteger subtitleDelay;

/**
 字幕索引
 */
@property (strong, nonatomic, readonly) NSArray <NSNumber *>*subtitleIndexs;

/**
 字幕名称
 */
@property (strong, nonatomic, readonly) NSArray <NSString *>*subtitleTitles;

/**
 当前字幕索引
 */
@property (assign, nonatomic) int currentSubtitleIndex;


/**
 音频索引
 */
@property (strong, nonatomic, readonly) NSArray <NSNumber *>*audioChannelIndexs;

/**
 音频名称
 */
@property (strong, nonatomic, readonly) NSArray <NSString *>*audioChannelTitles;

/**
 当前音频索引
 */
@property (assign, nonatomic) int currentAudioChannelIndex;




@property (assign, nonatomic) float speed;

/**
 宽高比
 */
@property (assign, nonatomic) CGSize videoAspectRatio;

@property (assign, readonly) CGSize videoSize;
/**
 *  位置 0 ~ 1
 */
- (CGFloat)position;
/**
 *  设置媒体位置
 *
 *  @param position          位置 0 ~ 1
 *  @param completionHandler 完成之后的回调
 */
- (void)setPosition:(CGFloat)position completionHandler:(void(^)(NSTimeInterval time))completionHandler;
/**
 *  协议返回的时间格式 默认"mm:ss"
 */
@property (strong, nonatomic) NSString *timeFormat;
@property (weak, nonatomic) id <DDPMediaPlayerDelegate>delegate;
- (DDPMediaPlayerStatus)status;
- (NSTimeInterval)length;
- (NSTimeInterval)currentTime;
- (DDPMediaType)mediaType;
/**
 *  基于当前时间跳转
 *
 *  @param value 增加的值
 */
- (void)jump:(int)value completionHandler:(void(^)(NSTimeInterval time))completionHandler;

/**
 设置播放时间

 @param time 播放时间
 @param completionHandler 完成回调
 */
- (void)setCurrentTime:(int)time completionHandler:(void(^)(NSTimeInterval time))completionHandler;

/**
 *  音量增加
 *
 *  @param value 增加的值
 */
- (void)volumeJump:(CGFloat)value;
- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)stop;
/**
 *  保存截图
 *
 *  @param size  宽 如果为 CGSizeZero则为原视频的宽高
 *  @param completion 高 如果填0则为原视频高
 */
- (void)saveVideoSnapshotwithSize:(CGSize)size completionHandler:(SnapshotCompleteBlock)completion;
/**
 *  加载字幕文件
 *
 *  @param path 字幕路径
 *
 *  @return 是否成功 0失败 1成功
 */
- (int)openVideoSubTitlesFromFile:(NSURL *)path;
/**
 *  初始化
 *
 *  @param mediaURL 媒体路径 可以为本地视频或者网络视频
 *
 *  @return self
 */
- (instancetype)initWithMediaURL:(NSURL *)mediaURL;


/**
 解析
 */
- (void)parseWithCompletion:(void(^)(void))completion;

@end
