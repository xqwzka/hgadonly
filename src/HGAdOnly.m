// HGAdOnly.m — v1.1.1 (fix: rewarded-ad skip no longer calls the delegate
// synchronously inside showRewardedVideoAdWith:params:delegate: — the manager
// state is not ready at that point and it crashed. Now the reward callback is
// dispatched async to the main queue, and the close callback is NOT faked
// (there is no presented ad VC to dismiss).
// 1. 去广告: hongguofn 2.2.2 的 57 组广告开关 (12 个类), 强制返回 NO。
// 2. 会员伪装: SSUser 的 VIP 状态 getter 强制返回 YES (均已验为 BOOL 返回)。
//    VIP 专享剧集的播放地址由服务端按账号校验, 服务端不认仍播不了, 以实测为准。
// 3. 跳过激励广告: 收到播放请求时不播视频, 异步回调 delegate 的
//    luckyRewardedVideoAdBecomeEffective: (已看够, 可领奖)。奖励是否到账取决
//    于服务端校验, 以实测为准。
// 4. 默认清晰度 1080p: 建议清晰度返回 @"1080P", 只改默认建议。

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <dispatch/dispatch.h>

// --- ad flags: always NO ---
static BOOL hg_returnNO(id self, SEL _cmd) { return NO; }

// --- VIP: always YES ---
static BOOL hg_returnYES(id self, SEL _cmd) { return YES; }
static BOOL hg_returnYES1(id self, SEL _cmd, id arg) { return YES; }

// --- default resolution: 1080P ---
static NSString *hg_resolution1080P(id self, SEL _cmd) { return @"1080P"; }

// --- skip rewarded video ad: grant the reward async, do not fake a close ---
static void hg_skipRewardedAd(id self, SEL _cmd, id ad, id params, id delegate) {
    if (!delegate || !ad) return;
    id d = delegate;
    id a = ad;
    dispatch_async(dispatch_get_main_queue(), ^{
        SEL eff = NSSelectorFromString(@"luckyRewardedVideoAdBecomeEffective:");
        if (eff && [d respondsToSelector:eff]) {
            ((void (*)(id, SEL, id))objc_msgSend)(d, eff, a);
        }
    });
}

static void hg_hookFlag(const char *className, const char *selName) {
    Class cls = objc_getClass(className);
    if (!cls) return;
    SEL sel = sel_registerName(selName);
    if (!sel) return;
    Method m = class_getInstanceMethod(cls, sel);
    if (m) method_setImplementation(m, (IMP)hg_returnNO);
    Method cm = class_getClassMethod(cls, sel);
    if (cm) method_setImplementation(cm, (IMP)hg_returnNO);
}

static void hg_hookYES(const char *className, const char *selName) {
    Class cls = objc_getClass(className);
    if (!cls) return;
    SEL sel = sel_registerName(selName);
    if (!sel) return;
    Method m = class_getInstanceMethod(cls, sel);
    if (m) method_setImplementation(m, (IMP)hg_returnYES);
    Method cm = class_getClassMethod(cls, sel);
    if (cm) method_setImplementation(cm, (IMP)hg_returnYES);
}

static void hg_hookYES1(const char *className, const char *selName) {
    Class cls = objc_getClass(className);
    if (!cls) return;
    SEL sel = sel_registerName(selName);
    if (!sel) return;
    Method m = class_getInstanceMethod(cls, sel);
    if (m) method_setImplementation(m, (IMP)hg_returnYES1);
    Method cm = class_getClassMethod(cls, sel);
    if (cm) method_setImplementation(cm, (IMP)hg_returnYES1);
}

static void hg_hookString(const char *className, const char *selName, IMP repl) {
    Class cls = objc_getClass(className);
    if (!cls) return;
    SEL sel = sel_registerName(selName);
    if (!sel) return;
    Method m = class_getInstanceMethod(cls, sel);
    if (m) method_setImplementation(m, repl);
    Method cm = class_getClassMethod(cls, sel);
    if (cm) method_setImplementation(cm, repl);
}

