# HGAdOnly — 红果只去广告 + 默认 1080p

从 hongguofn 2.2.2 里提取「去广告」, 再加默认 1080p。没有设置页、没有倍速、没有界面净化、没有「关于与支持」。

1. **去广告** — hongguofn 的机制: 不拦网络请求, hook 红果 App 自己的广告开关 —— 12 个 AB 测试 / 广告配置类的 57 个 BOOL getter, 全部强制返回 NO (`SSBizAdConfigHelper` 39 个、`SSBizVideoAdABTestHelper` 4 个……完整列表见 `src/HGAdOnly.m`)。
2. **默认清晰度 1080p** — `SSShortVideoResolutionStrategy` 的建议清晰度返回 `@"1080P"`。只改"默认建议", 用户手动选的清晰度仍按用户选择的走。

## 安装

- 越狱机: 装 `HGAdOnly-1.2.0-iphoneos-arm64.deb` (rootless)。
- 非越狱 (TrollStore / TrollFools): 注入 `HGKeyFinder.dylib` 同款方式, 用 `HGAdOnly.dylib` (目标 Bundle: `com.phoenix.video` / `com.kylin.readnew`)。

## 构建

GitHub Actions (macOS) 自动构建, Release 里拿 deb 和 dylib。

## 版本

- v1.2.0 — 精简版: 只留去广告 + 默认 1080p, 去掉会员伪装、跳过激励广告、屏蔽热更新挂件入口。
- v1.1.1 — 修复 v1.1.0 闪退 (激励广告回调改异步, 不伪造关闭回调)。
- v1.1.0 — 加会员伪装、跳过激励广告、默认 1080p (闪退, 已废弃)。
- v1.0.0 — 只去广告。
