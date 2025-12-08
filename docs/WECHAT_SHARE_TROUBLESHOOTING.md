# 微信分享功能排查指南

## 当前状态

✅ **前端集成完成**：
- Stimulus controller 已正确挂载到 `app/views/cards/show.html.erb`
- 使用外部 API：`https://www.qinglion.com/api/v1/wechat_signatures`
- 已集成 vConsole 调试工具

## 使用 vConsole 调试

### 启用 vConsole

在 URL 后添加 `?vconsole=1` 参数：

```
https://card.qinglion.com/c/sengmitnick?vconsole=1
```

vConsole 会在页面右下角显示一个绿色的浮动按钮。点击即可打开调试面板。

### vConsole 功能

- **Console**: 查看所有 console.log/error/warn 输出
- **Network**: 查看所有网络请求和响应
- **Element**: 查看 DOM 元素
- **Storage**: 查看 localStorage/Cookie 等
- **System**: 查看系统信息

## 排查步骤

### 第一步：在微信内置浏览器中打开页面

**重要**：微信 JS-SDK 只在微信内置浏览器中生效！

1. 打开微信
2. 发送链接到任意聊天：`https://card.qinglion.com/c/sengmitnick?vconsole=1`
3. 点击链接在微信浏览器中打开
4. 点击右下角绿色按钮打开 vConsole

### 第二步：查看控制台日志

在 vConsole 的 Console 标签中，查找以下日志：

#### 正常流程应该看到：

```javascript
"vConsole loaded - check bottom-right corner for debug panel"
"WechatShare controller connected"
"WeChat JS-SDK not loaded, loading now..."
// 如果签名 API 调用失败会看到：
"Failed to get WeChat signature: ..."
// 或
"Error initializing WeChat share: ..."
// 如果成功会看到：
"WeChat JS-SDK ready"
"Share to chat configured"
"Share to timeline configured"
```

### 第三步：检查网络请求

在 vConsole 的 Network 标签中，找到这个请求：

**请求应该是：**
```
POST https://www.qinglion.com/api/v1/wechat_signatures
```

点击查看详情，检查：

1. **Request Payload**:
```json
{
  "url": "https://card.qinglion.com/c/sengmitnick"
}
```

2. **Response**（应该是 200 状态码）:
```json
{
  "success": true,
  "data": {
    "appId": "wx...",
    "timestamp": "...",
    "nonceStr": "...",
    "signature": "..."
  }
}
```

### 第四步：检查可能的问题

#### 问题 1：vConsole 未出现

**症状**：右下角没有绿色按钮

**解决**：
- 确认 URL 包含 `?vconsole=1`
- 检查网络是否能访问 `unpkg.com`
- 查看 Network 标签确认 vconsole.min.js 是否加载成功

#### 问题 2：controller 未连接

**症状**：Console 中没有 "WechatShare controller connected" 日志

**可能原因**：
- JS 未正确编译
- Stimulus controller 未注册

**解决**：
```bash
# 重新构建
npm run build
# 检查构建输出
ls -lh app/assets/builds/application.js
```

#### 问题 3：外部 API 不可访问

**症状**：
- Network 标签显示请求失败（红色）
- Console 显示 "Error initializing WeChat share"
- 或看到 CORS 错误

**检查**：
1. 在 vConsole Network 中查看具体错误
2. 测试 API 是否可访问：
```bash
curl -X POST https://www.qinglion.com/api/v1/wechat_signatures \
  -H "Content-Type: application/json" \
  -d '{"url": "https://card.qinglion.com/c/sengmitnick"}'
```

**可能原因**：
- API 服务器不可达
- CORS 配置问题（API 需要允许 `card.qinglion.com` 域名）
- API 返回格式不正确

#### 问题 4：签名验证失败

**症状**：
- Console 显示 "WeChat JS-SDK error"
- 可能看到类似错误：`{errMsg: "config:invalid signature"}`

**可能原因**：
1. URL 格式问题
2. 域名未在微信公众号配置 JS 安全域名
3. timestamp/nonceStr/signature 计算错误

**解决**：
1. 确保 `card.qinglion.com` 已添加到微信公众号的 JS接口安全域名
2. 检查 vConsole Network 中 API 返回的签名数据
3. 联系 API 管理员验证签名生成逻辑

#### 问题 5：权限问题

**症状**：Console 显示 `{errMsg: "config:permission denied"}`

**解决**：
- 确认域名已在微信公众号后台配置
- 路径：公众号设置 > 功能设置 > JS接口安全域名
- 必须添加：`card.qinglion.com`（不带 http/https）

### 第五步：手动测试 API

在 vConsole 的 Console 标签中，点击输入框，输入以下代码测试：

```javascript
// 1. 测试 API 调用
fetch('https://www.qinglion.com/api/v1/wechat_signatures', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ 
    url: 'https://card.qinglion.com/c/sengmitnick' 
  })
})
.then(res => res.json())
.then(data => console.log('API Response:', data))
.catch(err => console.error('API Error:', err))

// 2. 检查微信 SDK 是否加载
console.log('wx object:', typeof wx)

// 3. 检查当前 URL
console.log('Current URL:', window.location.href)
console.log('URL without fragment:', window.location.href.split('#')[0])
```

