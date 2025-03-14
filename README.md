<div align="center">
  <img src="https://github.com/user-attachments/assets/8593a0f0-89c5-467c-a88c-fa6f50cf067f" alt="PicHoro Logo">
  <h1>PicHoro</h1>
  <a href="https://github.com/Kuingsmile/PicHoro/releases/latest">
    <img src="https://img.shields.io/github/release/Kuingsmile/PicHoro.svg?style=flat-square" alt="Release Version">
  </a>
</div>

## 简介

PicHoro 是一款基于 Flutter 的手机端云存储平台/图床管理和文件上传/下载工具，最新版本 **V2.4.0**。

- 与 PicGo/PicList 配置互通，可直接扫码导入
- 支持云存储/图床/云服务器平台和网盘管理（通过 [Alist](https://alist.nn.ci/zh/)）
- 提供文件上传、下载管理及多格式链接分享功能

支持多种图片/PDF/文本文件/音视频的在线预览和播放，具体支持的格式请查看[支持的格式列表](https://github.com/Kuingsmile/PicHoro/blob/main/supported_format.md)。

> **桌面端推荐**：如果您需要桌面端图床管理，推荐使用 [PicList](https://github.com/Kuingsmile/PicList)

📘 [项目介绍和配置手册](https://pichoro.horosama.com)

## 支持的图床/存储平台

- [x] 兰空图床V2
- [x] SM.MS
- [x] Github
- [x] Imgur
- [x] 七牛云存储
- [x] 腾讯云COS V5
- [x] 阿里云OSS
- [x] 又拍云存储
- [x] FTP-SSH/SFTP
- [x] 兼容S3 API接口的平台
- [x] Alist V3
- [x] WebDav

## 特色功能

### 核心特性

- **云存储/图床管理** - 新建/删除/修改存储桶，创建/删除目录和文件，上传和下载文件和照片等
- **网盘管理** - 通过 Alist V3 或 WebDav 管理多种网盘
- **图片压缩** - 支持压缩为 webp/jpg/png 格式
- **多格式文件预览** - 包括图片/PDF/文本文件/音视频等
- **SSH/SFTP支持** - 可视化管理文件，内置 SSH 终端可直接管理云服务器
- **PicGo兼容性** - 支持扫描二维码将 PicGo(v2.3.0-beta.2 以上版本)配置文件直接导入 PicHoro

### 其他功能

- 每种图床最多支持 26 个备用配置，可快速切换
- 连续上传模式，相机拍照后自动上传并返回拍照页面
- 支持导入剪贴板中的网络图片链接，换行符分割可批量导入
- 上传图片后自动复制链接到剪贴板
- 自定义复制到剪贴板的链接格式，占位符与 PicGo 一致
- 多种文件重命名方式（时间戳、随机字符串和自定义重命名）
- 相册分图床显示，支持多选管理，复制多张图片链接或删除
- 支持导出配置至剪贴板（与 PicGo 配置文件格式相同）
- 查看和导出软件日志，快捷查找问题和报告 bug

## 文件预览支持

| 平台   | 图片  |  PDF  | 文本文件 | 视频  |
| ------ | :---: | :---: | :------: | :---: |
| Alist  |   ✅   |   ✅   |    ✅     |   ✅   |
| 阿里云 |   ✅   |   ✅   |    ✅     |   ✅   |
| S3     |   ✅   |   ✅   |    ✅     |   ✅   |
| 腾讯云 |   ✅   |   ✅   |    ✅     |   ✅   |
| 又拍云 |   ✅   |   ✅   |    ✅     |   ✅   |
| 七牛云 |   ✅   |   ✅   |    ✅     |   ✅   |
| WebDav |   ✅   |   ✅   |    ✅     |   ✅   |
| FTP    |   ✅   |   ❌   |    ✅     |   ❌   |
| Github |   ✅   |   ❌   |    ✅     |   ❌   |
| Imgur  |   ✅   |   ❌   |    ❌     |   ✅   |
| 兰空   |   ✅   |   ❌   |    ❌     |   ❌   |
| SM.MS  |   ✅   |   ❌   |    ❌     |   ❌   |

## 下载

### 安卓

- **Github 下载**: [Github release](https://github.com/Kuingsmile/PicHoro/releases)
- **官网下载**: [最新版本 V2.4.0](https://pichoro.msq.pub/PicHoro_V2.4.0.apk)

### iOS

目前暂无 iOS 版本。如果您有兴趣帮助开发 iOS 版本，请联系我们提供技术支持。

## 应用展示

<div><video controls src="https://user-images.githubusercontent.com/96409857/205264099-a3a5d040-df75-4ae2-9773-f4d61fe3fb0a.mp4" muted="false"></video></div>

<table rules="none">
  <tr>
    <td><img src="https://user-images.githubusercontent.com/96409857/203718727-ceac86b4-8cb5-49c5-8ee3-bcfce51710cb.jpg" width="200" height="400" alt="主页面"/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203718378-fd4cf22f-b801-4356-9a8b-9d51a0db0e54.jpg" width="200" height="400" alt="相册页面"/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/211286619-63e406aa-0736-4581-bd9e-adde92209dba.png" width="200" height="400" alt="文件管理"/></td>
  </tr>
   <tr>
    <td><img src="https://user-images.githubusercontent.com/96409857/211286730-2e0c05b3-5093-4738-8378-7d2c273a694b.png" width="200" height="400" alt="设置页面"/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203719066-b6e45be8-eb8f-49da-bea2-78f3d4379591.jpg" width="200" height="400" alt="图床配置"/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203719617-b54a49bb-d9f9-4917-a68a-b4a46f951ee0.png" width="200" height="400" alt="文件上传"/></td>
  </tr>
   <tr>
    <td><img src="https://user-images.githubusercontent.com/96409857/203719608-34170e4c-2d6f-4e3a-990a-f61c610417e9.png" width="200" height="400" alt="预览功能"/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203720199-38266fae-e0fa-4aad-8315-f272bc8b6add.jpg" width="200" height="400" alt="自定义链接"/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203720359-26717390-1789-4750-97dd-27836da322da.jpg" width="200" height="400" alt="文件管理"/></td>
  </tr>
  <tr>
    <td><img src="https://user-images.githubusercontent.com/96409857/203720473-577368a7-ed29-461b-b8f2-4077dd02ca84.jpg" width="200" height="400" alt="上传历史"/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203720565-4d4008a5-198f-451d-b0cc-b1780291f2b7.png" width="200" height="400" alt="SSH终端"/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203720614-4bfd6e0c-ea16-4ed1-945d-c5c5524c89a6.png" width="200" height="400" alt="配置导出"/></td>
  </tr>
</table>

## 最近更新

详细更新日志请查看[更新日志](https://github.com/Kuingsmile/PicHoro/blob/main/Version_update_log.md)

### 2024-07-19 **V2.4.0**

#### 新增功能:

- 与 AList 3.35 版本保持同步
- `alist` 图床现在支持设置管理员 token
- `sm.ms` 图床上传重复图片时不再判定为失败
- S3 兼容平台支持带端口号的 endpoint
- S3 兼容平台支持设置是否启用 SSL 连接和 S3 path style
- 优化图床导入，支持 PicList 内置 AList、兰空图床、ftp 图床、WebDAV 图床及 alist 图床插件配置
- 优化文件 mime 类型判断，兼容更多文件类型并默认使用 `application/octet-stream`
- 重命名占位符 `{m}` 和 `{d}` 固定为两位数字，如 `01`、`02`
- 新增重命名占位符: `{h}`(小时)、`{i}`(分钟)、`{s}`(秒)、`{ms}`(毫秒)、`{str-num}`
- 默认自定义重命名格式修改为 `{Y}{m}{d}{h}{i}{ms}`，与 PicGo 一致
- 默认自定义链接格式修改为 `![$fileName]($url)`
- 设置图床配置时自动去除开头和结尾多余空格

#### 修复问题:

- alist 备用设置中无法设置网址路径的问题
- alist 设置了网址路径时返回地址多了一个 '/' 的问题
- alist 返回链接是平台直链而非 alist 专用网址的问题
- 特定情况下 `ftp` 图床返回链接错误的问题
- ftp 图床设置页面打开错误的问题
- 导入 `imgur` 配置时错误保存到 `smms` 的问题
- 关闭自动复制链接后仍然会复制到剪贴板的问题

## 开发与交流

- **开发进度**: 查看 [Projects](https://github.com/Kuingsmile/PicHoro/projects)
- **讨论交流**: 加入 [Github 讨论区](https://github.com/Kuingsmile/PicHoro/discussions)
- **问题反馈**: 在 [Github Issues](https://github.com/Kuingsmile/PicHoro/issues) 提出

**Telegram 交流群:**

![Telegram Group](https://pichoro.msq.pub/wechat.png)

## 开发说明

### 软件修改步骤

1. 准备环境: 安装 Android Studio、Android SDK 21+ 和 Flutter 3.13
2. 克隆仓库: `git clone https://github.com/Kuingsmile/PicHoro.git`
3. Windows 用户推荐使用 VSCode 编辑和调试代码

### 图床修改说明

兰空图床相册 ID 参数生效条件:

1. 基于付费企业版兰空图床搭建
2. 开源免费版需修改源代码文件 `/app/Services/ImageService.php`:

```php
// 原代码
if ($albumId = $user->configs->get(UserConfigKey::DefaultAlbum)) {
    if ($user->albums()->where('id', $albumId)->exists()) {
        $image->album_id = $albumId;
    }
}

// 修改后
if ($request->has('album_id')) {
    $image->album_id = $request->input('album_id');
} else {
    if ($albumId = $user->configs->get(UserConfigKey::DefaultAlbum)) {
        if ($user->albums()->where('id', $albumId)->exists()) {
            $image->album_id = $albumId;
        }
    }
}
```

### 软件打包

使用以下命令构建:

```bash
flutter build apk --release
```

构建成功后，在 `build\app\outputs\flutter-apk\release` 生成 `app-release.apk` 文件。

> **注意**: 请设置 `minifyEnabled false` 和 `shrinkResources false`，否则打包后可能闪退。

## License

[MIT](https://opensource.org/licenses/MIT)

Copyright (c) 2022-present, Kuingsmile

## Github Star 趋势

[![Stargazers over time](https://starchart.cc/Kuingsmile/PicHoro.svg)](https://starchart.cc/Kuingsmile/PicHoro)
