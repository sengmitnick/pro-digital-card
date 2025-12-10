# 阿里云邮件推送故障排查指南

## 错误：535 Authentication failure

### 问题描述

```
邮件发送失败：535 Authentication failure[0] [@ud010301]
```

这是 SMTP 认证失败的错误，表示用户名或密码不正确。

### 常见原因

#### 1. 使用了错误的密码 ⚠️

**最常见错误**：使用了阿里云控制台的登录密码，而不是 SMTP 密码。

**正确做法**：
- 阿里云邮件推送的 SMTP 密码需要单独为每个发信地址设置
- SMTP 密码 ≠ 阿里云账号密码

#### 2. 发信地址未验证

发信地址必须先在阿里云控制台验证通过才能使用。

#### 3. 用户名格式错误

阿里云邮件推送的用户名必须是完整的邮箱地址。

## 解决步骤

### 第一步：检查配置的环境变量

```bash
# 在生产环境中运行
rails runner "
  puts 'SMTP Address: ' + ENV['EMAIL_SMTP_ADDRESS'].to_s
  puts 'SMTP Port: ' + ENV['EMAIL_SMTP_PORT'].to_s
  puts 'SMTP Username: ' + ENV['EMAIL_SMTP_USERNAME'].to_s
  puts 'SMTP Password: ' + (ENV['EMAIL_SMTP_PASSWORD'].present? ? '[已设置]' : '[未设置]')
  puts 'SMTP Domain: ' + ENV['EMAIL_SMTP_DOMAIN'].to_s
"
```

**正确的配置示例**：
```
SMTP Address: smtpdm.aliyun.com
SMTP Port: 465
SMTP Username: noreply@card.qinglion.com
SMTP Password: [已设置]
SMTP Domain: card.qinglion.com
```

### 第二步：设置 SMTP 密码（重要！）

#### 2.1 登录阿里云控制台

1. 访问阿里云控制台：https://dm.console.aliyun.com/
2. 进入"邮件推送"服务

#### 2.2 找到发信地址管理

1. 在左侧菜单中选择"发信地址"
2. 找到你要使用的发信地址（如 `noreply@card.qinglion.com`）

#### 2.3 设置/重置 SMTP 密码

1. 点击发信地址右侧的"设置 SMTP 密码"按钮
2. 输入新的 SMTP 密码（建议使用强密码）
3. 确认并保存

**重要提示**：
- SMTP 密码是单独设置的，不是你的阿里云账号密码
- 每个发信地址都需要单独设置 SMTP 密码
- 如果忘记了 SMTP 密码，可以重新设置

#### 2.4 更新环境变量

将新设置的 SMTP 密码更新到环境变量中：

```yaml
# config/application.yml 或环境变量
EMAIL_SMTP_PASSWORD: '你刚刚设置的SMTP密码'
```

**如果使用 Clacky 部署**，设置环境变量：
```bash
CLACKY_EMAIL_API_KEY='你刚刚设置的SMTP密码'
```

### 第三步：验证发信地址状态

#### 3.1 检查发信地址是否验证通过

在阿里云控制台的"发信地址"页面，确认：
- ✅ 状态显示为"验证通过"
- ✅ 域名验证状态为"已验证"

#### 3.2 验证域名（如果未验证）

1. 在阿里云控制台点击"发信域名"
2. 添加你的域名（如 `card.qinglion.com`）
3. 按照提示添加 SPF、MX、CNAME 记录到你的 DNS 服务商

**需要添加的 DNS 记录**：

**SPF 记录**（TXT 记录）：
```
主机记录: @
记录类型: TXT
记录值: v=spf1 include:spf.mxhichina.com -all
```

**MX 记录**：
```
主机记录: @
记录类型: MX
记录值: mxn.mxhichina.com
优先级: 10
```

**CNAME 记录**（域名验证）：
```
主机记录: （阿里云提供的随机值）
记录类型: CNAME
记录值: （阿里云提供的验证值）
```

### 第四步：测试 SMTP 连接

创建测试脚本 `tmp/test_smtp.rb`：

```ruby
require 'net/smtp'

smtp_address = ENV['EMAIL_SMTP_ADDRESS']
smtp_port = ENV['EMAIL_SMTP_PORT'].to_i
smtp_username = ENV['EMAIL_SMTP_USERNAME']
smtp_password = ENV['EMAIL_SMTP_PASSWORD']

puts "测试 SMTP 连接..."
puts "地址: #{smtp_address}"
puts "端口: #{smtp_port}"
puts "用户名: #{smtp_username}"
puts "密码: #{smtp_password.present? ? '[已设置]' : '[未设置]'}"
puts ""

begin
  smtp = Net::SMTP.new(smtp_address, smtp_port)
  smtp.enable_ssl if smtp_port == 465
  smtp.enable_starttls_auto if smtp_port != 465
  
  smtp.start('localhost', smtp_username, smtp_password, :login) do |smtp_session|
    puts "✅ SMTP 连接成功！认证通过。"
  end
rescue Net::SMTPAuthenticationError => e
  puts "❌ SMTP 认证失败：#{e.message}"
  puts ""
  puts "可能的原因："
  puts "1. SMTP 密码不正确（最常见）"
  puts "2. 用户名格式错误（应该是完整邮箱地址）"
  puts "3. 发信地址未在阿里云控制台设置 SMTP 密码"
rescue => e
  puts "❌ 连接失败：#{e.class} - #{e.message}"
end
```

运行测试：
```bash
rails runner tmp/test_smtp.rb
```

### 第五步：使用正确的配置重新测试

#### 5.1 确认最终配置