## 快速验证清单

- [ ] URL 包含 `?vconsole=1` 参数
- [ ] 在微信浏览器中打开页面（不是普通浏览器）
- [ ] 右下角看到绿色 vConsole 按钮
- [ ] Console 看到 "WechatShare controller connected"
- [ ] 微信 JS-SDK 脚本加载成功
- [ ] Network 中看到 POST 请求到外部 API
- [ ] API 返回 200 状态码和正确的签名数据
- [ ] Console 看到 "WeChat JS-SDK ready"
- [ ] 没有看到任何错误消息
- [ ] `card.qinglion.com` 已添加到微信公众号 JS安全域名

## 常见错误代码

| 错误消息 | 含义 | 解决方法 |
|---------|------|----------|
| `config:invalid url domain` | 当前页面所在域名与使用的 appId 没有绑定 | 添加域名到 JS安全域名 |
| `config:invalid signature` | 签名错误 | 检查签名生成逻辑，确保 URL 正确 |
| `config:permission denied` | 没有权限 | 检查 appId 是否正确，域名是否配置 |
| `the permission value is offline verifying` | 正在验证权限 | 等待几分钟重试 |
| `Network request failed` | 网络请求失败 | 检查 API 是否可访问，查看 CORS 配置 |

## 示例：正常的调试输出

```javascript
// vConsole Console 标签
vConsole loaded - check bottom-right corner for debug panel
WechatShare controller connected
WeChat JS-SDK not loaded, loading now...
WeChat JS-SDK ready
Share to chat configured
Share to timeline configured

// vConsole Network 标签
POST https://www.qinglion.com/api/v1/wechat_signatures
Status: 200 OK
Response: {
  "success": true,
  "data": {
    "appId": "wx1234567890abcdef",
    "timestamp": "1701234567",
    "nonceStr": "abc123",
    "signature": "a1b2c3d4e5f6..."
  }
}
```

## 生产环境使用

### 临时启用调试

生产环境中，只有带 `?vconsole=1` 参数的 URL 才会加载 vConsole：

```
https://card.qinglion.com/c/sengmitnick?vconsole=1
```

普通用户访问时不会看到 vConsole（无性能影响）：

```
https://card.qinglion.com/c/sengmitnick
```

### 永久禁用（可选）

如果要完全禁用 vConsole，修改 `app/views/layouts/application.html.erb`：

```erb
<!-- 删除或注释这段代码 -->
<% if Rails.env.development? || params[:vconsole] == '1' %>
  <script src="https://unpkg.com/vconsole@latest/dist/vconsole.min.js"></script>
  <script>
    var vConsole = new window.VConsole();
    console.log('vConsole loaded - check bottom-right corner for debug panel');
  </script>
<% end %>
```

## 微信公众号配置检查

### 必须配置的项目

1. **JS接口安全域名**
   - 登录：https://mp.weixin.qq.com/
   - 路径：设置与开发 > 公众号设置 > 功能设置 > JS接口安全域名
   - 添加：`card.qinglion.com`（不带协议）

2. **验证文件**
   - 微信会要求下载一个 MP_verify_xxx.txt 文件
   - 将文件放到 `public/` 目录
   - 确保可访问：`https://card.qinglion.com/MP_verify_xxx.txt`

## 外部 API 要求

外部签名 API 必须满足：

1. **CORS 配置**
   ```
   Access-Control-Allow-Origin: https://card.qinglion.com
   Access-Control-Allow-Methods: POST
   Access-Control-Allow-Headers: Content-Type
   ```

2. **返回格式**
   ```json
   {
     "success": true,
     "data": {
       "appId": "wx...",
       "timestamp": "1234567890",
       "nonceStr": "random_string",
       "signature": "sha1_hash",
       "url": "https://card.qinglion.com/c/sengmitnick"
     }
   }
   ```

3. **签名算法**
   ```
   签名字符串 = jsapi_ticket={ticket}&noncestr={nonce}&timestamp={ts}&url={url}
   signature = SHA1(签名字符串)
   ```

## 联系支持

### 外部 API 问题
- API Endpoint: https://www.qinglion.com/api/v1/wechat_signatures
- 需要联系 API 管理员确认：
  - CORS 配置是否正确
  - 签名生成逻辑是否正确
  - API 是否正常运行

### 微信公众号配置
- 登录: https://mp.weixin.qq.com/
- 检查 JS接口安全域名配置
- 确保域名验证文件可访问

### 前端集成问题
- 检查文件：`app/javascript/controllers/wechat_share_controller.ts`
- 检查视图：`app/views/cards/show.html.erb`
- 检查布局：`app/views/layouts/application.html.erb`
- 运行测试：`bundle exec rspec spec/javascript/stimulus_validation_spec.rb`

## 附录：完整的调试流程

1. 访问 `https://card.qinglion.com/c/sengmitnick?vconsole=1`
2. 点击右下角绿色按钮打开 vConsole
3. 切换到 Console 标签，查看日志
4. 切换到 Network 标签，查看 API 请求
5. 如有错误，根据错误消息查阅上方的"常见错误代码"
6. 记录所有错误信息，提供给技术支持
