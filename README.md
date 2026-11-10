# HGAdOnly — 红果只去广告 + 会员伪装 + 跳过激励广告 + 默认 1080p

从 hongguofn 2.2.2 里提取「去广告」, 再加三个新功能。没有设置页、没有倍速、没有界面净化、没有「关于与支持」。

## 功能

1. **去广告** — hongguofn 的机制: 不拦网络请求, hook 红果 App 自己的广告开关 —— 12 个 AB 测试 / 广告配置类的 57 个 BOOL getter, 全部强制返回 NO (`SSBizAdConfigHelper` 39 个、`SSBizVideoAdABTestHelper` 4 个……完整列表见 `src/HGAdOnly.m`)。
2. **会员伪装** — `SSUser` 的 VIP 状态 getter (`isVip`、`hasAnyVip`、`hasAnySubVip`、`isAdFreeSubVip`、`isSubVip:`、`isVipSuperThan:` 等) 强制返回 YES。会员标识、免广告这类客户端判断会生效; **VIP 专享剧集的播放地址由服务端按账号校验, 服务端不认的话仍播不了, 以实测为准。**
3. **跳过激励广告** — `BDMannorUnionRewardedVideoManager` 收到播放激励视频的请求时不播视频, 直接回调 delegate 的 `luckyRewardedVideoAdBecomeEffective:` (已看够, 可领奖) 再回调 `luckyRewardedVideoAd:didClickCloseWithInfo:` (已关闭)。奖励是否到账取决于服务端校验, 以实测为准。
4. **默认清晰度 1080p** — `SSShortVideoResolutionStrategy` 的建议清晰度返回 `@"1080P"`。只改"默认建议", 用户手动选的清晰度仍按用户选择的走。

## 构建

GitHub Actions (macOS) 自动编译, push 即构建, 打 tag `v*` 出 Release。本地 Mac:

```bash
./build.sh
```

产出 `HGAdOnly.dylib` (TrollStore + TrollFools 注入) 和 `HGAdOnly-1.1.1-iphoneos-arm64.deb` (越狱机 rootless)。

Filter: `com.phoenix.video` (红果短剧) + `com.kylin.readnew` (红果漫剧)。
