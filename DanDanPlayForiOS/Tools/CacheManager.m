//
//  CacheManager.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "CacheManager.h"
#import "UIFont+Tools.h"

static NSString *const userSaveKey = @"login_user";
static NSString *const danmakuCacheTimeKey = @"damaku_cache_time";
static NSString *const autoRequestThirdPartyDanmakuKey = @"auto_request_third_party_danmaku";
static NSString *const danmakuFiltersKey = @"danmaku_filters";
static NSString *const openFastMatchKey = @"open_fast_match";
static NSString *const danmakuFontKey = @"danmaku_font";
static NSString *const danmakuOpacityKey = @"danmaku_opacity";
static NSString *const danmakuFontIsSystemFontKey = @"danmaku_font_is_system_font";
static NSString *const danmakuShadowStyleKey = @"danmaku_shadow_style";
static NSString *const subtitleProtectAreaKey = @"subtitle_protect_area";
static NSString *const danmakuSpeedKey = @"danmaku_speed";
static NSString *const playerPlayKey = @"player_play";
static NSString *const folderCacheKey = @"folder_cache";

NSString *const videoNameKey = @"video_name";
NSString *const videoEpisodeIdKey = @"video_episode_id";


@interface CacheManager ()
@property (strong, nonatomic) YYCache *cache;
@end

@implementation CacheManager

+ (instancetype)shareCacheManager {
    static CacheManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

#pragma mark - 懒加载

- (JHFile *)rootFile {
    if (_rootFile == nil) {
        _rootFile = [[JHFile alloc] init];
        _rootFile.type = JHFileTypeFolder;
        _rootFile.fileURL = [[UIApplication sharedApplication] documentsURL];
    }
    return _rootFile;
}

- (YYCache *)cache {
    if (_cache == nil) {
        _cache = [[YYCache alloc] initWithName:@"dandanplay_cache"];
    }
    return _cache;
}

- (void)setUser:(JHUser *)user {
    [self.cache setObject:user forKey:userSaveKey withBlock:nil];
}

- (JHUser *)user {
    return (JHUser *)[self.cache objectForKey:userSaveKey];
}

- (void)setDanmakuFont:(UIFont *)danmakuFont {
    [self.cache setObject:danmakuFont forKey:danmakuFontKey withBlock:nil];
    [self.cache setObject:@(danmakuFont.isSystemFont) forKey:danmakuFontIsSystemFontKey withBlock:nil];
}

- (UIFont *)danmakuFont {
    UIFont *font = (UIFont *)[self.cache objectForKey:danmakuFontKey];
    if (font == nil) {
        font = NORMAL_SIZE_FONT;
        font.isSystemFont = YES;
        self.danmakuFont = font;
    }
    else {
        NSNumber *num = (NSNumber *)[self.cache objectForKey:danmakuFontIsSystemFontKey];
        font.isSystemFont = num.boolValue;
    }
    
    return font;
}

- (void)setDanmakuShadowStyle:(JHDanmakuShadowStyle)danmakuShadowStyle {
    [self.cache setObject:@(danmakuShadowStyle) forKey:danmakuShadowStyleKey withBlock:nil];
}

- (JHDanmakuShadowStyle)danmakuShadowStyle {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:danmakuShadowStyleKey];
    if (num == nil) {
        num = @(JHDanmakuShadowStyleGlow);
        self.danmakuShadowStyle = JHDanmakuShadowStyleGlow;
    }
    return [num integerValue];
}

- (void)setSubtitleProtectArea:(BOOL)subtitleProtectArea {
    [self.cache setObject:@(subtitleProtectArea) forKey:subtitleProtectAreaKey withBlock:nil];
}

- (BOOL)subtitleProtectArea {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:subtitleProtectAreaKey];
    if (num == nil) {
        num = @(YES);
        self.subtitleProtectArea = YES;
    }
    return [num boolValue];
}

- (void)setDanmakuCacheTime:(NSUInteger)danmakuCacheTime {
    [self.cache setObject:@(danmakuCacheTime) forKey:danmakuCacheTimeKey withBlock:nil];
}

- (NSUInteger)danmakuCacheTime {
    NSNumber *time = (NSNumber *)[self.cache objectForKey:danmakuCacheTimeKey];
    if (time == nil) {
        time = @(7);
        self.danmakuCacheTime = 7;
    }
    
    return [time unsignedIntegerValue];
}

- (void)setAutoRequestThirdPartyDanmaku:(BOOL)autoRequestThirdPartyDanmaku {
    [self.cache setObject:@(autoRequestThirdPartyDanmaku) forKey:autoRequestThirdPartyDanmakuKey withBlock:nil];
}

