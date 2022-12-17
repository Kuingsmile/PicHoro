<div align="center">
  <img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_05_633d79e401694.png" alt="">
  <h1>PicHoro</h1>
  <a href="https://github.com/Kuingsmile/PicHoro/releases">
    <img src="https://img.shields.io/github/downloads/Kuingsmile/PicHoro/total.svg?style=flat-square" alt="">
  </a>
  <a href="https://github.com/Kuingsmile/PicHoro/releases/latest">
    <img src="https://img.shields.io/github/release/Kuingsmile/PicHoro.svg?style=flat-square" alt="">
  </a>
  <a href="https://github.com/Kuingsmile/PicHoro">
     <img src="https://img.shields.io/github/stars/Kuingsmile/PicHoro.svg?style=flat-square" alt="">
     </a>
</div>

&emsp;&emsp;一款基于flutter的手机端云存储平台/图床管理和文件上传/下载工具，最新版本**V1.9.8**，与PicGo配置互通，可直接扫码导入，主要功能包括云存储/图床/云服务器平台,以及网盘管理（通过[Alist](https://alist.nn.ci/zh/))，文件上传和下载管理，以及各种格式的链接分享。

&emsp;&emsp;支持多种图片/PDF/文本文件/音视频的在线预览和播放，具体支持的格式请查看[支持的格式列表](https://github.com/Kuingsmile/PicHoro/blob/main/supported_format.md "支持的格式列表")

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

我的个人网站提供的最新版本下载地址 [https://www.horosama.com/self_apk/PicHoro_V1.9.8.apk](https://www.horosama.com/self_apk/PicHoro_V1.9.8.apk)

### IOS

由于个人没有Mac和开发者账号，暂时无法提供IOS版本，如果有人愿意帮忙开发IOS版本，可以联系我，我会提供相关的技术支持。

## 应用截图

<div><video controls src="https://user-images.githubusercontent.com/96409857/205264099-a3a5d040-df75-4ae2-9773-f4d61fe3fb0a.mp4" muted="false"></video></div>

<table rules="none">
  <tr>
    <td><img src="https://user-images.githubusercontent.com/96409857/203718727-ceac86b4-8cb5-49c5-8ee3-bcfce51710cb.jpg" width="200" height="400" alt=""/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203718378-fd4cf22f-b801-4356-9a8b-9d51a0db0e54.jpg" width="200" height="400" alt=""/></td>
    <td><img src="https://user-images.githubusercontent.com/96409857/203718175-6616cd6d-0d7d-4eab-9f6f-6686db9468ec.png" width="200" height="400" alt=""/></td>
  </tr>
   <tr>
    <td><img src="https://user-images.githubusercontent.com/96409857/203718982-448828ff-3ad1-4d93-9c7f-ece9d69d34c4.jpg" width="200" height="400" alt=""/></td>
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

- 2022-12-18: **V1.98**:
  - 新增：添加了图片压缩功能，现在可以选择在上传图片前先进行压缩了，可选压缩后格式为jpg、png和webp，并且可以自定义最小宽度、最小高度和压缩后质量。
  - 新增：S3 API兼容平台上传时现在会主动修改content-type。
  - 优化：添加了webp文件格式的图标。

- 2022-12-05: **V1.97**:
  - 新增：添加了对**WebDAV**的支持，使用坚果云webdav和Alist V3的webdav测试通过。
  - 新增：Alist V3现在可以不登录访问了，只需要设置Alist域名，即可在管理页面中查看文件。
  - 修复：修复了清空相册数据库页面没有显示阿里云的问题。

- 2022-12-02: **V1.96**:

  - 新增：新增了对[Alist V3](https://alist.nn.ci/zh/)的支持，现在可以通过Alist间接管理其支持的各种存储和网盘。支持的平台包括：本地存储，阿里云盘，百度网盘，夸克网盘，蓝奏云，谷歌相册，115，OneDrive，天翼云盘，GoogleDrive，123云盘，FTP / SFTP，PikPak，S3，又拍云，WebDav，Teambition，分秒帧，移动云盘等等。
    - Alist的token有有效期，PicHoro会每天尝试更新一次token，如果遇到错误，请尝试重新设置Alist来更新token。
    - 支持通过Alist来查看图片和观看视频。
    - 支持快捷操作Alist存储，包括新增，卸载，修改配置，启用，禁用等。
    - 支持上传/下载，新建文件夹/重命名/删除/分享链接等各种操作，使用百度网盘官方接口时，会自动添加`User-Agent:pan.baidu.com`的请求头。
    - 由于Alist支持的平台比较多，个人一些平台没有账号，未能全部完成测试，如果发现有问题，请提交issue。已经测试过的平台有：
      - Alist V3
      - 阿里云盘
      - 百度网盘
      - 本机存储
      - SFTP
      - FTP
      - 一刻相册
      - WebDav(使用坚果云webdav测试)
  - 新增：增加了对**PDF**格式文件在线预览的支持，可以搜索和跳转页面。
  - 新增：增加了对**音视频文件**在线播放的支持，其中：
    - mp4, flv,m4v,mp3,avi,mpg,flac,ogg,ts,aac,m4a,vob等格式支持播放列表功能，列表由当前目录下的视频文件组成。
    - mkv和rmvb等格式由于后台实现的问题，暂时不支持播放列表功能。
    - mkv文件可以自动识别和加载字幕文件，字幕文件需要与视频的文件名相同，后缀名为srt/ass/vtt/sbv/ttml/dfxp/ssa之一。
    - **为了解码mkv等格式，添加了VLC依赖，包体积增加较多，我在尝试缩减和考虑是否提供不带VLC的版本。**
  - 新增：现在支持**更多的文本文件格式**预览，涵盖了各种常见编程语言源文件。
  - 新增：图床管理页面增加了重置排序按钮，可以将图床的排序重置为默认排序。
  - 优化：压缩了部分assets文件，尽量减少对包体积的影响，同时删除了部分未使用的assets文件。
  - 优化：更换了网页浏览的实现方式。
  - 优化：用户登录后的图床信息查看页，现在按照图床名称排序。
  - 优化：优化部分UI尺寸。
  - 优化：优化了部分冗余代码。
  - 修复：修复了图片预览时会在最后额外添加一页空白页的问题
  - 修复：修复了注销登录时没有清空S3上传/下载列表的问题。
  - 修复：修复了连续上传模式下，使用S3上传时相册显示不正确的问题。
  - 修复：修复了图床设置为S3时，相册内删除会错误的将url当做本地文件名进行删除的问题。
  - 修复：修复了使用S3时，返回的图片URL不包括存储桶，导致图片无法显示的问题。
  - 修复：修复了图床管理页面的排序问题。

## 开发交流

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

Copyright (c) 2022 Kuingsmile

## Github star

[![Stargazers over time](https://starchart.cc/Kuingsmile/PicHoro.svg)](https://starchart.cc/Kuingsmile/PicHoro)