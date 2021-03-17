# NanoPi-R2S 的 OpenWrt 极简固件  
基于 [nicholas-opensource/OpenWrt-Autobuild](https://github.com/nicholas-opensource/OpenWrt-Autobuild) 对 [openwrt/openwrt](https://github.com/openwrt/openwrt) v21.02 进行定制编译  

## 固件特性  
1. 设置主机名为 `NanoPi-R2S`  
2. 默认 LAN IP： `192.168.1.1`  
3. 默认用户、密码： `root` `无`  
4. 插件仅包含： [`OpenClash`](https://github.com/vernesong/OpenClash) [`SSRPlus`](https://github.com/fw876/helloworld) [`Samba4网络共享`](https://github.com/openwrt/luci/tree/master/applications/luci-app-samba4) [`网易云音乐解锁`](https://github.com/immortalwrt/luci-app-unblockneteasemusic)  
7. 主题仅包含 [`luci-theme-argon`](https://github.com/jerrykuku/luci-theme-argon)  
8. 默认关闭 `IPv6`  
9. 移除上游的 [`fuck`](https://github.com/nicholas-opensource/OpenWrt-Autobuild/blob/main/PATCH/new/script/fuck) 组件  

## 感谢  
   感谢所有提供了上游项目代码和给予了帮助的大佬们  
