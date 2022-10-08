
<div align="center">
  <img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_05_633d79e401694.png" alt="">
  <h1>PicHoro</h1>
</div>

&emsp;&emsp;一款基于flutter的移动端图片上传工具，已支持如下图床：  
- [x] 兰空图床 个人图床网站[https://imgx.horosama.com](https://imgx.horosama.com)
- [x] SM.MS(**V1.41版本添加**) 图床网站[https://smms.app](https://smms.app)或[https://sm.ms](https://sm.ms)

&emsp;&emsp;正在研究添加各种其它图床的支持，个人开发用于学习flutter和替代很久没更新了的[flutter-Picgo](https://github.com/PicGo/flutter-picgo)。

@author: Horosama

@email: ma_shiqing@163.com

## 应用截图

<table rules="none" align="center" border="none">
<tr border="none">
<td border="none">
<center>
<img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_07_633f92429faf6.jpg" width="100%" />
<br/>
<font color="AAAAAA">主页.jpg</font>
</center>
</td>
<td border="none">
<center>
<img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_07_633f9f49cf071.jpg" width="100%" />
<br/>
<font color="AAAAAA">设置.jpg</font>
</center>
</td>
</tr>
</table>

## 最近更新

  详细更新日志请查看[更新日志](https://github.com/Kuingsmile/PicHoro/blob/main/Version_update_log.md "更新日志")

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
- 2002-10-05: **V1.30**:
  - 重构了整个APP的代码架构，把所有的页面和功能性函数都放在了对应文件夹里，方便后续的维护和扩展，同时抽象了上传等功能的接口，后续增加图床时可以直接调用。
  - 增加了用户登录和拉取云端配置的功能，可以通过用户名和密码登录，将图床配置等保存在服务器上，这里现在用户本地用3DES加密然后再保存到数据库，除了用户名和图床名是明文外，其他的都是密文，这样可以保证用户的隐私。
  - 增加了软件主题切换的功能，增加了软件更新页面
  - 新设计了软件的图标和启动画面，同时对软件的UI进行了一些优化
  - 一些BUG修复
- 2022-10-02: **V1.00**: 项目初始化，完成基本的上传功能，目前仅支持兰空图床，需要手动授予存储和相机权限

## 下载

**安卓版**：

[https://www.horosama.com/self_apk/PicHoro_V1.4.1.apk](https://www.horosama.com/self_apk/PicHoro_V1.4.1.apk)

## 开发计划

- 增加对各种图床平台的支持，预计先写github和腾讯云存储的代码,已完成
  - [x] 兰空图床
  - [x] SM.MS
- 增加相册功能，可以查看已上传的图片并进行管理
- 增加软件更新后保留本地配置的功能
- 增加上传时的设置功能，如是否修改文件名等-**已实现**
- 增加上传后复制链接到剪贴板的功能，同时可以再设置里选择链接的格式-**已实现**
- 增加主动获取权限的功能，避免用户手动授予权限-**已实现**
- 增加相册图片多选上传功能-**已实现**
- 增加拍照后自动上传功能-**已实现**
- 增加上传或者等待时的loading动画-**已实现**
- 增加主题切换功能-**已实现**

## License

MIT

Copyright (c) 2022 Kuingsmile