- (BOOL)autoRequestThirdPartyDanmaku {
    NSNumber *autoRequestThirdPartyDanmaku = (NSNumber *)[self.cache objectForKey:autoRequestThirdPartyDanmakuKey];
    if (autoRequestThirdPartyDanmaku == nil) {
        autoRequestThirdPartyDanmaku = @(YES);
        self.autoRequestThirdPartyDanmaku = YES;
    }
    
    return [autoRequestThirdPartyDanmaku boolValue];
}

- (NSDictionary *)episodeInfoWithVideoModel:(VideoModel *)model {
    if (model == nil) return 0;
    
    NSDictionary *dic = (NSDictionary *)[self.cache objectForKey:[NSString stringWithFormat:@"video_model_%@", model.md5]];
    return dic;
}

- (void)saveEpisodeId:(NSUInteger)episodeId
          episodeName:(NSString *)episodeName
           videoModel:(VideoModel *)model {
    if (model.md5.length == 0 || episodeId == 0) return;
    
    if (episodeName.length == 0) {
        episodeName = @"";
    }
    
    NSDictionary *dic = @{videoNameKey : episodeName , videoEpisodeIdKey : @(episodeId)};
    
    [self.cache setObject:dic forKey:[NSString stringWithFormat:@"video_model_%@", model.md5] withBlock:nil];
}

- (NSArray<JHFilter *> *)danmakuFilters {
    return (NSArray *)[self.cache objectForKey:danmakuFiltersKey];
}

- (void)addDanmakuFilter:(JHFilter *)danmakuFilter {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:(NSArray *)[self.cache objectForKey:danmakuFiltersKey]];
    [arr addObject:danmakuFilter];
    [self.cache setObject:arr forKey:danmakuFiltersKey withBlock:nil];
}

- (void)removeDanmakuFilter:(JHFilter *)danmakuFilter {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:(NSArray *)[self.cache objectForKey:danmakuFiltersKey]];
    [arr removeObject:danmakuFilter];
    [self.cache setObject:arr forKey:danmakuFiltersKey withBlock:nil];
}

- (void)setOpenFastMatch:(BOOL)openFastMatch {
    [self.cache setObject:@(openFastMatch) forKey:openFastMatchKey withBlock:nil];
}

- (BOOL)openFastMatch {
    NSNumber * num = (NSNumber *)[self.cache objectForKey:openFastMatchKey];
    if (num == nil) {
        num = @(YES);
        self.openFastMatch = YES;
    }
    return num.boolValue;
}

- (float)danmakuSpeed {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:danmakuSpeedKey];
    if (num == nil) {
        num = @1;
        self.danmakuSpeed = 1;
    }
    
    return num.floatValue;
}

- (void)setDanmakuSpeed:(float)danmakuSpeed {
    [self.cache setObject:@(danmakuSpeed) forKey:danmakuSpeedKey withBlock:nil];
}

- (float)danmakuOpacity {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:danmakuOpacityKey];
    if (num == nil) {
        num = @1;
        self.danmakuOpacity = 1;
    }
    
    return num.floatValue;
}

- (void)setDanmakuOpacity:(float)danmakuOpacity {
    [self.cache setObject:@(danmakuOpacity) forKey:danmakuOpacityKey withBlock:nil];
}

- (void)setPlayMode:(PlayerPlayMode)playMode {
    [self.cache setObject:@(playMode) forKey:playerPlayKey withBlock:nil];
}

- (PlayerPlayMode)playMode {
    NSNumber *num = (NSNumber *)[self.cache objectForKey:playerPlayKey];
    if (num == nil) {
        num = @(PlayerPlayModeOrder);
        self.playMode = PlayerPlayModeOrder;
    }
    
    return num.integerValue;
}

- (NSMutableDictionary *)folderCache {
    NSMutableDictionary <NSString *, NSArray <NSString *>*>*dic = (NSMutableDictionary *)[[CacheManager shareCacheManager].cache objectForKey:folderCacheKey];
    if ([dic isKindOfClass:[NSMutableDictionary class]] == NO) {
        dic = [dic mutableCopy];
        [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
            dic[key] = [obj mutableCopy];
        }];
    }
    return dic;
}

- (void)setFolderCache:(NSMutableDictionary<NSString *, NSArray<NSString *> *> *)folderCache {
    [[CacheManager shareCacheManager].cache setObject:folderCache forKey:folderCacheKey withBlock:nil];
}

@end