__attribute__((constructor))
static void hg_adonly_init(void) {
    static const char *pairs[][2] = {
        {"SSBizAdConfigHelper", "TopViewEnable"},
        {"SSBizAdConfigHelper", "enableShortVideoPlotTouchAd"},
        {"SSBizAdConfigHelper", "enableHomePageFeedAd"},
        {"SSBizAdConfigHelper", "enableShortStroyAd"},
        {"SSBizAdConfigHelper", "enableVideoAlbumAd"},
        {"SSBizAdConfigHelper", "enablePauseAd"},
        {"SSBizAdConfigHelper", "enableLandscapeOuterFeedAd"},
        {"SSBizAdConfigHelper", "enableMultiAdRequest"},
        {"SSBizAdConfigHelper", "enableShortVideoAdBaseCommonSwitch"},
        {"SSBizAdConfigHelper", "enableRewardVideoPreload"},
        {"SSBizAdConfigHelper", "enableRewardMoreVideoPreload"},
        {"SSBizAdConfigHelper", "enable_pub_book_ad"},
        {"SSBizAdConfigHelper", "enableReaderFeedScrollAd"},
        {"SSBizAdConfigHelper", "enableMultiAdRequestInReaderFlowAd"},
        {"SSBizAdConfigHelper", "enableReaderAttachmentAd"},
        {"SSBizAdConfigHelper", "enableSideBarPatchAd"},
        {"SSBizAdConfigHelper", "enablePatchAd"},
        {"SSBizAdConfigHelper", "enableSeriesCommentAd"},
        {"SSBizAdConfigHelper", "enableCommentAdPreloadForFirstScreen"},
        {"SSBizAdConfigHelper", "enableComicsAd"},
        {"SSBizAdConfigHelper", "awemeHostAdEnable"},
        {"SSBizAdConfigHelper", "brandTopViewEnable"},
        {"SSBizAdConfigHelper", "enable_topview"},
        {"SSBizAdConfigHelper", "buzz_should_ad_image_preload"},
        {"SSBizAdConfigHelper", "chapterMultiTypeAdEnable"},
        {"SSBizAdConfigHelper", "enableAdVideoUsePreload"},
        {"SSBizAdConfigHelper", "brandChapterFrontAdSwitch"},
        {"SSBizAdConfigHelper", "innerLiveAdEnable"},
        {"SSBizAdConfigHelper", "gameCenterAdSwitch"},
        {"SSBizAdConfigHelper", "enableBannerRequestMannorInReaderFeed"},
        {"SSBizAdConfigHelper", "shortVideoAdEnable"},
        {"SSBizAdConfigHelper", "enableVideoAdCSJ"},
        {"SSBizAdConfigHelper", "enableShortVideoAdSDK"},
        {"SSBizAdConfigHelper", "residualFlowIsOpen"},
        {"SSBizAdConfigHelper", "residualFlowIsForceReq"},
        {"SSBizAdConfigHelper", "landscapeInsertAdEnable"},
        {"SSBizAdConfigHelper", "isPreloadEnable"},
        {"SSBizAdConfigHelper", "isEnableSifPreloadLandingPage"},
        {"SSBizAdConfigHelper", "isEnablePreloadSfLynxPage"},
        {"SSAdABTestHelper", "videoListenFrontAdEnable"},
        {"SSBizVideoAdABTestHelper", "videoEnablePatchAdsV647"},
        {"SSBizVideoAdABTestHelper", "enableShortVideoPauseAd"},
        {"SSBizVideoAdABTestHelper", "enableNaturalAdLandscapeInsert"},
        {"SSBizVideoAdABTestHelper", "enableNaturalAdUUIDInsertV737"},
        {"SSBizAudioAdABTestHelper", "ttsAutoAdEnablePopScene"},
        {"SSBizAudioAdABTestHelper", "canAddTimeAd"},
        {"SSBizAudioAdABTestHelper", "enableListenLynxPreload"},
        {"SSBizAudioAdABTestService", "enableBelowReadFlowAd"},
        {"SSVipABTestHelper", "enableMidAdInSingleSeriesPay"},
        {"SSCommonABTestHelper", "insert_screen_ad_pop_cfg"},
        {"IESECShopABTestManager", "enableAdShopApiPreload"},
        {"IESECShopABTestManager", "enableAdShopResourcePreload"},
        {"SSAdSettingsRewardAdParamsConfig", "inspire_rewarded_more_ad_preload_enable"},
        {"SSCommentSeriesAdConfig", "enable_pre_request_comment_ad"},
        {"SSAdSettingsAdLynxConfig", "preloadEnable"},
        {"SSAdSettingsLandingConfig", "is_enable_sif_landing_page_preload"},
        {"SSAdSettingsLandingConfig", "is_enable_preload_sf_lynx_page"},
    };
    for (size_t i = 0; i < sizeof(pairs) / sizeof(pairs[0]); i++) {
        hg_hookFlag(pairs[i][0], pairs[i][1]);
    }

    static const char *vip0[] = {
        "isVip",
        "hasAnyVip",
        "hasAnySubVip",
        "isAdFreeSubVip",
        "isPublishSubVip",
        "isShortStroySubVip",
        "isAdViPAvailable",
    };
    for (size_t i = 0; i < sizeof(vip0) / sizeof(vip0[0]); i++) {
        hg_hookYES("SSUser", vip0[i]);
    }
    hg_hookYES1("SSUser", "isSubVip:");
    hg_hookYES1("SSUser", "isVipSuperThan:");

    hg_hookString("SSShortVideoResolutionStrategy", "suggestResolutionTypeString", (IMP)hg_resolution1080P);
    hg_hookString("BDMannorUnionRewardedVideoManager", "showRewardedVideoAdWith:params:delegate:", (IMP)hg_skipRewardedAd);
}
