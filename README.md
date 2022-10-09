
<div align="center">
  <img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_05_633d79e401694.png" alt="">
  <h1>PicHoro</h1>
</div>

&emsp;&emsp;一款基于flutter的移动端图片上传和图床管理工具，可上传和删除图片，已支持如下图床：  
- [x] 兰空图床 个人图床网站[https://imgx.horosama.com](https://imgx.horosama.com)
- [x] SM.MS(**V1.41版本添加**) 图床网站[https://smms.app](https://smms.app)或[https://sm.ms](https://sm.ms)

&emsp;&emsp;正在研究添加各种其它图床的支持，个人开发用于学习flutter和替代很久没更新了的[flutter-Picgo](https://github.com/PicGo/flutter-picgo)。

@author: Horosama

@email: ma_shiqing@163.com

## 应用截图

<table rules="none">
  <tr>
    <td><img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_07_633f92429faf6.jpg" width="200" height="400" alt=""/></td>
    <td><img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_09_63428bdd8a02c.jpg" width="200" height="400" alt=""/></td>
    <td><img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_07_633f9f49cf071.jpg" width="200" height="400" alt=""/></td>
  </tr>
   <tr>
    <td><img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_09_63428bdd827b6.jpg" width="200" height="400" alt=""/></td>
    <td><img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_09_63428bdcd4761.jpg" width="200" height="400" alt=""/></td>
  </tr>
</table>

## 最近更新

  详细更新日志请查看[更新日志](https://github.com/Kuingsmile/PicHoro/blob/main/Version_update_log.md "更新日志")

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
- 2022-10-07: **V1.41**:
  - 增加了对SM.MS图床的支持
  - 修复了markdown链接的文件名错误的问题
- 2022-10-07: **V1.40**:
  - 增加了文件上传自动重命名的功能
  - 增加了文件上传后自动复制链接的功能，同时可选url，html，markdown，bbcode和带链接的markdown等格式
  - 增加了软件APP内自动更新的功能
  - Github国内打开太慢，把项目地址页面换成更新日志页面
  - 部分bug修复
- 2022-10-06: **V1.31**:
  - 修复了已注册用户在新设备第一次登录的时候，无法正常登录的bug
  - 修复了连续上传功能在退出的时候会卡在上传中的bug
  - 已登录的设备在获取云端配置的时候不需要重新输入用户名和密码了
  - 修复了部分代码小bug
- 2022-10-02: **V1.00**: 项目初始化，完成基本的上传功能，目前仅支持兰空图床，需要手动授予存储和相机权限

## 下载

**安卓版**：

[https://www.horosama.com/self_apk/PicHoro_V1.5.0.apk](https://www.horosama.com/self_apk/PicHoro_V1.5.0.apk)

## 开发计划

- 增加对各种图床平台的支持，预计先写github和腾讯云存储的代码,已完成
  - [x] 兰空图床
  - [x] SM.MS
  - [x] Github(实现了一半，开发中)
- 增加图床仓库管理的功能，增加从相册里删除图片的时候只删除数据库记录的功能
- 增加从剪贴板和网络URL上传图片的功能
- 增加自定义复制的链接格式的功能
- 增加图片分享到其他APP的功能
- 增加软件更新后保留本地配置的功能-**部分实现，APP内升级可以保留配置**
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
