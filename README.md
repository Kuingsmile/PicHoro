
<div align="center">
  <img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_05_633d79e401694.png" alt="">
  <h1>PicHoro</h1>

# PicHoro

Mobile tool for pictures uploading built by flutter

一款基于flutter的移动端图片上传工具，已支持兰空图床，正在研究添加各种其它图床的支持，个人开发用于学习flutter和替代很久没更新了的[flutter-Picgo](https://github.com/PicGo/flutter-picgo)。

@author: Horosama

@email: ma_shiqing@163.com

## 应用截图

<table rules="none" align="center">
<tr>
<td>
<center>
<img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_05_633d85a4eb29d.jpg" width="97%" height = 105%/>
<br/>
<font color="AAAAAA">主页.jpg</font>
</center>
</td>
<td>
<center>
<img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_05_633d859a5d809.jpg" width="100%" />
<br/>
<font color="AAAAAA">设置.jpg</font>
</center>
</td>
</tr>
</table>

## 最近更新

  详细更新日志请查看[更新日志](https://github.com/Kuingsmile/PicHoro/blob/main/Version_update_log.md "更新日志")

- 2002-10-04: **V1.30**:
  - 重构了整个APP的代码架构，把所有的页面和功能性函数都放在了对应文件夹里，方便后续的维护和扩展，同时抽象了上传等功能的接口，后续增加图床时可以直接调用。
  - 增加了用户登录和拉取云端配置的功能，可以通过用户名和密码登录，将图床配置等保存在服务器上，这里现在用户本地用3DES加密然后再保存到数据库，除了用户名和图床名是明文外，其他的都是密文，这样可以保证用户的隐私。
  - 增加了软件主题切换的功能，增加了软件更新页面
  - 新设计了软件的图标和启动画面，同时对软件的UI进行了一些优化
  - 一些BUG修复
- 2002-10-04: **V1.21**:
  - 增加了上传图片和配置图床时的等待动画
  - 在设置页面增加了底部导航栏，修改了部分按钮的名字
  - 调整了部分弹出式提示框的实现方式，修改为自动消失的小提示框，同时部分重要提示框禁止了点击背景消失
  - 修复了项目地址页面打不开的问题
  - 优化了部分代码
- 2002-10-03: **V1.20**:
  - 现在从相册里选择照片的时候可以多选了，上传功能也更新为批量上传
  - 增加了新的设置页面，可以在设置页面里选择图床配置，项目地址和联系作者
  - 重构了部分代码，为后续增加图床平台做准备
  - 优化了页面布局，改变了部分UI
- 2022-10-02: **V1.00**: 项目初始化，完成基本的上传功能，目前仅支持兰空图床，需要手动授予存储和相机权限

## 下载

**安卓版**：

<div align =center>
<img src="http://imgx.horosama.com/admin_uploads/2022/10/2022_10_05_633d79dbadc96.png" width=30% alt ='http://www.horosama.com/self_apk/PicHoro.apk'>
</div>

## 开发计划

- 增加对各种图床平台的支持，预计先写github和腾讯云存储的代码
- 增加上传时的设置功能，如是否修改文件名等
- 增加上传后复制链接到剪贴板的功能
- 增加主动获取权限的功能，避免用户手动授予权限-**已实现**
- 增加相册图片多选上传功能-**已实现**
- 增加拍照后自动上传功能-**已实现**
- 增加上传或者等待时的loading动画-**已实现**
- 增加主题切换功能-**已实现**

## License

[MIT](http://opensource.org/licenses/MIT)

Copyright (c) 2022 Kuingsmile
