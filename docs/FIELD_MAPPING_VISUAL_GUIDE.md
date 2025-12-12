# 字段映射可视化指南

## 📊 快速导航

- [页面结构总览](#页面结构总览)
- [Hero Section 映射](#hero-section-映射)
- [Why Section 映射](#why-section-映射)
- [How Section 映射](#how-section-映射)
- [What Section 映射](#what-section-映射)
- [CTA Section 映射](#cta-section-映射)
- [后台操作路径](#后台操作路径)

---

## 页面结构总览

```
┌─────────────────────────────────────────────────────────────────┐
│                        Hero Section (Picture)                    │
│  ┌────────┐  ┌──────────────────────────────────────────────┐ │
│  │ Avatar │  │ Full Name (H1)                                │ │
│  │  128px │  │ Title · Company                               │ │
│  └────────┘  │ 📍 Location                                   │ │
│              │ [Tag1] [Tag2] [Tag3]...                       │ │
│              └──────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Why Section (Promise)                       │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ [Background Image]                                          │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ⚡ 为什么选择我？                                              │
│  Why - 我的使命与价值主张                                      │
│                                                                  │
│  Bio 内容（多段落文本）                                         │
│  Lorem ipsum dolor sit amet...                                  │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                       How Section (Process)                      │
│  🛡️ 我如何帮助您？                                             │
│  How - 专业方法与服务优势                                       │
│                                                                  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐              │
│  │ ✓ 优势1    │  │ ✓ 优势2    │  │ ✓ 优势3    │              │
│  │  标题      │  │  标题      │  │  标题      │              │
│  │  描述...   │  │  描述...   │  │  描述...   │              │
│  └────────────┘  └────────────┘  └────────────┘              │
│                                                                  │
│  服务流程                                                        │
│  ①──────→  ②──────→  ③──────→  ④                           │
│  流程1      流程2      流程3      流程4                          │
│  标题       标题       标题       标题                            │
│  描述       描述       描述       描述                            │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                       What Section (Prove)                       │
│  🏆 我做过什么？                                                │
│  What - 成功案例与专业认可                                      │
│                                                                  │
│  成功案例                                                        │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ [1] 案例标题   [分类]  2024年6月                           │ │
│  │     案例描述详细内容...                                     │ │
│  ├───────────────────────────────────────────────────────────┤ │
│  │ [2] 案例标题   [分类]  2024年5月                           │ │
│  │     案例描述详细内容...                                     │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                  │
│  荣誉与认证                                                      │
│  ┌──────────────┐  ┌──────────────┐                          │
│  │ ⭐ 荣誉标题  │  │ ⭐ 荣誉标题  │                          │
│  │   颁发机构    │  │   颁发机构    │                          │
│  │   2023年3月   │  │   2023年5月   │                          │
│  └──────────────┘  └──────────────┘                          │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                        CTA Section (Push)                        │
│                  💬 准备好开始了吗？                             │
│         无论您有任何问题或需求，我们随时为您服务                │
│                                                                  │
│     [🗨️ 立即咨询]          [👥 了解团队]                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Hero Section 映射

### 视觉布局

```
┌──────────────────────────────────────────────────────────────┐
│  渐变背景 (primary → primary-dark → secondary)                │
│                                                                │
│   ┌─────────┐      ┌────────────────────────────────────┐   │
│   │         │      │ 张伟                    ← full_name│   │
│   │ Avatar  │      │ 高级咨询顾问 · 青狮满天星           │   │
│   │         │      │    ↑title      ↑company             │   │
│   │ 128x128 │      │                                      │   │
│   │         │      │ 📍 北京  ← location                 │   │
│   └─────────┘      │                                      │   │
│                    │ [企业战略咨询] [数字化转型]         │   │
│                    │ [团队管理] ← specializations        │   │
│                    └────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

### 字段映射表

| 前台元素 | 后台字段 | 后台位置 | 数据类型 | 必填 |
|---------|---------|---------|---------|-----|
| 大标题 | `Profile.full_name` | Profiles → Edit → Full name | String | ✅ |
| 副标题（职位） | `Profile.title` | Profiles → Edit → Title | String | ✅ |
| 副标题（公司） | `Profile.company` | Profiles → Edit → Company | String | ❌ |
| 位置徽章 | `Profile.location` | Profiles → Edit → Location | String | ❌ |
| 头像图片 | `Profile.avatar` | Profiles → Edit → Avatar | File | ❌ |
| 头像备用 | `Profile.avatar_url` | Profiles → Edit → Avatar url | URL | ❌ |
| 专业标签 | `Profile.specializations` | Profiles → Edit → Specializations | JSON | ❌ |

### 后台编辑路径

```
后台首页
  └─ Profiles (侧边栏)
      └─ 点击您的名片
          └─ Edit 按钮
              ├─ Full name *
              ├─ Title *
              ├─ Company
              ├─ Location
              ├─ Avatar (file upload)
              ├─ Avatar url
              └─ Specializations (JSON format)
```

### Specializations 数据格式

```json
["企业战略咨询", "数字化转型", "团队管理", "商业模式创新"]
```

**注意：**
- 必须使用 JSON 数组格式
- 使用英文双引号和逗号
- 建议 3-5 个标签

---

## Why Section 映射

### 视觉布局

```
┌──────────────────────────────────────────────────────────────┐
│ [背景图片 - 可选]                   ← background_image       │
│ 1920x1080px                                                   │
└──────────────────────────────────────────────────────────────┘

┌────┐
│ ⚡ │  为什么选择我？                    ← 固定标题
└────┘  Why - 我的使命与价值主张            ← 固定副标题

┌──────────────────────────────────────────────────────────────┐
│ 我致力于帮助企业和个人实现数字化转型，相信技术与人文的融合 │
│ 能创造更大价值。                                             │
│                                                                │
│ 在过去15年中，我累计服务50+世界500强企业，涵盖制造、金融、 │
│ 零售等多个行业。我的服务方法强调理论与实践结合，注重为每位 │
│ 客户量身定制解决方案。                    ← bio (200-500字) │
│                                                                │
│ 期待与您探讨如何将我的专业经验转化为您的成功助力。         │
└──────────────────────────────────────────────────────────────┘
```

### 字段映射表

| 前台元素 | 后台字段 | 后台位置 | 数据类型 | 必填 |
|---------|---------|---------|---------|-----|
| 主标题 | 固定文本："为什么选择我？" | - | - | - |
| 副标题 | 固定文本："Why - 我的使命与价值主张" | - | - | - |
| 背景图片 | `Profile.background_image` | Profiles → Edit → Background image | File | ❌ |
| 正文内容 | `Profile.bio` | Profiles → Edit → Bio | Text | ✅ |

### 后台编辑路径

```
后台首页
  └─ Profiles
      └─ Edit
          ├─ Bio * (textarea, 200-500字)
          └─ Background image (file upload, 1920x1080px)
```

### Bio 撰写建议

使用黄金圈法则结构：

1. **Why（1-2句）** - 使命与信念
2. **How（2-3句）** - 方法与优势  
3. **What（1-2句）** - 成果与影响

**示例：**
```
[Why] 我致力于帮助企业实现数字化转型。

[How] 拥有15年咨询经验，曾服务50+企业，擅长战略规划、
流程优化和团队赋能，注重理论与实践结合。

[What] 帮助客户平均提升30%运营效率，获得98%客户满意度。
```

---

## How Section 映射

### 视觉布局

```
┌────┐
│ 🛡️│  我如何帮助您？                    ← 固定标题
└────┘  How - 专业方法与服务优势          ← 固定副标题

┌────────────────┐ ┌────────────────┐ ┌────────────────┐
│ ✓ 十年行业经验 │ │ ✓ 智能服务     │ │ ✓ 品质保证     │
│  ↑ adv_1_title │ │  ↑ adv_2_title │ │  ↑ adv_3_title │
│                 │ │                 │ │                 │
│ 团队平均从业   │ │ 24小时AI助手   │ │ 严格的服务标准 │
│ 10年，服务...  │ │ 随时为客户...   │ │ 确保每一次...   │
│ ↑ adv_1_desc   │ │ ↑ adv_2_desc   │ │ ↑ adv_3_desc   │
└────────────────┘ └────────────────┘ └────────────────┘

──────────────────────────────────────────────────────────────
服务流程                                        ← 固定标题

 ① ──────→  ② ──────→  ③ ──────→  ④
了解需求      匹配专家      专业服务      持续跟进
↑proc_1       ↑proc_2       ↑proc_3       ↑proc_4
_title        _title        _title        _title

深入沟通，    智能推荐最    提供专业、    确保服务质量，
准确把握您的  合适的团队    高效的解决    持续优化体验
需求和期望    成员为您服务  方案
↑proc_1_desc  ↑proc_2_desc  ↑proc_3_desc  ↑proc_4_desc
```

### 服务优势字段映射

| 前台元素 | 后台字段 | 后台位置 | 数据类型 | 建议长度 |
|---------|---------|---------|---------|---------|
| 优势1标题 | `Organization.service_advantage_1_title` | 组织设置 → 服务优势 → 优势1 | String | 4-10字 |
| 优势1描述 | `Organization.service_advantage_1_description` | 同上 | Text | 30-80字 |
| 优势2标题 | `Organization.service_advantage_2_title` | 组织设置 → 服务优势 → 优势2 | String | 4-10字 |
| 优势2描述 | `Organization.service_advantage_2_description` | 同上 | Text | 30-80字 |
| 优势3标题 | `Organization.service_advantage_3_title` | 组织设置 → 服务优势 → 优势3 | String | 4-10字 |
| 优势3描述 | `Organization.service_advantage_3_description` | 同上 | Text | 30-80字 |

### 服务流程字段映射

| 前台元素 | 后台字段 | 后台位置 | 数据类型 | 建议长度 |
|---------|---------|---------|---------|---------|
| 流程1标题 | `Organization.service_process_1_title` | 组织设置 → 服务流程 → 步骤1 | String | 4-8字 |
| 流程1描述 | `Organization.service_process_1_description` | 同上 | Text | 15-40字 |
| 流程2标题 | `Organization.service_process_2_title` | 组织设置 → 服务流程 → 步骤2 | String | 4-8字 |
| 流程2描述 | `Organization.service_process_2_description` | 同上 | Text | 15-40字 |
| 流程3标题 | `Organization.service_process_3_title` | 组织设置 → 服务流程 → 步骤3 | String | 4-8字 |
| 流程3描述 | `Organization.service_process_3_description` | 同上 | Text | 15-40字 |
| 流程4标题 | `Organization.service_process_4_title` | 组织设置 → 服务流程 → 步骤4 | String | 4-8字 |
| 流程4描述 | `Organization.service_process_4_description` | 同上 | Text | 15-40字 |

### 后台编辑路径

```
后台首页
  └─ 组织设置 (侧边栏)
      └─ 编辑组织信息
          ├─ 服务优势 Section
          │   ├─ 优势1 (标题 + 描述)
          │   ├─ 优势2 (标题 + 描述)
          │   └─ 优势3 (标题 + 描述)
          │
          └─ 服务流程 Section
              ├─ 步骤1 (标题 + 描述)
              ├─ 步骤2 (标题 + 描述)
              ├─ 步骤3 (标题 + 描述)
              └─ 步骤4 (标题 + 描述)
```

---

## What Section 映射

### 视觉布局

```
┌────┐
│ 🏆 │  我做过什么？                      ← 固定标题
└────┘  What - 成功案例与专业认可          ← 固定副标题

成功案例                                    ← 固定副标题
┌──────────────────────────────────────────────────────────────┐
│ [1] 某大型企业数字化转型咨询项目  [企业咨询]  2024年6月     │
│     ↑ title                        ↑ category  ↑ date        │
│                                                                │
│     为某世界500强企业提供全面的数字化转型咨询服务，         │
│     帮助其建立数字化战略框架，实现运营效率提升35%...        │
│     ↑ description                                             │
├──────────────────────────────────────────────────────────────┤
│ [2] 另一个案例标题...                                        │
└──────────────────────────────────────────────────────────────┘

荣誉与认证                                  ← 固定副标题
┌─────────────────────┐  ┌─────────────────────┐
│ ⭐ PMP 国际项目管理  │  │ ⭐ MBA 工商管理硕士 │
│    专业人士          │  │                      │
│    ↑ title          │  │    ↑ title          │
│                      │  │                      │
│ PMI 国际项目管理协会 │  │ 清华大学经济管理学院│
│ ↑ organization      │  │ ↑ organization      │
│                      │  │                      │
│ 2023年3月           │  │ 2020年6月           │
│ ↑ date              │  │ ↑ date              │
│                      │  │                      │
│ 全球认可的项目管理  │  │ (description可选)   │
│ 专业资格认证        │  │                      │
│ ↑ description       │  │                      │
└─────────────────────┘  └─────────────────────┘
```

### Case Studies 字段映射

| 前台元素 | 后台字段 | 后台位置 | 数据类型 | 必填 |
|---------|---------|---------|---------|-----|
| 序号 | 自动生成 | - | Number | - |
| 案例标题 | `CaseStudy.title` | Case studies → New → Title | String | ✅ |
| 分类标签 | `CaseStudy.category` | Case studies → New → Category | String | ❌ |
| 完成日期 | `CaseStudy.date` | Case studies → New → Date | String | ❌ |
| 详细描述 | `CaseStudy.description` | Case studies → New → Description | Text | ✅ |
| 排序位置 | `CaseStudy.position` | Case studies → New → Position | Integer | ❌ |
| 所属名片 | `CaseStudy.profile_id` | Case studies → New → Profile | Select | ✅ |

### Honors 字段映射

| 前台元素 | 后台字段 | 后台位置 | 数据类型 | 必填 |
|---------|---------|---------|---------|-----|
| 图标 | 固定：金色星星 | - | SVG | - |
| 荣誉标题 | `Honor.title` | Honors → New → Title | String | ✅ |
| 颁发机构 | `Honor.organization` | Honors → New → Organization | String | ✅ |
| 获得日期 | `Honor.date` | Honors → New → Date | String | ❌ |
| 补充说明 | `Honor.description` | Honors → New → Description | Text | ❌ |
| 所属名片 | `Honor.profile_id` | Honors → New → Profile | Select | ✅ |

### 后台编辑路径

```
后台首页
  ├─ Case studies (侧边栏)
  │   └─ New Case study
  │       ├─ Title *
  │       ├─ Category
  │       ├─ Date
  │       ├─ Description * (textarea)
  │       ├─ Position (排序)
  │       └─ Profile * (选择所属名片)
  │
  └─ Honors (侧边栏)
      └─ New Honor
          ├─ Title *
          ├─ Organization *
          ├─ Date
          ├─ Description
          └─ Profile * (选择所属名片)
```

### 排序规则

**Case Studies 排序：**
```
ORDER BY position ASC, created_at DESC
```
- Position 越小越靠前
- 相同 position 按创建时间倒序

**Honors 排序：**
```
ORDER BY date DESC, created_at DESC
```
- 日期越新越靠前
- 相同日期按创建时间倒序

---

## CTA Section 映射

### 视觉布局

```
┌──────────────────────────────────────────────────────────────┐
│              渐变背景 (primary/5 → secondary/5)               │
│                                                                │
│                        ┌────┐                                 │
│                        │ 💬 │                                 │
│                        └────┘                                 │
│                                                                │
│                   准备好开始了吗？                            │
│                   ↑ cta_title                                 │
│                                                                │
│       无论您有任何问题或需求，我们的专业团队随时             │
│       准备为您提供帮助。首次咨询完全免费...                  │
│       ↑ cta_description                                       │
│                                                                │
│     ┌──────────────────┐    ┌──────────────────┐            │
│     │ 🗨️ 立即咨询      │    │ 👥 了解团队      │            │
│     │  (btn-primary)   │    │  (btn-outline)   │            │
│     └──────────────────┘    └──────────────────┘            │
│          ↓ 跳转到                 ↓ 跳转到                   │
│       consultations              teams                        │
└──────────────────────────────────────────────────────────────┘
```

### 字段映射表

| 前台元素 | 后台字段 | 后台位置 | 数据类型 | 必填 | 建议长度 |
|---------|---------|---------|---------|-----|---------|
| 图标 | 固定：对话图标 | - | SVG | - | - |
| 主标题 | `Organization.cta_title` | 组织设置 → 行动号召 → CTA标题 | String | ❌ | 8-20字 |
| 描述文案 | `Organization.cta_description` | 组织设置 → 行动号召 → CTA描述 | Text | ❌ | 30-80字 |
| 按钮1 | 固定："立即咨询" | - | - | - | - |
| 按钮2 | 固定："了解团队" | - | - | - | - |

### 后台编辑路径

```
后台首页
  └─ 组织设置
      └─ 行动号召 (CTA) Section
          ├─ CTA 标题
          │   例如：准备好开始了吗？
          │
          └─ CTA 描述
              例如：无论您有任何问题或需求，我们的专业团队
              随时准备为您提供帮助。首次咨询完全免费，让我们
              一起探索最适合您的解决方案。
```

### 按钮行为

| 按钮 | 样式 | 链接目标 | 说明 |
|------|------|---------|------|
| 立即咨询 | `btn-primary btn-lg` | `/consultations?profile_id=XXX` | 跳转到咨询页面 |
| 了解团队 | `btn-outline-primary btn-lg` | `/teams?profile_id=XXX` | 跳转到团队页面 |

---

## 后台操作路径

### 快速导航

```
登录后台 (https://your-domain.com/admin)
│
├─ Profiles (编辑个人信息)
│   ├─ 选择您的名片
│   └─ Edit 按钮
│       ├─ Basic Info: full_name*, title*, company, location
│       ├─ Bio: bio* (200-500字)
│       ├─ Images: avatar, background_image
│       └─ Specializations: specializations (JSON)
│
├─ 组织设置 (编辑组织服务信息)
│   └─ 编辑组织信息
│       ├─ 基本信息: name*, description, logo
│       ├─ 服务优势 (3组): title + description
│       ├─ 服务流程 (4步): title + description
│       └─ 行动号召: cta_title, cta_description
│
├─ Case studies (添加成功案例)
│   └─ New Case study
│       ├─ title*, category, date
│       ├─ description*, position
│       └─ profile_id*
│
└─ Honors (添加荣誉认证)
    └─ New Honor
        ├─ title*, organization*
        ├─ date, description
        └─ profile_id*
```

### 操作优先级

**必填项（最小可展示）：**
1. ✅ Profile: full_name, title, bio
2. ✅ 保存即可基本展示

**推荐补充（完整展示）：**
1. 🌟 Profile: location, specializations, avatar
2. 🌟 Organization: 服务优势（3组）、服务流程（4步）
3. 🌟 Case studies: 至少3个案例
4. 🌟 Honors: 至少3个荣誉
5. 🌟 Organization: CTA标题和描述

**可选增强：**
- Profile: background_image
- Organization: logo, background_image
- 更多 case studies 和 honors

---

## 数据流向图

```
┌─────────────┐
│   管理员     │
│  (登录后台)  │
└──────┬──────┘
       │
       ├──────────────┐
       │              │
       ▼              ▼
┌─────────────┐  ┌──────────────┐
│  编辑        │  │  添加         │
│  Profile    │  │  Case/Honor  │
│  ├─基本信息 │  │  ├─案例标题  │
│  ├─Bio      │  │  ├─案例描述  │
│  ├─头像     │  │  └─排序      │
│  └─标签     │  │              │
└──────┬──────┘  └──────┬───────┘
       │                 │
       │  ┌──────────────┤
       │  │              │
       ▼  ▼              ▼
┌─────────────────────────────┐
│      编辑 Organization       │
│      ├─服务优势 (3组)       │
│      ├─服务流程 (4步)       │
│      └─行动号召 (CTA)       │
└──────────┬──────────────────┘
           │
           │ 保存
           ▼
┌─────────────────────────────┐
│        数据库存储            │
│   ├─ profiles 表            │
│   ├─ organizations 表       │
│   ├─ case_studies 表        │
│   └─ honors 表              │
└──────────┬──────────────────┘
           │
           │ 查询
           ▼
┌─────────────────────────────┐
│      前台名片页面渲染        │
│   ├─ Hero Section           │
│   ├─ Why Section            │
│   ├─ How Section            │
│   ├─ What Section           │
│   └─ CTA Section            │
└─────────────────────────────┘
           │
           ▼
┌─────────────────────────────┐
│       访客浏览名片          │
│   (https://domain.com/c/xxx)│
└─────────────────────────────┘
```

---

## 条件渲染逻辑

### 区块显示规则

```ruby
# Why Section
if @profile.bio.present?
  显示 Why Section
end

# How Section  
if @profile.organization&.service_advantage_1_title.present? || 
   @profile.organization&.service_process_1_title.present?
  显示 How Section
end

# What Section - Case Studies
if @case_studies.present?
  显示成功案例区块
end

# What Section - Honors
if @honors.present?
  显示荣誉认证区块
end

# CTA Section
if @profile.organization&.cta_title.present?
  显示 CTA Section
end
```

### 最小可展示配置

```
✅ Profile.full_name = "张伟"
✅ Profile.title = "高级咨询顾问"
✅ Profile.bio = "我致力于..."

→ 页面显示：Hero + Why Section
→ 其他区块自动隐藏
```

### 完整展示配置

```
✅ 所有 Profile 字段已填写
✅ Organization 服务优势3组已填写
✅ Organization 服务流程4步已填写  
✅ Organization CTA已填写
✅ 至少3个 Case Studies
✅ 至少3个 Honors

→ 页面显示：所有5个 Section
→ 内容丰富，完美呈现
```

---

## 常见问题映射

### Q: 为什么某个区块没有显示？

**检查清单：**

| 区块 | 检查字段 | 后台位置 |
|------|---------|---------|
| Hero | full_name, title | Profiles → Edit → 前两个字段 |
| Why | bio | Profiles → Edit → Bio |
| How | service_advantage_1_title 或 service_process_1_title | 组织设置 → 服务优势/服务流程 |
| What - Cases | case_studies 表有记录 | Case studies → 列表 |
| What - Honors | honors 表有记录 | Honors → 列表 |
| CTA | cta_title | 组织设置 → 行动号召 |

### Q: 如何修改某个具体文本？

使用 Ctrl+F 搜索该文本，对照上方映射表找到对应后台字段。

---

**最后更新：** 2024-12-11  
**文档版本：** 1.0
