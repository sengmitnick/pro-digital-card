# 注册功能屏蔽说明

## 概述

本系统已屏蔽所有公开注册入口，用户只能通过管理员发送的邀请链接加入。

**重要**：所有视图中均无注册或申请入口，邀请链接由管理员通过其他渠道（邮件、微信等）发送给成员。

## 修改内容

### 1. 路由更改 (config/routes.rb)
- ❌ 已禁用: `sign_up_path` (GET/POST)
- ❌ 已禁用: `resources :registrations`
- ❌ 已禁用: API 注册端点 `POST /api/v1/sign_up`
- ✅ 保留: `invitation_path` (需要有效 token)

### 2. 视图更改
所有注册/申请入口已移除，替换为提示文案：
- **导航栏** (`app/views/shared/_navbar.html.erb`): 移除注册按钮，仅保留登录
- **首页** (`app/views/home/index.html.erb`): 移除所有申请按钮，替换为"联系管理员获取邀请链接"文案
- **登录页** (`app/views/sessions/new.html.erb`): 移除注册链接，显示"请联系管理员获取邀请链接"

### 3. 邀请页面保护
- 邀请页面 (`/invitation/new`) 必须提供有效的 `token` 参数
- 无 token 访问会被重定向到首页并提示"邀请链接无效或已过期"

### 4. 用户激活流程
- **通过邀请链接**: 用户通过管理员发送的带 token 的链接提交信息
- **创建状态**: 用户创建后状态为 `activated: false`, `status: 'pending'`
- **管理员审批**: 管理员在后台批准后，用户状态变为 `activated: true`, `status: 'approved'`
- **OAuth 用户**: OAuth 登录的新用户也需要管理员审批才能激活

### 5. 测试更新
- 更新 `spec/requests/authenticated_access_spec.rb` 验证:
  - `sign_up_path` 已不可用（抛出 NameError）
  - 邀请页面无 token 访问被重定向
  - 邀请页面有效 token 访问成功
- 所有测试通过验证

## 管理员如何邀请成员

### 方式一：通过组织邀请链接
1. 访问 `/admin/organization/members` 查看组织邀请链接
2. 复制邀请链接（格式：`/invitation/new?token=xxx`）
3. 通过邮件、微信等渠道发送给待邀请成员
4. 成员点击链接填写信息提交
5. 管理员在后台审核通过

### 方式二：直接添加已注册用户
1. 访问 `/admin/organization/members`
2. 在"添加用户"表单中输入用户邮箱
3. 点击"添加用户"按钮
4. 用户自动加入已批准成员列表并激活

### 查看待审核用户
访问: `/admin/organization/members`

### 批准用户
1. 在待审核列表中点击"通过"按钮
2. 系统自动发送邮件通知用户
3. 用户收到邮件后设置密码即可登录

## 用户注册流程

### 当前流程
1. 用户通过管理员发送的邀请链接访问 `/invitation/new?token=xxx`
2. 填写申请信息（邮箱、姓名、职位等）
3. 系统创建待审核用户 (`activated: false`)
4. 管理员在后台审核通过
5. 系统发送审批通过邮件，包含设置密码链接
6. 用户设置密码后可以登录

## 相关文件

- 路由配置: `config/routes.rb`
- 邀请控制器: `app/controllers/invitations_controller.rb`
- 用户模型: `app/models/user.rb`
- Profile 模型: `app/models/profile.rb`
- 视图文件:
  - `app/views/shared/_navbar.html.erb`
  - `app/views/home/index.html.erb`
  - `app/views/sessions/new.html.erb`
  - `app/views/invitations/new.html.erb`
- 测试文件: 
  - `spec/requests/authenticated_access_spec.rb`
  - `spec/requests/invitations_spec.rb`

## 如何获取组织邀请链接

管理员可以通过以下方式获取邀请链接：

```bash
# 使用 Rails console
bundle exec rails console
org = Organization.first
puts org.invite_url
# 输出示例: http://localhost:3000/invitation/new?token=abc123...

# 或者使用 rake task
bundle exec rake organization:show
```

## 恢复注册功能

如需恢复公开注册，需要：
1. 取消 `config/routes.rb` 中的注册路由注释
2. 恢复视图中的注册按钮和链接
3. 调整 `User.from_omniauth` 中的 `activated: false` 改为 `activated: true`
4. 更新相关测试文件
