Map alistNewBucketTemplate = {
  "115 Cloud": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "cookie",
        "translate": "Cookie",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "需要 QR 代码令牌和 cookie 中的一个"
      },
      {
        "name": "qrcode_token",
        "translate": "二维码令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "需要 QR 代码令牌和 cookie 中的一个"
      },
      {
        "name": "qrcode_source",
        "translate": "Qrcode 源",
        "type": "select",
        "default": "linux",
        "options": "web,android,ios,linux,mac,windows,tv",
        "options_translate": "网页,安卓,iOS,Linux,Mac,Windows,Tv",
        "required": false,
        "help": "选择二维码设备，默认 linux"
      },
      {
        "name": "page_size",
        "translate": "每页数量",
        "type": "number",
        "default": "56",
        "options": "",
        "required": false,
        "help": "115 驱动程序的列表 API 的每页大小"
      },
      {
        "name": "limit_rate",
        "translate": "限制速率",
        "type": "number",
        "default": "2",
        "options": "",
        "required": false,
        "help": "限制所有 api 请求速率(1r/[limit_rate]s)"
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "0",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "config": {
      "name": "115 Cloud",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "0",
      "alert": ""
    }
  },
  "115 Share": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "cookie",
        "translate": "Cookie",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": "需要 QR 代码令牌和 cookie 中的一个"
      },
      {
        "name": "qrcode_token",
        "translate": "二维码令牌",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": "需要 QR 代码令牌和 cookie 中的一个"
      },
      {
        "name": "qrcode_source",
        "translate": "Qrcode 源",
        "type": "select",
        "default": "linux",
        "options": "web,android,ios,linux,mac,windows,tv",
        "options_translate": "网页,安卓,iOS,Linux,Mac,Windows,Tv",
        "required": false,
        "help": "选择二维码设备，默认 linux"
      },
      {
        "name": "page_size",
        "translate": "每页数量",
        "type": "number",
        "default": "20",
        "options": "",
        "required": false,
        "help": "115 驱动程序的列表 API 的每页大小"
      },
      {
        "name": "limit_rate",
        "translate": "限制速率",
        "type": "number",
        "default": "2",
        "options": "",
        "required": false,
        "help": "限制所有 api 请求速率(1r/[limit_rate]s)"
      },
      {
        "name": "share_code",
        "translate": "分享码",
        "type": "text",
        "default": "",
        "options": "",
        "required": true,
        "help": "分享链接的分享码"
      },
      {
        "name": "receive_code",
        "translate": "提取码",
        "type": "text",
        "default": "",
        "options": "",
        "required": true,
        "help": "115 分享链接提取码"
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "115 Share",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": true,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "123Pan": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "0",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "file_name",
        "options": "file_name,size,update_at",
        "options_translate": "文件名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "asc",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "123Pan",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "0",
      "alert": ""
    }
  },
  "123PanLink": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "origin_urls",
        "translate": "原始链接",
        "type": "text",
        "default": "https://vip.123pan.com/29/folder/file.mp3",
        "options": "",
        "required": true,
        "help": "结构: FolderName: [FileSize:][Modified:]Url"
      },
      {
        "name": "private_key",
        "translate": "私钥",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "uid",
        "translate": "账户uid",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "valid_duration",
        "translate": "有效时长",
        "type": "number",
        "default": "30",
        "options": "",
        "required": false,
        "help": "分钟"
      }
    ],
    "config": {
      "name": "123PanLink",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "123PanShare": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "sharekey",
        "translate": "分享key",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "sharepassword",
        "translate": "分享密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "0",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "file_name",
        "options": "file_name,size,update_at",
        "options_translate": "文件名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "asc",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "accesstoken",
        "translate": "访问令牌",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "123PanShare",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": true,
      "need_ms": false,
      "default_root": "0",
      "alert": ""
    }
  },
  "139Yun": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "proxy_range",
        "translate": "代理range",
        "type": "bool",
        "default": "true",
        "options": "",
        "required": false,
        "help": "Need to enable proxy"
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "authorization",
        "translate": "授权密钥",
        "type": "text",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "type",
        "translate": "类型",
        "type": "select",
        "default": "personal",
        "options": "personal,family,personal_new",
        "options_translate": "个人云,家庭云,新的个人盘",
        "required": false,
        "help": ""
      },
      {
        "name": "cloud_id",
        "translate": "Cloud ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "139Yun",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "189Cloud": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "cookie",
        "translate": "cookie",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "如果需要验证码 请填写cookie"
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "-11",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "config": {
      "name": "189Cloud",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "-11",
      "alert": "如果此驱动无法工作，你可以尝试使用“天翼网盘客户端”驱动。"
    }
  },
  "189CloudPC": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "validate_code",
        "translate": "验证码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "-11",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "filename",
        "options": "filename,filesize,lastOpTime",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "asc",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "type",
        "translate": "类型",
        "type": "select",
        "default": "personal",
        "options": "personal,family",
        "options_translate": "个人云,家庭云",
        "required": false,
        "help": ""
      },
      {
        "name": "family_id",
        "translate": "Family ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "upload_method",
        "translate": "上传方式",
        "type": "select",
        "default": "stream",
        "options": "stream,rapid,old",
        "options_translate": "流式,秒传,旧版",
        "required": false,
        "help": ""
      },
      {
        "name": "upload_thread",
        "translate": "上传线程数",
        "type": "string",
        "default": "3",
        "options": "",
        "required": false,
        "help": "1<=thread<=32"
      },
      {
        "name": "family_transfer",
        "translate": "家庭转移",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "rapid_upload",
        "translate": "秒传",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "no_use_ocr",
        "translate": "不使用OCR",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "189CloudPC",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "-11",
      "alert": ""
    }
  },
  "AList V2": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {"name": "url", "translate": "链接", "type": "string", "default": "", "options": "", "required": true, "help": ""},
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "access_token",
        "translate": "访问令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "AList V2",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": true,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "AList V3": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "proxy_range",
        "translate": "代理range",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": "Need to enable proxy"
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {"name": "url", "translate": "链接", "type": "string", "default": "", "options": "", "required": true, "help": ""},
      {
        "name": "meta_password",
        "translate": "元信息密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "token",
        "translate": "访问令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "AList V3",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "Alias": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "proxy_range",
        "translate": "代理range",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": "Need to enable proxy"
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {"name": "paths", "translate": "路径", "type": "string", "default": "", "options": "", "required": true, "help": ""}
    ],
    "config": {
      "name": "Alias",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": true,
      "no_upload": true,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "Aliyundrive": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "root",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,updated_at,created_at",
        "options_translate": "名称,大小,修改时间,创建时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "ASC,DESC",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "rapid_upload",
        "translate": "秒传",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "internal_upload",
        "translate": "内部上传",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "Aliyundrive",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "root",
      "alert": "在这个驱动中可能有一个死循环的错误。 已废弃，不再维护，并将在未来的版本中删除。 我们建议使用官方驱动的 阿里云盘Open。"
    }
  },
  "AliyundriveOpen": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "drive_type",
        "translate": "云盘类型",
        "type": "select",
        "default": "default",
        "options": "default,resource,backup",
        "options_translate": "默认,资源库,备份盘",
        "required": false,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "root",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,updated_at,created_at",
        "options_translate": "名称,大小,修改时间,创建时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "ASC,DESC",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "oauth_token_url",
        "translate": "OAuth令牌URL",
        "type": "string",
        "default": "https://api.nn.ci/alist/ali_open/token",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "如果你没有，请留空"
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "如果你没有，请留空"
      },
      {
        "name": "remove_way",
        "translate": "删除方式",
        "type": "select",
        "default": "",
        "options": "trash,delete",
        "options_translate": "移动到回收站,永久删除",
        "required": true,
        "help": ""
      },
      {
        "name": "rapid_upload",
        "translate": "秒传",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": "如果您启用此选项，文件将先上传到服务器，所以进度将不正确"
      },
      {
        "name": "internal_upload",
        "translate": "内部上传",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": "如果您在使用位于北京的阿里云服务器，您可以开启它来提高上传速度"
      },
      {
        "name": "livp_download_format",
        "translate": "Livp下载格式",
        "type": "select",
        "default": "jpeg",
        "options": "jpeg,mov",
        "options_translate": "JPEG,MOV",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "AliyundriveOpen",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "root",
      "alert": ""
    }
  },
  "AliyundriveShare": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "share_id",
        "translate": "分享ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "share_pwd",
        "translate": "分享密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "root",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,updated_at,created_at",
        "options_translate": "名称,大小,修改时间,创建时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "ASC,DESC",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "AliyundriveShare",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": true,
      "need_ms": false,
      "default_root": "root",
      "alert": ""
    }
  },
  "BaiduNetdisk": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "name",
        "options": "name,time,size",
        "options_translate": "名称,修改时间,大小",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "asc",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "download_api",
        "translate": "下载接口",
        "type": "select",
        "default": "official",
        "options": "official,crack",
        "options_translate": "官方,非官方",
        "required": false,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "iYCeC9g08h5vuP9UqvPHKKSVrKFXGa1v",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "jXiFMOPVPCWlO2M5CwWQzffpNPaGTRBG",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "custom_crack_ua",
        "translate": "自定义破解ua",
        "type": "string",
        "default": "netdisk",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "upload_thread",
        "translate": "上传线程",
        "type": "string",
        "default": "3",
        "options": "",
        "required": false,
        "help": "1<=thread<=32"
      },
      {
        "name": "upload_api",
        "translate": "上传接口",
        "type": "string",
        "default": "https://d.pcs.baidu.com",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "custom_upload_part_size",
        "translate": "自定义上传分块大小",
        "type": "number",
        "default": "0",
        "options": "",
        "required": false,
        "help": "0 表示根据VIP等级对应大小"
      }
    ],
    "config": {
      "name": "BaiduNetdisk",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "BaiduPhoto": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "show_type",
        "translate": "展示类型",
        "type": "select",
        "default": "root",
        "options": "root,root_only_album,root_only_file",
        "options_translate": "根目录,仅根目录下相册,仅根目录下文件",
        "required": false,
        "help": ""
      },
      {
        "name": "album_id",
        "translate": "相册ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "delete_origin",
        "translate": "删除原文件",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "iYCeC9g08h5vuP9UqvPHKKSVrKFXGa1v",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "jXiFMOPVPCWlO2M5CwWQzffpNPaGTRBG",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "upload_thread",
        "translate": "上传线程",
        "type": "string",
        "default": "3",
        "options": "",
        "required": false,
        "help": "1<=thread<=32"
      }
    ],
    "config": {
      "name": "BaiduPhoto",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "BaiduShare": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根目录路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "surl",
        "translate": "分享链接",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "pwd",
        "translate": "提取密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "BDUSS",
        "translate": "BDUSS",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "BaiduShare",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": true,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "ChaoXingGroupDrive": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "user_name",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "bbsid",
        "translate": "bbsid",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "-1",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "cookie",
        "translate": "cookie",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "ChaoXingGroupDrive",
      "local_sort": false,
      "only_local": false,
      "only_proxy": true,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "-1",
      "alert": ""
    }
  },
  "Cloudreve": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根目录路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "address",
        "translate": "地址",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "cookie",
        "translate": "cookie",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "custom_ua",
        "translate": "自定义UA",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_thumb_and_folder_size",
        "translate": "启用缩略图和文件夹大小",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "Cloudreve",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "Crypt": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "use to sort"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "filename_encryption",
        "translate": "文件名加密",
        "type": "select",
        "default": "off",
        "options": "off,standard,obfuscate",
        "options_translate": "关闭,标准,混淆",
        "required": true,
        "help": ""
      },
      {
        "name": "directory_name_encryption",
        "translate": "目录名加密",
        "type": "select",
        "default": "false",
        "options": "false,true",
        "options_translate": "关闭,开启",
        "required": true,
        "help": ""
      },
      {
        "name": "remote_path",
        "translate": "加密后文件存储路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "这是加密数据存储的位置"
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "the main password"
      },
      {
        "name": "salt",
        "translate": "加盐",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "如果您不知道什么是加盐，可以视为第二个密码。可选，推荐。"
      },
      {
        "name": "encrypted_suffix",
        "translate": "加密后缀",
        "type": "string",
        "default": ".bin",
        "options": "",
        "required": true,
        "help": "高级选项！加密的文件将使用此后缀"
      },
      {
        "name": "filename_encoding",
        "translate": "文件名编码",
        "type": "select",
        "default": "base64",
        "options": "base64,base32,base32768",
        "options_translate": "base64,base32,base32768",
        "required": true,
        "help": "for advanced user only!"
      },
      {
        "name": "thumbnail",
        "translate": "缩略图",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": "启用在缩略图文件夹下预先生成的缩略图"
      },
      {
        "name": "show_hidden",
        "translate": "显示隐藏",
        "type": "bool",
        "default": "true",
        "options": "",
        "required": false,
        "help": "显示隐藏目录以及文件"
      }
    ],
    "config": {
      "name": "Crypt",
      "local_sort": true,
      "only_local": false,
      "only_proxy": true,
      "no_cache": true,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "Doge": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根目录路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "bucket",
        "translate": "Bucket",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "endpoint",
        "translate": "Endpoint",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "region",
        "translate": "Region",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "access_key_id",
        "translate": "Access Key ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "secret_access_key",
        "translate": "Secret Access Key",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "session_token",
        "translate": "会话令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "custom_host",
        "translate": "自定义主机",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "sign_url_expire",
        "translate": "签名URL过期时间",
        "type": "number",
        "default": "4",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "placeholder",
        "translate": "占位文件名",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "force_path_style",
        "translate": "强制路径样式",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "list_object_version",
        "translate": "列出对象版本",
        "type": "select",
        "default": "v1",
        "options": "v1,v2",
        "required": false,
        "help": ""
      },
      {
        "name": "remove_bucket",
        "translate": "移除Bucket",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": "使用自定义主机时从路径中删除bucket名称。"
      },
      {
        "name": "add_filename_to_disposition",
        "translate": "添加文件名到内容头部",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": "添加filename到Content-Disposition头中。"
      }
    ],
    "config": {
      "name": "Doge",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "Dropbox": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根目录路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "oauth_token_url",
        "translate": "OAuth令牌URL",
        "type": "string",
        "default": "https://api.xhofe.top/alist/dropbox/token",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "Keep it empty if you don't have one"
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "Keep it empty if you don't have one"
      }
    ],
    "config": {
      "name": "Dropbox",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "FTP": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "address",
        "translate": "地址",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "config": {
      "name": "FTP",
      "local_sort": true,
      "only_local": true,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "FeijiPan": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "0",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "config": {
      "name": "FeijiPan",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "0",
      "alert": ""
    }
  },
  "GoogleDrive": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "root",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "例如: folder,name,modifiedTime"
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "202264815644.apps.googleusercontent.com",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "X4Z3ca8xfWDb1Voo-F9a7ZxJ",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "chunk_size",
        "translate": "分片大小",
        "type": "number",
        "default": "5",
        "options": "",
        "required": false,
        "help": "上传分块大小 (单位: MB)"
      }
    ],
    "config": {
      "name": "GoogleDrive",
      "local_sort": false,
      "only_local": false,
      "only_proxy": true,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "root",
      "alert": ""
    }
  },
  "GooglePhoto": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "root",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "202264815644.apps.googleusercontent.com",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "X4Z3ca8xfWDb1Voo-F9a7ZxJ",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "show_archive",
        "translate": "显示归档",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "GooglePhoto",
      "local_sort": true,
      "only_local": false,
      "only_proxy": true,
      "no_cache": false,
      "no_upload": true,
      "need_ms": false,
      "default_root": "root",
      "alert": ""
    }
  },
  "ILanZou": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "use to sort"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "0",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "config": {
      "name": "ILanZou",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "0",
      "alert": ""
    }
  },
  "IPFS API": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根目录路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "endpoint",
        "translate": "Endpoint",
        "type": "string",
        "default": "http://127.0.0.1:5001",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "gateway",
        "translate": "网关",
        "type": "string",
        "default": "https://ipfs.io",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "IPFS API",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "Lanzou": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "type",
        "translate": "类型",
        "type": "select",
        "default": "cookie",
        "options": "account,cookie,url",
        "options_translate": "账号,cookie,URL",
        "required": false,
        "help": ""
      },
      {
        "name": "account",
        "translate": "账号",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cookie",
        "translate": "Cookie",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "大概15天有效"
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "-1",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "share_password",
        "translate": "分享密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "baseUrl",
        "translate": "基础URL",
        "type": "string",
        "default": "https://pc.woozooo.com",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "shareUrl",
        "translate": "分享链接",
        "type": "string",
        "default": "https://pan.lanzouo.com",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "repair_file_info",
        "translate": "修复文件信息",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": "To use webdav, you need to enable it"
      }
    ],
    "config": {
      "name": "Lanzou",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "-1",
      "alert": ""
    }
  },
  "Lark": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "app_id",
        "translate": "app id",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": "app id"
      },
      {
        "name": "app_secret",
        "translate": "app secret",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": "app secret"
      },
      {
        "name": "external_mode",
        "translate": "外部预览模式",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": "external mode"
      },
      {
        "name": "tenant_url_prefix",
        "translate": "租户URL前缀",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": "tenant url prefix"
      }
    ],
    "config": {
      "name": "Lark",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "Local": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "thumbnail",
        "translate": "缩略图",
        "type": "bool",
        "default": "",
        "options": "",
        "required": true,
        "help": "启用缩略图"
      },
      {
        "name": "thumb_cache_folder",
        "translate": "缩略图缓存文件夹",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "show_hidden",
        "translate": "显示隐藏",
        "type": "bool",
        "default": "true",
        "options": "",
        "required": false,
        "help": "显示隐藏目录以及文件"
      },
      {
        "name": "mkdir_perm",
        "translate": "创建目录权限",
        "type": "string",
        "default": "777",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "recycle_bin_path",
        "translate": "回收站路径",
        "type": "string",
        "default": "delete permanently",
        "options": "",
        "required": false,
        "help": "回收站的路径，如果空或保留“永久删除”则永久删除"
      }
    ],
    "config": {
      "name": "Local",
      "local_sort": true,
      "only_local": true,
      "only_proxy": false,
      "no_cache": true,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "MediaTrack": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "access_token",
        "translate": "访问令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "project_id",
        "translate": "项目ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "title",
        "options": "updated_at,title,size",
        "options_translate": "修改时间,名称,大小",
        "required": false,
        "help": ""
      },
      {
        "name": "order_desc",
        "translate": "降序排列",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "MediaTrack",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "Mega_nz": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "email",
        "translate": "邮箱",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "two_fa_code",
        "translate": "2FA代码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "2FA 6位数字代码，仅填写2FA 代码将不支持重载驱动程序"
      },
      {
        "name": "two_fa_secret",
        "translate": "2FA密钥",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "2FA secret"
      }
    ],
    "config": {
      "name": "Mega_nz",
      "local_sort": true,
      "only_local": true,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "MoPan": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "phone",
        "translate": "手机号",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "sms_code",
        "translate": "短信验证码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "input 'send' send sms "
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "-11",
        "options": "",
        "required": true,
        "help": "be careful when using the -11 value, some operations may cause system errors"
      },
      {
        "name": "cloud_id",
        "translate": "Cloud Id",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "filename,filesize,lastOpTime",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "asc",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "device_info",
        "translate": "设备信息",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "upload_thread",
        "translate": "上传线程数",
        "type": "string",
        "default": "3",
        "options": "",
        "required": false,
        "help": "1<=thread<=32"
      }
    ],
    "config": {
      "name": "MoPan",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": "这个网盘可能将您的密码以明文存储，请小心设置您的密码"
    }
  },
  "NeteaseMusic": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "use to sort"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "cookie",
        "translate": "Cookie",
        "type": "text",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "song_limit",
        "translate": "歌曲数量限制",
        "type": "number",
        "default": "200",
        "options": "",
        "required": false,
        "help": "only get 200 songs by default"
      }
    ],
    "config": {
      "name": "NeteaseMusic",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "Onedrive": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "region",
        "translate": "地区",
        "type": "select",
        "default": "global",
        "options": "global,cn,us,de",
        "options_translate": "全局,世纪互联,美国版,德国版",
        "required": true,
        "help": ""
      },
      {
        "name": "is_sharepoint",
        "translate": "是否SharePoint",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "redirect_uri",
        "translate": "重定向URI",
        "type": "string",
        "default": "https://alist.nn.ci/tool/onedrive/callback",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "site_id",
        "translate": "站点ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "chunk_size",
        "translate": "分片大小",
        "type": "number",
        "default": "5",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "custom_host",
        "translate": "自定义主机",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "Custom host for onedrive download link"
      }
    ],
    "config": {
      "name": "Onedrive",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "OnedriveAPP": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "region",
        "translate": "地区",
        "type": "select",
        "default": "global",
        "options": "global,cn,us,de",
        "options_translate": "全局,世纪互联,美国版,德国版",
        "required": true,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "tenant_id",
        "translate": "租户ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "email",
        "translate": "账号",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "chunk_size",
        "translate": "分片大小",
        "type": "number",
        "default": "5",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "custom_host",
        "translate": "自定义主机",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "Custom host for onedrive download link"
      }
    ],
    "config": {
      "name": "OnedriveAPP",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "PikPak": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "YNxT9w7GMdWvEOKa",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "dbw2OtmVEeuUvIptb1Coyg",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "disable_media_link",
        "translate": "禁用媒体链接",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "PikPak",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "PikPakShare": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "share_id",
        "translate": "分享ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "share_pwd",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "YNxT9w7GMdWvEOKa",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "dbw2OtmVEeuUvIptb1Coyg",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "config": {
      "name": "PikPakShare",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": true,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "Quark": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "cookie",
        "translate": "Cookie",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "0",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "none",
        "options": "none,file_type,file_name,updated_at",
        "options_translate": "无,文件类型,文件名,更新时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "asc",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "Quark",
      "local_sort": false,
      "only_local": true,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "0",
      "alert": ""
    }
  },
  "Quqi": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "use to sort"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "0",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "phone",
        "translate": "手机号码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cookie",
        "translate": "Cookie",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "Cookie can be used on multiple clients at the same time"
      },
      {
        "name": "cdn",
        "translate": "CDN加速",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help":
            "If you enable this option, the download speed can be increased, but there will be some performance loss"
      }
    ],
    "config": {
      "name": "Quqi",
      "local_sort": true,
      "only_local": true,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "0",
      "alert": ""
    }
  },
  "S3": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "bucket",
        "translate": "存储桶",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "endpoint",
        "translate": "Endpoint",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "region",
        "translate": "地区",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "access_key_id",
        "translate": "访问密钥 Id",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "secret_access_key",
        "translate": "安全访问密钥",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "session_token",
        "translate": "会话令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "custom_host",
        "translate": "自定义HOST",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "sign_url_expire",
        "translate": "签名链接有效期",
        "type": "number",
        "default": "4",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "placeholder",
        "translate": "占位文件名",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "force_path_style",
        "translate": "强制路径样式",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "list_object_version",
        "translate": "列出对象版本",
        "type": "select",
        "default": "v1",
        "options": "v1,v2",
        "options_translate": "v1,v2",
        "required": false,
        "help": ""
      },
      {
        "name": "remove_bucket",
        "translate": "移除存储桶名",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": "Remove bucket name from path when using custom host."
      },
      {
        "name": "add_filename_to_disposition",
        "translate": "添加文件名到内容描述",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": "Add filename to Content-Disposition header."
      }
    ],
    "config": {
      "name": "S3",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "SFTP": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder_name",
        "translate": "提取文件夹名称",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "address",
        "translate": "地址",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "private_key",
        "translate": "私钥",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "ignore_symlink_error",
        "translate": "忽略符号链接错误",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "SFTP",
      "local_sort": true,
      "only_local": true,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "SMB": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": ".",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "address",
        "translate": "地址",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "share_name",
        "translate": "分享名称",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "config": {
      "name": "SMB",
      "local_sort": true,
      "only_local": true,
      "only_proxy": false,
      "no_cache": true,
      "no_upload": false,
      "need_ms": false,
      "default_root": ".",
      "alert": ""
    }
  },
  "Seafile": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": ".",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "address",
        "translate": "地址",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "token",
        "translate": "Token",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "repoId",
        "translate": "仓库ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "repoPwd",
        "translate": "仓库密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "Seafile",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "Teambition": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "region",
        "translate": "地区",
        "type": "select",
        "default": "",
        "options": "china,international",
        "options_translate": "中国,国际",
        "required": true,
        "help": ""
      },
      {
        "name": "cookie",
        "translate": "Cookie",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "project_id",
        "translate": "项目ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "fileName",
        "options": "fileName,fileSize,updated,created",
        "options_translate": "文件名,文件大小,更新时间,创建时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "Asc",
        "options": "Asc,Desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "use_s3_upload_method",
        "translate": "使用S3上传方法",
        "type": "bool",
        "default": "true",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "Teambition",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "Terabox": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "use to sort"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "The cache expiration time for this storage"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "cookie",
        "translate": "Cookie",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "download_api",
        "translate": "下载API",
        "type": "select",
        "default": "official",
        "options": "official,crack",
        "options_translate": "官方API,破解API",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "name",
        "options": "name,time,size",
        "options_translate": "名称,时间,大小",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "asc",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "Terabox",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "Thunder": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "captcha_token",
        "translate": "验证码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "Thunder",
      "local_sort": true,
      "only_local": false,
      "only_proxy": true,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "ThunderExpert": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "login_type",
        "translate": "登录类型",
        "type": "select",
        "default": "user",
        "options": "user,refresh_token",
        "options_translate": "用户名,刷新令牌",
        "required": false,
        "help": ""
      },
      {
        "name": "sign_type",
        "translate": "签名类型",
        "type": "select",
        "default": "algorithms",
        "options": "algorithms,captcha_sign",
        "options_translate": "算法,验证码签名",
        "required": false,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "登录类型是用户名时必填"
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "登录类型是用户名时必填"
      },
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "登录类型是刷新令牌时必填"
      },
      {
        "name": "algorithms",
        "translate": "算法",
        "type": "string",
        "default":
            "HPxr4BVygTQVtQkIMwQH33ywbgYG5l4JoR,GzhNkZ8pOBsCY+7,v+l0ImTpG7c7/,e5ztohgVXNP,t,EbXUWyVVqQbQX39Mbjn2geok3/0WEkAVxeqhtx857++kjJiRheP8l77gO,o7dvYgbRMOpHXxCs,6MW8TD8DphmakaxCqVrfv7NReRRN7ck3KLnXBculD58MvxjFRqT+,kmo0HxCKVfmxoZswLB4bVA/dwqbVAYghSb,j,4scKJNdd7F27Hv7tbt",
        "options": "",
        "required": true,
        "help": "签名类型是算法时必填"
      },
      {
        "name": "captcha_sign",
        "translate": "验证码签名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "签名类型是验证码签名时必填"
      },
      {
        "name": "timestamp",
        "translate": "时间戳",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "签名类型是验证码签名时必填"
      },
      {
        "name": "captcha_token",
        "translate": "验证码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "device_id",
        "translate": "设备ID",
        "type": "string",
        "default": "9aa5c268e7bcfc197a9ad88e2fb330e5",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "Xp6vsxz_7IYVw2BB",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "Xp6vsy4tN9toTVdMSpomVdXpRmES",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_version",
        "translate": "客户端版本",
        "type": "string",
        "default": "7.51.0.8196",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "package_name",
        "translate": "包名",
        "type": "string",
        "default": "com.xunlei.downloadprovider",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "user_agent",
        "translate": "用户代理",
        "type": "string",
        "default":
            "ANDROID-com.xunlei.downloadprovider/7.51.0.8196 netWorkType/4G appid/40 deviceName/Xiaomi_M2004j7ac deviceModel/M2004J7AC OSVersion/12 protocolVersion/301 platformVersion/10 sdkVersion/220200 Oauth2Client/0.9 (Linux 4_14_186-perf-gdcf98eab238b) (JAVA 0)",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "download_user_agent",
        "translate": "下载用户代理",
        "type": "string",
        "default": "Dalvik/2.1.0 (Linux; U; Android 12; M2004J7AC Build/SP1A.210812.016)",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "use_video_url",
        "translate": "使用视频URL",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "ThunderExpert",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "ThunderX": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "use to sort"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "The cache expiration time for this storage"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "captcha_token",
        "translate": "验证码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "use_video_url",
        "translate": "使用视频URL",
        "type": "bool",
        "default": "true",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "ThunderX",
      "local_sort": true,
      "only_local": false,
      "only_proxy": true,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "ThunderXExpert": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "use to sort"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "The cache expiration time for this storage"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "login_type",
        "translate": "登录类型",
        "type": "select",
        "default": "user",
        "options": "user,refresh_token",
        "options_translate": "用户名,刷新令牌",
        "required": false,
        "help": ""
      },
      {
        "name": "sign_type",
        "translate": "签名类型",
        "type": "select",
        "default": "algorithms",
        "options": "algorithms,captcha_sign",
        "options_translate": "算法,验证码签名",
        "required": false,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "login type is user,this is required"
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "login type is user,this is required"
      },
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "login type is refresh_token,this is required"
      },
      {
        "name": "algorithms",
        "translate": "算法",
        "type": "string",
        "default":
            "lHwINjLeqssT28Ym99p5MvR,xvFcxvtqPKCa9Ajf,2ywOP8spKHzfuhZMUYZ9IpsViq0t8vT0,FTBrJism20SHKQ2m2,BHrWJsPwjnr5VeLtOUr2191X9uXhWmt,yu0QgHEjNmDoPNwXN17so2hQlDT83T,OcaMfLMCGZ7oYlvZGIbTqb4U7cCY,jBGGu0GzXOjtCXYwkOBb+c6TZ/Nymv,YLWRjVor2rOuYEL,94wjoPazejyNC+gRpOj+JOm1XXvxa",
        "options": "",
        "required": true,
        "help": "sign type is algorithms,this is required"
      },
      {
        "name": "captcha_sign",
        "translate": "验证码签名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "sign type is captcha_sign,this is required"
      },
      {
        "name": "timestamp",
        "translate": "时间戳",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "sign type is captcha_sign,this is required"
      },
      {
        "name": "captcha_token",
        "translate": "验证码",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "device_id",
        "translate": "设备ID",
        "type": "string",
        "default": "9aa5c268e7bcfc197a9ad88e2fb330e5",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "ZQL_zwA4qhHcoe_2",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "Og9Vr1L8Ee6bh0olFxFDRg",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_version",
        "translate": "客户端版本",
        "type": "string",
        "default": "1.05.0.2115",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "package_name",
        "translate": "包名",
        "type": "string",
        "default": "com.thunder.downloader",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "user_agent",
        "translate": "UA",
        "type": "string",
        "default":
            "ANDROID-com.thunder.downloader/1.05.0.2115 netWorkType/4G appid/40 deviceName/Xiaomi_M2004j7ac deviceModel/M2004J7AC OSVersion/12 protocolVersion/301 platformVersion/10 sdkVersion/220200 Oauth2Client/0.9 (Linux 4_14_186-perf-gdcf98eab238b) (JAVA 0)",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "download_user_agent",
        "translate": "下载UA",
        "type": "string",
        "default": "Dalvik/2.1.0 (Linux; U; Android 12; M2004J7AC Build/SP1A.210812.016)",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "use_video_url",
        "translate": "使用视频URL",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "ThunderXExpert",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "Trainbit": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "use to sort"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期时间",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "The cache expiration time for this storage"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理URL,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "前置,后置",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "0_000",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "AUSHELLPORTAL",
        "translate": "AUSHELLPORTAL",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "apikey",
        "translate": "apikey",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "config": {
      "name": "Trainbit",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "0_000",
      "alert": ""
    }
  },
  "UC": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "cookie",
        "translate": "Cookie",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "none",
        "options": "none,file_type,file_name,updated_at",
        "options_translate": "无,类型,名称,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "asc",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "UC",
      "local_sort": false,
      "only_local": true,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "0",
      "alert": ""
    }
  },
  "USS": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "bucket",
        "translate": "存储桶",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "endpoint",
        "translate": "Endpoint",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "operator_name",
        "translate": "操作员",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "operator_password",
        "translate": "操作员密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "anti_theft_chain_token",
        "translate": "防盗链Token",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "sign_url_expire",
        "translate": "签名URL过期时间",
        "type": "number",
        "default": "4",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "USS",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "UrlTree": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "use to sort"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "url_structure",
        "translate": "URL结构",
        "type": "text",
        "default":
            "https://jsd.nn.ci/gh/alist-org/alist/README.md\nhttps://jsd.nn.ci/gh/alist-org/alist/README_cn.md\nfolder:\n  CONTRIBUTING.md:1635:https://jsd.nn.ci/gh/alist-org/alist/CONTRIBUTING.md\n  CODE_OF_CONDUCT.md:2093:https://jsd.nn.ci/gh/alist-org/alist/CODE_OF_CONDUCT.md",
        "options": "",
        "required": true,
        "help": "structure:FolderName:\n  [FileName:][FileSize:][Modified:]Url"
      },
      {
        "name": "head_size",
        "translate": "获取文件大小",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": false,
        "help": "Use head method to get file size, but it may be failed."
      }
    ],
    "config": {
      "name": "UrlTree",
      "local_sort": true,
      "only_local": false,
      "only_proxy": false,
      "no_cache": true,
      "no_upload": true,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "VTencent": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "The path you want to mount to, it is unique and cannot be repeated"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "use to sort"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "The cache expiration time for this storage"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "type": "select",
        "default": "",
        "options": "front,back",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "提取文件夹",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "9",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "cookie",
        "translate": "Cookie",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "tf_uid",
        "translate": "UID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "Name,Size,UpdateTime,CreatTime",
        "options_translate": "名称,大小,修改时间,创建时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "Asc,Desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "VTencent",
      "local_sort": false,
      "only_local": false,
      "only_proxy": true,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "9",
      "alert": ""
    }
  },
  "Virtual": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "num_file",
        "translate": "文件数量",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "num_folder",
        "translate": "文件夹数量",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "max_file_size",
        "translate": "最大文件大小",
        "type": "number",
        "default": "1073741824",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "min_file_size",
        "translate": "最小文件大小",
        "type": "number",
        "default": "1048576",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "config": {
      "name": "Virtual",
      "local_sort": true,
      "only_local": true,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": true,
      "default_root": "",
      "alert": ""
    }
  },
  "WebDav": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "",
        "options": "name,size,modified",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "vendor",
        "translate": "供应商",
        "type": "select",
        "default": "other",
        "options": "sharepoint,other",
        "options_translate": "SharePoint,其他",
        "required": false,
        "help": ""
      },
      {
        "name": "address",
        "translate": "地址",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "username",
        "translate": "用户名",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "password",
        "translate": "密码",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "tls_insecure_skip_verify",
        "translate": "跳过TLS验证",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "WebDav",
      "local_sort": true,
      "only_local": false,
      "only_proxy": true,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  },
  "WeiYun": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": "要挂载到的路径，它是唯一的，不能重复"
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "use to sort"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "native_proxy",
        "options": "use_proxy_url,native_proxy",
        "options_translate": "使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cookies",
        "translate": "Cookies",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "name",
        "options": "name,size,updated_at",
        "options_translate": "名称,大小,修改时间",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "asc",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "upload_thread",
        "translate": "上传线程数",
        "type": "string",
        "default": "4",
        "options": "",
        "required": false,
        "help": "4<=thread<=32"
      }
    ],
    "config": {
      "name": "WeiYun",
      "local_sort": false,
      "only_local": false,
      "only_proxy": true,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "",
      "alert": ""
    }
  },
  "WoPan": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "root_folder_id",
        "translate": "根文件夹ID",
        "type": "string",
        "default": "0",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "family_id",
        "translate": "家庭ID",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": "Keep it empty if you want to use your personal drive"
      },
      {
        "name": "sort_rule",
        "translate": "排序规则",
        "type": "select",
        "default": "name_asc",
        "options": "name_asc,name_desc,time_asc,time_desc,size_asc,size_desc",
        "options_translate": "名称升序,名称降序,时间升序,时间降序,大小升序,大小降序",
        "required": false,
        "help": ""
      },
      {
        "name": "access_token",
        "translate": "访问令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      }
    ],
    "config": {
      "name": "WoPan",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "0",
      "alert": ""
    }
  },
  "YandexDisk": {
    "common": [
      {
        "name": "mount_path",
        "translate": "挂载路径",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order",
        "translate": "序号",
        "type": "number",
        "default": "",
        "options": "",
        "required": false,
        "help": "用于排序"
      },
      {
        "name": "remark",
        "translate": "备注",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "cache_expiration",
        "translate": "缓存过期分钟",
        "type": "number",
        "default": "30",
        "options": "",
        "required": true,
        "help": "此存储的缓存过期时间(分钟)"
      },
      {
        "name": "web_proxy",
        "translate": "Web代理",
        "type": "bool",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "webdav_policy",
        "translate": "WebDAV策略",
        "type": "select",
        "default": "302_redirect",
        "options": "302_redirect,use_proxy_url,native_proxy",
        "options_translate": "302重定向,使用代理地址,本地代理",
        "required": true,
        "help": ""
      },
      {
        "name": "down_proxy_url",
        "translate": "下载代理URL",
        "type": "text",
        "default": "",
        "options": "",
        "required": false,
        "help": ""
      },
      {
        "name": "extract_folder",
        "translate": "提取文件夹",
        "type": "select",
        "default": "",
        "options": "front,back",
        "options_translate": "提取到最前,提取到最后",
        "required": false,
        "help": ""
      },
      {
        "name": "enable_sign",
        "translate": "启用签名",
        "type": "bool",
        "default": "false",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "additional": [
      {
        "name": "refresh_token",
        "translate": "刷新令牌",
        "type": "string",
        "default": "",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "order_by",
        "translate": "排序",
        "type": "select",
        "default": "name",
        "options": "name,path,created,modified,size",
        "options_translate": "名称,路径,创建时间,修改时间,大小",
        "required": false,
        "help": ""
      },
      {
        "name": "order_direction",
        "translate": "排序方向",
        "type": "select",
        "default": "asc",
        "options": "asc,desc",
        "options_translate": "升序,降序",
        "required": false,
        "help": ""
      },
      {
        "name": "root_folder_path",
        "translate": "根文件夹路径",
        "type": "string",
        "default": "/",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_id",
        "translate": "客户端ID",
        "type": "string",
        "default": "a78d5a69054042fa936f6c77f9a0ae8b",
        "options": "",
        "required": true,
        "help": ""
      },
      {
        "name": "client_secret",
        "translate": "客户端密钥",
        "type": "string",
        "default": "9c119bbb04b346d2a52aa64401936b2b",
        "options": "",
        "required": true,
        "help": ""
      }
    ],
    "config": {
      "name": "YandexDisk",
      "local_sort": false,
      "only_local": false,
      "only_proxy": false,
      "no_cache": false,
      "no_upload": false,
      "need_ms": false,
      "default_root": "/",
      "alert": ""
    }
  }
};
