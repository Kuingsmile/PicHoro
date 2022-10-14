
<div align="center">
  <img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_05_633d79e401694.png" alt="">
  <h1>PicHoro</h1>
</div>

&emsp;&emsp;一款基于flutter的移动端图片上传和图床管理工具，与PicGo配置互通，可直接扫码导入，主要功能包括上传，查看，删除图片，已支持如下图床：  

- [x] 兰空图床V2 (**V1.00版本添加**)
- [x] SM.MS(**V1.41版本添加**) 图床网站[https://smms.app](https://smms.app)或[https://sm.ms](https://sm.ms)
- [x] Github(**V1.55版本添加**) 使用Github仓库作为图床
- [x] Imgur(**V1.60版本添加**) Imgur国内用户需要配合翻墙使用，个人手机测试配合clash可以正常使用
- [x] 七牛云存储(**V1.65版本添加**) 七牛云存储
- [x] 腾讯云COS(**V1.70版本添加**) 腾讯云COS

&emsp;&emsp;正在研究添加各种其它图床的支持，个人开发用于学习flutter和替代很久没更新了的[flutter-Picgo](https://github.com/PicGo/flutter-picgo)。

@author: Horosama  
@website: [https://www.horosama.com](https://www.horosama.com)  
@email: ma_shiqing@163.com  

## 应用截图

<table rules="none">
  <tr>
    <td><img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_07_633f92429faf6.jpg" width="200" height="400" alt=""/></td>
    <td><img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_09_63428bdd8a02c.jpg" width="200" height="400" alt=""/></td>
    <td><img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_11_634539370c248.png" width="200" height="400" alt=""/></td>
  </tr>
   <tr>
    <td><img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_11_63453925be3cb.png" width="200" height="400" alt=""/></td>
    <td><img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_11_6345392f8d997.png" width="200" height="400" alt=""/></td>
  </tr>
</table>

## 最近更新

  详细更新日志请查看[更新日志](https://github.com/Kuingsmile/PicHoro/blob/main/Version_update_log.md "更新日志")

- 2022-10-14: **V1.70**:
  - 增加了对腾讯云COS的支持
  - 修改自定义链接格式的占位符为`$fileName`和`$url`，来和PicGo保持一致，同时修改了默认的自定义链接格式。
  - 修复了七牛云不设置存储路径的时候保存路径错误的问题。
  - 修复了github，imgur和七牛云导入二维码配置的时候可选参数默认值错误和七牛云数据库保存的数据错误的问题。
- 2022-10-13: **V1.65**:
  - 增加了对七牛云的支持（吐槽一下，七牛云这官方文档真的是emmmm）
  - 调整了配置和图片上传/删除的时候的响应和连接超时时间设置数值。
  - 相册图片的外框默认透明色，选中的时候会有一个红色的边框提示。
- 2022-10-12: **V1.60**:
  - 增加了对Imgur图床的支持，但是由于Imgur的限制，使用的时候需要配置手机代理，在个人手机上配合clash测试可用。
  - 加入了设置配置和图片上传/删除的时候的响应和连接超时时间设置，防止网络不好的情况下卡死。
  - 区分了相册显示的时候的图片地址和复制的时候的图片地址，改善相册加载图片的速度，例如兰空图床在相册小图中显示的是缩略图，预览大图的时候才会加载原图。
  - 修复了设置页面跳转到主页的时候，有时会先跳转到相册页面的问题
  - 修复了注册用户的时候，同步创建本地相册数据库的代码没有执行的bug
  - 修复了连续上传功能中，复制的链接的格式错误的bug
  - 更改了登录页面UI，方便区分出是否已经登录
- 2022-10-11: **V1.55**:
  - 增加了扫码导入PicGo配置的功能，和PicGo进一步兼容。
  - 增加了对Github图床的支持,在主页增加了切换默认上传图床的浮动按钮。
  - 增加了自定义复制链接的格式的功能，和PicGo的自定义格式一样，使用\${url}和\${filename}来表示链接和文件名，可以在设置中自定义。
  - 增加了新的设置选项，可以选择在删除图片的时候是否同步删除网络端的图片（默认不删除）。
  - 重新整理了源代码文件架构，使得代码更加清晰，方便后续的更新和维护。
  - 修改了相册的显示逻辑，现在按上传时间倒序显示，最新上传的图片在最上面。
  - 修复了相册上翻页功能没有按预期作用的问题。
  - 修复了图片多选的时候，删除功能的bug，同时优化了动画显示，现在不会傻傻的等待了。
  - 修复了相册中显示的图床和默认上传图床不一致的时候无法删除网络端图片的bug。
  - 修复了选中状态会在翻页的时候保留的bug。
  - 修复了设置默认上传图床参数的时候，没有同步更改云端数据库记录的问题。
  - 优化了界面UI，修复了一些组件尺寸的问题。
- 2022-10-09: **V1.50**:
  - 增加了**相册**功能，进一步对标了PicGo,现在PicHoro不仅是一款上传工具，也是一款图床管理工具。
  - 相册模块中实现了这些功能：
    1. 显示已经上传的图片，分页显示，每页12张，可以上划和下拉翻页。
    2. 分图床显示，可选择显示某个图床的图片。
    3. 实现了删除图片的功能，删除后会自动刷新相册，默认删除数据库记录和图床上的图片，可选择是否同步删除本地图片。
    4. 实现了多选功能，可选择多张图片进行删除和复制指定格式的链接。
    5. 可点击图片查看大图，双击图片可复制指定格式的链接，长按图片可弹出菜单，选择链接格式或者删除图片。
    6. 相册中的图片数据保存在本地，通过APP内升级时不会丢失。
  - 增加了选择默认图床的页面，可以更直观的知道当前默认图床是哪个。
  - 修复了一些已知的bug。
- 2022-10-02: **V1.00**:
  - 项目初始化，完成基本的上传功能，目前仅支持兰空图床，需要手动授予存储和相机权限

## 下载

**安卓版**：

[https://www.horosama.com/self_apk/PicHoro_V1.7.0.apk](https://www.horosama.com/self_apk/PicHoro_V1.7.0.apk)

## 开发计划

- 增加对各种图床平台的,已完成
  - [x] 兰空图床V2版本
  - [x] SM.MS
  - [x] Github
  - [x] Imgur
  - [x] 七牛云
  - [x] 腾讯云
- 增加从剪贴板和网络URL上传图片的功能
- 增加图片分享到其他APP的功能
- 增加软件更新后保留本地配置的功能-**部分实现，APP内升级可以保留配置**
- 增加图床仓库管理的功能，增加从相册里删除图片的时候只删除数据库记录的功能-**已实现**
- 增加自定义复制的链接格式的功能-**已实现**
- 增加相册功能，可以查看已上传的图片并进行管理-**已实现**
- 增加上传时的设置功能，如是否修改文件名等-**已实现**
- 增加上传后复制链接到剪贴板的功能，同时可以再设置里选择链接的格式-**已实现**
- 增加主动获取权限的功能，避免用户手动授予权限-**已实现**
- 增加相册图片多选上传功能-**已实现**
- 增加拍照后自动上传功能-**已实现**
- 增加上传或者等待时的loading动画-**已实现**
- 增加主题切换功能-**已实现**

## License

MIT
