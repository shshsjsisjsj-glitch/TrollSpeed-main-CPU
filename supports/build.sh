#!/bin/sh

# This script is used to build the TrollSpeed app and create a tipa file with Xcode.

#打包的app目录
export appPath=$CODESIGNING_FOLDER_PATH
#签名root文件目录
export entitlementsPath=$PROJECT_DIR/supports/entitlements.plist
#执行签名脚本
codesign -s - --entitlements "${entitlementsPath}" -f "${appPath}"
#签名打包后 拷贝到指定目录
cp -r "${appPath}" /Users/shisange/Library/Mobile\ Documents/com\~apple\~CloudDocs/Payload
#定位到目录 压缩成zip 改成ipa 巨魔安装
cd /Users/shisange/Library/Mobile\ Documents/com\~apple\~CloudDocs/ && zip -r HUD.ipa Payload
