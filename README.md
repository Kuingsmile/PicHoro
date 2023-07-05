<div align="center">
  <img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_05_633d79e401694.png" alt="">
  <h1>PicHoro</h1>
  <a href="https://github.com/Kuingsmile/PicHoro/releases/latest">
    <img src="https://img.shields.io/github/release/Kuingsmile/PicHoro.svg?style=flat-square" alt="">
  </a>
</div>

&emsp;&emsp;一款基于flutter的手机端云存储平台/图床管理和文件上传/下载工具，最新版本**V2.1.0**，与PicGo配置互通，可直接扫码导入，主要功能包括云存储/图床/云服务器平台,以及网盘管理（通过[Alist](https://alist.nn.ci/zh/))，文件上传和下载管理，以及各种格式的链接分享。

&emsp;&emsp;支持多种图片/PDF/文本文件/音视频的在线预览和播放，具体支持的格式请查看[支持的格式列表](https://github.com/Kuingsmile/PicHoro/blob/main/supported_format.md "支持的格式列表")

桌面端如果也希望进行图床管理，推荐使用我的另一个项目`PicList`，[https://github.com/Kuingsmile/PicList](https://github.com/Kuingsmile/PicList)

&emsp;&emsp;项目介绍和配置手册网址:

&emsp;&emsp;[https://pichoro.horosama.com](https://pichoro.horosama.com)

&emsp;&emsp;目前已支持如下图床：

- [X] 兰空图床V2 (上传/相册-**V1.00**，文件管理-**V1.87**)
- [X] SM.MS (上传/相册-**V1.41**，文件管理-**V1.81**)
- [X] Github (上传/相册-**V1.55**，文件管理-**V1.89**)
- [X] Imgur (上传/相册-**V1.60**，文件管理-**V1.90**)
- [X] 七牛云存储 (上传/相册-**V1.65**，文件管理-**V1.86**)
- [X] 腾讯云COS V5 (上传/相册-**V1.70**，文件管理-**V1.80**)
- [X] 阿里云OSS (上传/相册-**V1.75**，文件管理-**V1.84**)
- [X] 又拍云存储 (上传/相册-**V1.75**，文件管理-**V1.85**)
- [X] FTP-SSH/SFTP (上传/相册-**V1.90**，文件管理-**V1.90**)
- [X] 兼容S3 API接口的平台 (上传/相册-**V1.91**，文件管理-**V1.91**)
- [X] Alist V3 (上传/相册-**V1.96**，文件管理-**V1.96**)
- [X] WebDav (上传/相册-**V1.97**，文件管理-**V1.97**)

## 特色功能

- **支持直接管理云存储/图床，包括新建/删除/修改存储桶，创建/删除目录和文件，上传和下载文件和照片等**
- **可通过Alist V3或WebDav管理多种网盘**
- **支持图片压缩功能，可压缩为webp/jpg/png格式**
- **支持预览多种格式的文件，包括图片/PDF/文本文件/音视频等**
- **支持SSH/SFTP，可视化管理文件，内置SSH终端可直接管理云服务器**
- **支持扫描二维码将PicGo(v2.3.0-beta.2以上版本)配置文件直接导入PicHoro**
- 每种图床支持保存最多26个备用配置，可快速切换备用配置为主配置
- 连续上传模式，相机拍照后自动上传然后返回拍照页面，可连续拍照上传
- 可导入剪贴板中的网络图片链接，同时使用换行符分割多个链接可批量导入
- 上传图片后自动复制链接到剪贴板，多图上传时全部复制
- 支持自定义复制到剪贴板的链接格式，占位符与Picgo一致
- 上传时可对文件重命名，目前有时间戳，随机字符串和自定义重命名三种方式，自定义重命名可使用多种占位符，如uuid，时间戳，md5等
- 相册分图床显示，支持多选管理，复制多张图片链接或删除
- 支持将PicHoro的配置导出至剪贴板，导出格式与PicGo配置文件相同，可直接导入PicGo
- 可查看和导出软件日志，快捷查找问题和报告bug

## 文件预览支持

| 平台| 图片 | PDF | 文本文件 | 视频|
| ---------------- | :--: | :--: | :--: | :--: |
|Alist|✅|✅|✅|✅|
|阿里云|✅|✅|✅|✅|
|S3|✅|✅|✅|✅|
|腾讯云|✅|✅|✅|✅|
|又拍云|✅|✅|✅|✅|
|七牛云|✅|✅|✅|✅|
|WebDav|✅|✅|✅|✅|
|FTP|  ✅|❌|✅|❌|
|Github|✅|❌|✅|❌|
|Imgur|✅|❌|❌|✅|
|兰空|✅|❌|❌|❌|
|SM.MS|✅|❌|❌|❌|

## 下载

### 安卓

Github下载地址 [Github release](https://github.com/Kuingsmile/PicHoro/releases)  

我的个人网站提供的最新版本下载地址 [https://pichoro.msq.pub/PicHoro_V2.1.0.apk](https://pichoro.msq.pub/PicHoro_V2.1.0.apk)

### IOS

由于个人没有Mac和开发者账号，暂时无法提供IOS版本，如果有人愿意帮忙开发IOS版本，可以联系我，我会提供相关的技术支持。

## 应用截图

<div><video controls src="https://user-images.githubusercontent.com/96409857/205264099-a3a5d040-df75-4ae2-9773-f4d61fe3fb0a.mp4" muted="false"></video></div>

<table rules="none">
  <tr>
    <td><img src="https://user-images.githubusercontent.com/96409857/203718727-ceac86b4-8cb5-49c5-8ee3-bcfce51710cb.jpg" width="200" height="400" alt=""/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203718378-fd4cf22f-b801-4356-9a8b-9d51a0db0e54.jpg" width="200" height="400" alt=""/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/211286619-63e406aa-0736-4581-bd9e-adde92209dba.png" width="200" height="400" alt=""/></td>
  </tr>
   <tr>
    <td><img src="https://user-images.githubusercontent.com/96409857/211286730-2e0c05b3-5093-4738-8378-7d2c273a694b.png" width="200" height="400" alt=""/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203719066-b6e45be8-eb8f-49da-bea2-78f3d4379591.jpg" width="200" height="400" alt=""/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203719617-b54a49bb-d9f9-4917-a68a-b4a46f951ee0.png" width="200" height="400" alt=""/></td>
  </tr>
   <tr>
    <td><img src="https://user-images.githubusercontent.com/96409857/203719608-34170e4c-2d6f-4e3a-990a-f61c610417e9.png" width="200" height="400" alt=""/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203720199-38266fae-e0fa-4aad-8315-f272bc8b6add.jpg" width="200" height="400" alt=""/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203720359-26717390-1789-4750-97dd-27836da322da.jpg" width="200" height="400" alt=""/></td>
  </tr>
  <tr>
    <td><img src="https://user-images.githubusercontent.com/96409857/203720473-577368a7-ed29-461b-b8f2-4077dd02ca84.jpg" width="200" height="400" alt=""/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203720565-4d4008a5-198f-451d-b0cc-b1780291f2b7.png" width="200" height="400" alt=""/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203720614-4bfd6e0c-ea16-4ed1-945d-c5c5524c89a6.png" width="200" height="400" alt=""/></td>
  </tr>
</table>

## 最近更新

  详细更新日志请查看[更新日志](https://github.com/Kuingsmile/PicHoro/blob/main/Version_update_log.md "更新日志")

- 2023-06-20: **V2.1.0**:

  - webdav现在支持设置自定义域名
  - ftp现在支持设置自定义域名

- 2023-05-04: **V2.0.0**:

  - 移除了用户登录和云端同步系统，现在所有数据保存于用户本地
  - 移除了imgur管理登录页面对clientsecret的需求
  - 更新了alist驱动列表，与最新版(3.16.3)保持同步
  - 修复了重复设置Alist为默认图床时，默认相册设置错误的问题

- 2023-02-28: **V1.10.0**:

  - 新增：s3/阿里云/腾讯云等平台现在可以单独为存储桶设置自定义域名了。
  - 新增：现在会在安装或者启动时获取安装未知应用权限，避免APP无法启动。
  - 维护：部分代码精简
  - 修复：修复了s3平台文件地址错误的问题。
  - 修复：修复了图片缓存导致相同地址的图片无法更新的问题。

## 开发计划

- 添加搜索功能
- 添加生成限时分享链接功能
- 优化文件数量过多时的加载速度
- 修复bug

## 开发交流

![image](https://pichoro.msq.pub/wechat.png)

开发进度可以查看 [Projects](https://github.com/Kuingsmile/PicHoro/projects)，会同步更新开发进度。

欢迎加入 [Github讨论区](https://github.com/Kuingsmile/PicHoro/discussions) 与我交流。

遇到Bug或有好的建议可以在 [Github Issues](https://github.com/Kuingsmile/PicHoro/issues) 中提出。

## 开发说明

### 软件修改

如果你想要修改或自行构建 PicHoro，可以依照下面的指示：

1. 你需要有 Android Studio和 Android SDK 21+ 的环境，并安装了Flutter 3.0+版本。flutter环境配置可以参考 [Flutter 官方文档](https://flutter.dev/docs/get-started/install)。
2. `git clone https://github.com/Kuingsmile/PicHoro.git` 并进入项目。
3. Windows 推荐使用VScode编辑和调试代码。

### 图床修改

兰空图床的相册ID参数，限于以下两种情况下才会生效：
    1. 基于付费企业版兰空图床搭建
    2. 开源免费版需要自己或者联系管理员修改源代码文件，修改方式为打开 **/app/Services/ImageService.php**文件，修改第139行，原文件为

```php
            if ($albumId = $user->configs->get(UserConfigKey::DefaultAlbum)) {
                if ($user->albums()->where('id', $albumId)->exists()) {
                    $image->album_id = $albumId;
                }
            }
```

修改为

```php
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

### 依赖包修改

本APP使用的部分依赖包需要手动修改源代码才可使用，需要修改的依赖包如下：

#### flutter_speed_dial

文件路径示例: `D:\flutter\.pub-cache\hosted\pub.flutter-io.cn\flutter_speed_dial-6.1.0+1\lib\src\speed_dial.dart`

如下修改`dispose`函数：

```dart
@override
  void dispose() {
    if (widget.renderOverlay &&
        (backgroundOverlay != null && backgroundOverlay!.mounted)) {
      backgroundOverlay?.remove();
    }
    if (overlayEntry != null && overlayEntry!.mounted) {
      overlayEntry?.remove();
      overlayEntry?.dispose();
    }
    _controller.dispose();
    widget.openCloseDial?.removeListener(_onOpenCloseDial);
    super.dispose();
  }
```

#### minio_new

文件路径示例: `D:\flutter\.pub-cache\hosted\pub.flutter-io.cn\minio_new-1.0.1\lib\src\minio.dart`

1. `queries['maxKeys']`修改为`queries['max-keys']`
2. 添加导入 `import 'package:xml2json/xml2json.dart';`
3. 如下修改`listBuckets`函数

```dart
  Future<List<Bucket>> listBuckets() async {
    final resp = await _client.request(
      method: 'GET',
      region: region ?? 'us-east-1',
    );
    final myTransformer = Xml2Json();
    myTransformer.parse(resp.body);
    Map responseMap = json.decode(myTransformer.toParker());
    List<Bucket> buckets = [];
    if (responseMap['ListAllMyBucketsResult'] == null ||
        responseMap['ListAllMyBucketsResult']['Buckets'] == null ||
        responseMap['ListAllMyBucketsResult']['Buckets']['Bucket'] == null ||
        responseMap['ListAllMyBucketsResult']['Buckets']['Bucket'].length ==
            0) {
      return buckets;
    }
    if (responseMap['ListAllMyBucketsResult']['Buckets']['Bucket'] is! List) {
      buckets.add(Bucket(
          DateTime.parse(responseMap['ListAllMyBucketsResult']['Buckets']
              ['Bucket']['CreationDate']),
          responseMap['ListAllMyBucketsResult']['Buckets']['Bucket']['Name']));
      return buckets;
    }
    for (var bucket in responseMap['ListAllMyBucketsResult']['Buckets']
        ['Bucket']) {
      buckets
          .add(Bucket(DateTime.parse(bucket['CreationDate']), bucket['Name']));
    }
    return buckets;
  }
```

#### chewie

文件路径示例: `"D:\flutter\.pub-cache\hosted\pub.flutter-io.cn\chewie-1.3.6\lib\src\player_with_controls.dart"`

第86行开始修改为

```dart
  return Container(
      color:Colors.black,
      child:Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: calculateAspectRatio(context),
          child: buildPlayerWithControls(chewieController, context),
        ),
      )),
    );
```

### 软件打包

如果你需要自行构建，可以使用 `flutter build apk` 或者 进入 `android` 目录，使用 `gradlew assembleRelease` 命令构建。
构建成功后，会在 `build\app\outputs\apk\release` 目录下生成 `app-release.apk` 文件。

请设置`minifyEnabled false`和`shrinkResources false`，否则打包release版本后可能会出现闪退。

## License

[MIT](https://opensource.org/licenses/MIT)

Copyright (c) 2022-present, Kuingsmile

## Github star

[![Stargazers over time](https://starchart.cc/Kuingsmile/PicHoro.svg)](https://starchart.cc/Kuingsmile/PicHoro)
