#!/bin/bash
# 在 Mac + Xcode 上跑, 一条命令出两个东西:
#   1. HGAdOnly-1.2.0-iphoneos-arm64.deb  (越狱机, rootless /var/jb 路径)
#   2. HGAdOnly.dylib                    (TrollStore + TrollFools 注入用)
# 这台 Linux 编不出 iOS arm64 dylib, 没有 iOS SDK, 所以只出源码 + 打包脚本, 不出二进制。
set -e
cd "$(dirname "$0")"

xcrun -sdk iphoneos clang -arch arm64 -miphoneos-version-min=12.0 \
    -dynamiclib -install_name @rpath/HGAdOnly.dylib \
    -framework Foundation -fobjc-arc \
    -o HGAdOnly.dylib src/HGAdOnly.m
codesign --force --sign - --timestamp=none HGAdOnly.dylib

# --- deb (rootless, Dopamine / palera1n rootless; 老 rootful 越狱把 var/jb 改成空, 即根目录) ---
rm -rf deb/var
mkdir -p deb/var/jb/Library/MobileSubstrate/DynamicLibraries
cp HGAdOnly.dylib deb/var/jb/Library/MobileSubstrate/DynamicLibraries/
cp DynamicLibraries/HGAdOnly.plist deb/var/jb/Library/MobileSubstrate/DynamicLibraries/
dpkg-deb -b deb HGAdOnly-1.2.0-iphoneos-arm64.deb

echo "built:"
ls -l HGAdOnly.dylib HGAdOnly-1.2.0-iphoneos-arm64.deb
file HGAdOnly.dylib
