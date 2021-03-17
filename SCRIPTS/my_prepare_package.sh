#!/bin/bash

MY_PATH=$(pwd)

# 调整 02 脚本内容
## 移除 fuck 组件
sed -i '/fuck/d' 02_prepare_package.sh

# 替换默认设置
pushd ${MY_PATH}/../PATCH/duplicate/addition-trans-zh-r2s/files
  rm -fr zzz-default-settings
  cp ${MY_PATH}/../PATCH/zzz-default-settings ./
popd


# 执行 02 脚本
/bin/bash 02_prepare_package.sh
/bin/bash 02_R2S.sh


# 调整luci依赖，去除 luci-app-opkg，替换 luci-theme-bootstrap 为 luci-theme-argon
sed -i 's/+luci-app-opkg //' ./feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/' ./feeds/luci/collections/luci/Makefile

# 主题
rm -fr package/new/luci-theme-argon
git clone -b master --single-branch https://github.com/jerrykuku/luci-theme-argon package/new/luci-theme-argon
pushd package/new/luci-theme-argon/luasrc/view/themes/argon
  # 移除 footer.htm 底部文字
  sed -i '/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\">/d' footer.htm
  sed -i '/<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\">/d' footer.htm
  sed -i '/<%= ver.distversion %>/d' footer.htm
  # 移除 footer_login.htm 底部文字
  sed -i '/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\">/d' footer_login.htm
  sed -i '/<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\">/d' footer_login.htm
  sed -i '/<%= ver.distversion %>/d' footer_login.htm
popd
#sed -i '/<a href=\"https:\/\/github.com\/openwrt\/luci\">/d' feeds/luci/themes/luci-theme-bootstrap/luasrc/view/themes/bootstrap/footer.htm
## 设置首页背景
mkdir -p package/base-files/files/www/luci-static/argon/background
cp ${MY_PATH}/../PATCH/background.jpg package/base-files/files/www/luci-static/argon/background/ 

# SSRP 微调
pushd package/lean/luci-app-ssr-plus
  ## 替换部分翻译
  sed -i 's/ShadowSocksR Plus+ Settings/Basic Settings/' po/zh-cn/ssr-plus.po
  sed -i 's/ShadowSocksR Plus+ 设置/基本设置/' po/zh-cn/ssr-plus.po
  sed -i '/Customize Netflix IP Url/d' po/zh-cn/ssr-plus.po
  sed -i '/自定义Netflix IP更新URL（默认项目地址：/d' po/zh-cn/ssr-plus.po
  sed -i '/<h3>Support SS/d' po/zh-cn/ssr-plus.po
  sed -i '/<h3>支持 SS/d' po/zh-cn/ssr-plus.po
  ## 修改部分内容
  sed -i 's/Map("shadowsocksr", translate("ShadowSocksR Plus+ Settings"), translate("<h3>Support SS\/SSR\/V2RAY\/TROJAN\/NAIVEPROXY\/SOCKS5\/TUN etc.<\/h3>"))/Map("shadowsocksr", translate("Basic Settings"))/' luasrc/model/cbi/shadowsocksr/client.lua
  pushd luasrc/model/cbi/shadowsocksr
    sed -i '/Clang.CN.CIDR/a\o:value("https://raw.sevencdn.com/QiuSimons/Chnroute/master/dist/chnroute/chnroute.txt", translate("QiuSimons/Chnroute"))' advanced.lua
    sed -i '/Customize Netflix IP Url/d' advanced.lua
  popd
  ## 全局替换 ShadowSocksR Plus+ 为 SSRPlus
  ssfiles="$(find 2>"/dev/null")"
  for ssf in ${ssfiles}; do
    if [ -f "$ssf" ]; then
      sed -i 's/ShadowSocksR Plus+/SSRPlus/gi' "$ssf"
    fi
  done
popd

# OpenClash
rm -fr package/new/luci-app-openclash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/new/luci-app-openclash
## 修改 DashBoard 默认地址和密码
pushd package/new/luci-app-openclash/root/usr/share/openclash/dashboard/assets
  sed -i 's/e=D(\"externalControllerAddr\",\"127.0.0.1\"),t=D(\"externalControllerPort\",\"9090\"),n=D(\"secret\",\"\")/e=D(\"externalControllerAddr\",\"nanopi-r2s.lan\"),t=D(\"externalControllerPort\",\"9090\"),n=D(\"secret\",\"123456\")/' *js
  sed -i 's/hostname:\"127.0.0.1\",port:\"9090\",secret:\"\"/hostname:\"nanopi-r2s.lan\",port:\"9090\",secret:\"123456\"/' *js
popd
## 预置内核
mkdir -p package/base-files/files/etc/openclash/core
clash_dev_url=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/Clash | grep /clash-linux-armv8 | sed 's/.*url\": \"//g' | sed 's/\"//g')
clash_game_url=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/TUN | grep /clash-linux-armv8 | sed 's/.*url\": \"//g' | sed 's/\"//g')
clash_premium_url=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/TUN-Premium | grep /clash-linux-armv8 | sed 's/.*url\": \"//g' | sed 's/\"//g')
wget -qO- $clash_dev_url | tar xOvz > package/base-files/files/etc/openclash/core/clash
wget -qO- $clash_game_url | tar xOvz > package/base-files/files/etc/openclash/core/clash_game
wget -qO- $clash_premium_url | gunzip -c > package/base-files/files/etc/openclash/core/clash_tun
chmod +x package/base-files/files/etc/openclash/core/clash*

# 网易云音乐解锁
git clone --depth 1 https://github.com/immortalwrt/luci-app-unblockneteasemusic.git package/new/luci-app-unblockneteasemusic
pushd package/new/luci-app-unblockneteasemusic
  ## 删除部分描述
  sed -i '/原理：采用/d' luasrc/model/cbi/unblockneteasemusic/unblockneteasemusic.lua
  sed -i '/启用本插件以解除网易云音乐播放限制/d' luasrc/model/cbi/unblockneteasemusic/unblockneteasemusic.lua
  ## 全局替换 解除网易云音乐播放限制 为 网易云音乐解锁
  ubfiles="$(find 2>"/dev/null")"
  for ubf in ${ubfiles}; do
    if [ -f "$ubf" ]; then
      sed -i 's/解除网易云音乐播放限制/网易云音乐解锁/g' "$ubf"
    fi
  done
popd

# 替换为 master 分支的 luci-app-samba4
rm -fr feeds/luci/applications/luci-app-samba4
svn co https://github.com/openwrt/luci/trunk/applications/luci-app-samba4 feeds/luci/applications/luci-app-samba4

# 移除 LuCI 部分页面
pushd feeds/luci/modules/luci-mod-system/root/usr/share/luci/menu.d
  rm -fr luci-mod-system.json
  cp ${MY_PATH}/../PATCH/luci-mod-system.json ./
popd
pushd feeds/luci/modules/luci-mod-system/htdocs/luci-static/resources/view/system
  rm -fr flash.js mounts.js
popd
pushd feeds/luci/modules/luci-mod-system/luasrc/model/cbi/admin_system
  rm -fr backupfiles.lua
popd

unset MY_PATH
exit 0

