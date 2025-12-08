# MCP Tools for AI Profile Management

This document describes the MCP (Model Context Protocol) tools available for AI-powered profile updates through the Dashboard Assistant.

## Overview

The AI assistant uses conversational understanding to update profile information. The current implementation uses natural language processing within the `DashboardAssistantService` to extract update intentions and apply them.

## Available Tools

### 1. Update Profile Basic Info
**Tool Name:** `update_profile_basic`

**Description:** Updates basic profile information like name, title, company.

**Parameters:**
```json
{
  "full_name": "string (optional)",
  "title": "string (optional)",
  "company": "string (optional)"
}
```

**Example Usage:**
```
User: "把我的职位改成高级律师"
AI: [Extracts intent and calls update] → {"title": "高级律师"}
```

### 2. Update Contact Information
**Tool Name:** `update_profile_contact`

**Description:** Updates contact details including phone, email, and location.

**Parameters:**
```json
{
  "phone": "string (optional)",
  "email": "string (optional)",
  "location": "string (optional)"
}
```

**Example Usage:**
```
User: "我的新电话是 138-1234-5678"
AI: [Extracts intent and calls update] → {"phone": "138-1234-5678"}
```

### 3. Update Professional Details
**Tool Name:** `update_profile_professional`

**Description:** Updates professional information including bio and specializations.

**Parameters:**
```json
{
  "bio": "string (optional)",
  "specializations": ["array of strings (optional)"]
}
```

**Example Usage:**
```
User: "添加专业领域：合同法和知识产权"
AI: [Extracts intent and calls update] → {"specializations": ["合同法", "知识产权"]}
```

### 4. Update Professional Stats
**Tool Name:** `update_profile_stats`

**Description:** Updates professional statistics and metrics.

**Parameters:**
```json
{
  "stats": {
    "years_experience": "number (optional)",
    "cases_handled": "number (optional)",
    "clients_served": "number (optional)",
    "success_rate": "number (optional, 0-100)"
  }
}
```

**Example Usage:**
```
User: "我已经有15年执业经验了"
AI: [Extracts intent and calls update] → {"stats": {"years_experience": 15}}
```

## Implementation Details

### Current Architecture

The system uses a conversational AI approach where:

1. **User sends natural language message** → "帮我更新电话号码为 138-xxxx-xxxx"
2. **AI analyzes intent** → Identifies this is a phone number update
3. **AI extracts data** → Extracts the phone number
4. **AI formats update** → Creates structured update: `{"phone": "138-xxxx-xxxx"}`
5. **System applies update** → Profile is updated in database
6. **AI confirms** → "好的，我已经帮你更新了电话号码！"

### Service Layer

The `DashboardAssistantService` handles:
- Parsing user messages
- Extracting update intentions
- Validating data
- Applying updates to the Profile model
- Generating confirmation messages

### Channel Layer

The `DashboardAssistantChannel` handles:
- WebSocket connection management
- Message routing
- Real-time updates to the UI
- Error handling

### Frontend Controller

The `DashboardAssistantController` (Stimulus) handles:
- UI state management
- Message display
- Real-time preview updates
- Notification system

## Future MCP Integration

To integrate with a full MCP system:

1. **Define formal tool schemas** in a JSON format
2. **Implement tool registry** to register available tools
3. **Add tool invocation system** that AI can call directly
4. **Implement tool result handling** to process tool outputs
5. **Add tool permission system** for security

### Example MCP Tool Schema

```json
{
  "name": "update_profile_phone",
  "description": "Updates the user's phone number on their professional profile",
  "parameters": {
    "type": "object",
    "properties": {
      "phone": {
        "type": "string",
        "description": "The new phone number",
        "pattern": "^[0-9\\-\\(\\)\\+\\s]+$"
      }
    },
    "required": ["phone"]
  }
}
```

## Security Considerations

- All updates are scoped to the current user's profile
- Input validation is performed before applying updates
- Changes are logged for audit purposes
- Sensitive operations (like email changes) could require additional verification

## Testing Tools

To test the AI assistant:

1. Open the dashboard
2. Click the floating AI assistant bubble (bottom right)
3. Try natural language commands:
   - "把我的电话改成 138-1234-5678"
   - "更新我的个人简介"
   - "添加专业领域：民商事诉讼"
   - "我有15年执业经验"

## API Integration

For programmatic access, profile updates can also be done via:

1. **DashboardAssistantChannel** - Real-time WebSocket
2. **Profile API endpoint** - REST API at `/api/v1/profile`
3. **Direct Profile model updates** - For system-level changes

## Monitoring and Analytics

Track AI assistant usage:
- Message volume per user
- Successful vs failed updates
- Common update patterns
- User satisfaction (implicit through continued usage)

## Extending Tools

To add new tools:

1. Update `DashboardAssistantService` with new field handlers
2. Add validation rules for new fields
3. Update AI system prompt with new capabilities
4. Test with various natural language inputs
5. Document in this file
