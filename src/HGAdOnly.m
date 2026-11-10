// HGAdOnly.m — v1.2.0 (minimal: ad-removal + default 1080p only)
// 1. 去广告: hongguofn 2.2.2 的 57 组广告开关 (12 个类), 强制返回 NO。
// 2. 默认清晰度 1080p: 建议清晰度返回 @"1080P", 只改默认建议。
// 已去掉: 会员伪装、跳过激励广告、屏蔽热更新挂件入口。

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

// --- ad flags: always NO ---
static BOOL hg_returnNO(id self, SEL _cmd) { return NO; }

// --- default resolution: 1080P ---
static NSString *hg_resolution1080P(id self, SEL _cmd) { return @"1080P"; }

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

    hg_hookString("SSShortVideoResolutionStrategy", "suggestResolutionTypeString", (IMP)hg_resolution1080P);
}