```yaml
# config/application.yml 或环境变量
EMAIL_SMTP_ADDRESS: 'smtpdm.aliyun.com'
EMAIL_SMTP_PORT: '465'
EMAIL_SMTP_USERNAME: 'noreply@card.qinglion.com'  # 完整邮箱地址
EMAIL_SMTP_PASSWORD: '在阿里云控制台设置的SMTP密码'  # 不是阿里云账号密码！
EMAIL_SMTP_DOMAIN: 'card.qinglion.com'
```

#### 5.2 重启应用

```bash
# 如果修改了环境变量，需要重启
touch tmp/restart.txt
```

#### 5.3 重新发送邮件

在后台管理页面点击"重新发送邮件"按钮测试。

## 其他常见问题

### 问题 1：端口选择

**推荐端口**：
- **465**（SSL）：推荐使用，安全性高
- **80**（非加密）：备选方案，某些网络环境下可用
- ❌ **25**：大部分云服务器禁用此端口

**测试不同端口**：
```bash
# 测试端口 465
telnet smtpdm.aliyun.com 465

# 测试端口 80
telnet smtpdm.aliyun.com 80
```

### 问题 2：发信地址与 SMTP 用户名不匹配

**错误配置**：
```yaml
EMAIL_SMTP_USERNAME: 'admin@example.com'     # 这个地址没有在阿里云配置
EMAIL_SMTP_DOMAIN: 'card.qinglion.com'       # 域名不匹配
```

**正确配置**：
```yaml
EMAIL_SMTP_USERNAME: 'noreply@card.qinglion.com'  # 必须是已配置的发信地址
EMAIL_SMTP_DOMAIN: 'card.qinglion.com'            # 域名匹配
```

### 问题 3：发信地址未审核通过

新创建的发信地址需要审核，审核期间无法使用。

**解决方法**：
1. 登录阿里云控制台
2. 查看"发信地址"状态
3. 如果显示"审核中"，需要等待审核通过（通常几分钟到几小时）
4. 如果审核失败，查看失败原因并重新提交

### 问题 4：超出发送额度

**免费版限额**：
- 每日 200 封
- 每月 2000 封

**解决方法**：
- 升级到标准版或企业版
- 或等待配额重置（每日或每月）

## 完整的配置检查清单

使用此清单逐项检查：

- [ ] 已在阿里云控制台添加并验证域名
- [ ] 已添加 SPF、MX、CNAME DNS 记录
- [ ] 已创建发信地址（如 `noreply@yourdomain.com`）
- [ ] 发信地址状态为"验证通过"
- [ ] 已为该发信地址设置 SMTP 密码（不是阿里云账号密码）
- [ ] `EMAIL_SMTP_USERNAME` 是完整的邮箱地址
- [ ] `EMAIL_SMTP_PASSWORD` 是在阿里云控制台设置的 SMTP 密码
- [ ] `EMAIL_SMTP_ADDRESS` 是 `smtpdm.aliyun.com`
- [ ] `EMAIL_SMTP_PORT` 是 `465`
- [ ] `EMAIL_SMTP_DOMAIN` 与发信地址的域名一致
- [ ] 已重启应用使配置生效

## 调试命令

### 1. 检查环境变量是否加载

```bash
rails runner "
  puts '=' * 50
  puts 'SMTP Configuration Check'
  puts '=' * 50
  puts \"ADDRESS: #{ENV['EMAIL_SMTP_ADDRESS']}\"
  puts \"PORT: #{ENV['EMAIL_SMTP_PORT']}\"
  puts \"USERNAME: #{ENV['EMAIL_SMTP_USERNAME']}\"
  puts \"PASSWORD: #{ENV['EMAIL_SMTP_PASSWORD'].present? ? 'Set (length: ' + ENV['EMAIL_SMTP_PASSWORD'].length.to_s + ')' : 'NOT SET'}\"
  puts \"DOMAIN: #{ENV['EMAIL_SMTP_DOMAIN']}\"
  puts '=' * 50
"
```

### 2. 测试发送邮件

```bash
rails runner "
  user = User.find_by(email: 'test@example.com')
  if user
    begin
      UserMailer.with(user: user).password_reset.deliver_now
      puts '✅ 邮件发送成功'
    rescue => e
      puts '❌ 邮件发送失败'
      puts \"错误: #{e.class}\"
      puts \"消息: #{e.message}\"
    end
  else
    puts '❌ 用户不存在'
  end
"
```

### 3. 查看详细的 SMTP 日志

在 `config/environments/production.rb` 或 `development.rb` 中临时启用 SMTP 日志：

```ruby
config.action_mailer.smtp_settings = {
  # ... 其他配置 ...
  enable_starttls_auto: smtp_port == 465 ? false : true,
  ssl: smtp_port == 465 ? true : false,
  tls: smtp_port == 465 ? true : false,
  authentication: :login,
  open_timeout: 10,
  read_timeout: 10,
  # 添加调试日志
  logger: Logger.new(STDOUT),
  enable_debug_log: true
}
```

## 联系支持

如果以上步骤都无法解决问题，可以联系阿里云技术支持：

- 工单系统：https://workorder.console.aliyun.com/
- 电话支持：95187
- 邮件推送文档：https://help.aliyun.com/product/29412.html

提供以下信息有助于快速解决问题：
- 阿里云账号 ID
- 发信域名
- 发信地址
- 错误信息和时间
- SMTP 配置（不要包含密码）

## 参考资料

- [阿里云邮件推送官方文档](https://help.aliyun.com/product/29412.html)
- [SMTP 接口说明](https://help.aliyun.com/document_detail/29439.html)
- [常见错误代码](https://help.aliyun.com/document_detail/51640.html)
