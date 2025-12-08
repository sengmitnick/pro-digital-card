# WeChat Share Integration Guide

## Overview

This document explains how to use WeChat JS-SDK share functionality for professional cards using an external signature API.

## Architecture

### External API

**Signature API Endpoint**: `https://www.qinglion.com/api/v1/wechat_signatures`

The signature generation is handled by an external service, so no backend implementation is required in this application.

### Frontend Component

**WechatShareController** (`app/javascript/controllers/wechat_share_controller.ts`)
- Stimulus controller that handles WeChat JS-SDK integration
- Automatically loads WeChat JS-SDK script (`//res2.wx.qq.com/open/js/jweixin-1.6.0.js`)
- Fetches signature from external API
- Configures share content for:
  - Share to Friends (onMenuShareAppMessage / updateAppMessageShareData)
  - Share to Timeline (onMenuShareTimeline / updateTimelineShareData)

## How It Works

### Flow Diagram

```
1. User opens card page in WeChat browser
   ↓
2. Stimulus controller loads on page
   ↓
3. Controller loads WeChat JS-SDK script
   ↓
4. Controller sends POST request to external API
   https://www.qinglion.com/api/v1/wechat_signatures
   with current URL (without fragment)
   ↓
5. External API:
   - Validates request
   - Generates signature using WeChat credentials
   - Returns: appId, timestamp, nonceStr, signature
   ↓
6. Controller calls wx.config() with signature data
   ↓
7. WeChat validates signature
   ↓
8. If valid, wx.ready() fires
   ↓
9. Controller configures share content
   ↓
10. User clicks WeChat share button
    ↓
11. Custom share content appears!
```

### API Request/Response

#### Request to External API

```javascript
POST https://www.qinglion.com/api/v1/wechat_signatures
Content-Type: application/json

{
  "url": "https://example.com/c/username"
}
```

#### Response from External API

```json
{
  "success": true,
  "data": {
    "appId": "wx1234567890abcdef",
    "timestamp": "1701234567",
    "nonceStr": "abc123def456",
    "signature": "a1b2c3d4e5f6...",
    "url": "https://example.com/c/username"
  }
}
```

## Integration in Views

The share functionality is integrated into `app/views/cards/show.html.erb`:

```erb
<div data-controller="wechat-share"
     data-wechat-share-title-value="<%= @profile.full_name %> - <%= @profile.title %>"
     data-wechat-share-desc-value="<%= @profile.bio&.truncate(100) || '专业名片分享' %>"
     data-wechat-share-link-value="<%= request.original_url %>"
     data-wechat-share-img-url-value="<%= @profile.avatar.attached? ? url_for(@profile.avatar) : '' %>">
  <!-- Your content -->
</div>
```

### Stimulus Controller Values

| Value | Type | Description | Example |
|-------|------|-------------|---------|
| `title` | String | Share title | "John Doe - Senior Lawyer" |
| `desc` | String | Share description | "Professional legal services..." |
| `link` | String | Share link URL | "https://example.com/c/johndoe" |
| `imgUrl` | String | Share thumbnail image | "https://example.com/avatar.jpg" |

## Testing

### Prerequisites

1. Access to WeChat mobile app
2. Valid URL that can be accessed from WeChat browser
3. External API must be operational

### Local Testing

Since WeChat JS-SDK only works with valid URLs accessible from the internet:

**Option: Use ngrok or similar tunnel**
```bash
ngrok http 3000
# Open the ngrok URL in WeChat browser
```

### Testing Steps

1. **Start Server**
   ```bash
   bin/dev
   ```

2. **Create Public URL** (if testing locally)
   ```bash
   ngrok http 3000
   # Copy the https URL
   ```

3. **Open in WeChat**
   - Send card URL to any WeChat chat
   - Open link in WeChat browser
   - Open browser console (for debugging)

4. **Verify JS-SDK Loading**
   ```
   Check console for:
   ✓ "WechatShare controller connected"
   ✓ "WeChat JS-SDK ready"
   ✓ "Share to chat configured"
   ✓ "Share to timeline configured"
   ```

5. **Test Share**
   - Click WeChat share button (top-right menu)
   - Verify custom title, description, and image appear
   - Share to friend or timeline
   - Check if shared message displays correctly

### Debug Mode

Enable debug mode to see detailed WeChat JS-SDK messages:

```typescript
// In app/javascript/controllers/wechat_share_controller.ts
// Line 71
wx.config({
  debug: true, // Change to true
  // ...
})
```

This will show alert popups with API call results.

### Common Issues

#### Issue: "config:invalid signature"

**Cause**: Signature verification failed

**Solutions**:
- Ensure URL doesn't include `#` fragment (controller automatically removes it)
- Check that external API is accessible
- Verify the URL sent to API matches exactly what WeChat expects
- Clear WeChat cache: Me > Settings > General > Storage > Clear Cache

#### Issue: "config:permission denied"

**Cause**: Domain not whitelisted in WeChat Official Account

**Solutions**:
- Contact the external API administrator
- Ensure your domain is added to their WeChat Official Account's JS-SDK security domains
- Wait 5 minutes after domain is added for changes to take effect

#### Issue: Share content not updating

**Cause**: WeChat cache

**Solutions**:
- Clear WeChat cache on mobile device
- Restart WeChat app
- Try with different URL parameters

#### Issue: Network error when fetching signature

**Cause**: Cannot reach external API

**Solutions**:
- Check network connectivity
- Verify API endpoint: `https://www.qinglion.com/api/v1/wechat_signatures`
- Check browser console for CORS errors
- Ensure external API allows requests from your domain

## Implementation Details

### Stimulus Controller Code

The controller automatically handles:

1. **Script Loading**: Dynamically loads WeChat JS-SDK script
2. **URL Preparation**: Removes fragment (#) from current URL
3. **Signature Fetching**: Calls external API with prepared URL
4. **SDK Initialization**: Configures wx.config() with received signature
5. **Share Configuration**: Sets up both new and old API methods for compatibility

### WeChat JS-SDK APIs Used

- `wx.config()` - Initialize JS-SDK with signature
- `wx.ready()` - Callback when SDK is ready
- `wx.error()` - Error handler
- `wx.updateAppMessageShareData()` - Share to friend (new API, 1.4.0+)
- `wx.updateTimelineShareData()` - Share to timeline (new API, 1.4.0+)
- `wx.onMenuShareAppMessage()` - Share to friend (old API, for compatibility)
- `wx.onMenuShareTimeline()` - Share to timeline (old API, for compatibility)

### Browser Compatibility

Works in:
- WeChat Built-in Browser (iOS)
- WeChat Built-in Browser (Android)

Does NOT work in:
- Safari
- Chrome
- Firefox
- Other mobile browsers

The controller will load the script but WeChat APIs will not function outside of WeChat's browser.

## Security Considerations

1. **External API Dependency**
   - Your application relies on external API availability
   - API downtime will prevent WeChat share functionality
   - Consider implementing graceful degradation

2. **CORS Configuration**
   - External API must allow requests from your domain
   - If CORS errors occur, contact API administrator

3. **URL Validation**
   - Controller sends current page URL to external API
   - Ensure sensitive query parameters are not included

## Production Deployment

### 1. Verify External API Access

```bash
# Test API accessibility
curl -X POST https://www.qinglion.com/api/v1/wechat_signatures \
  -H "Content-Type: application/json" \
  -d '{"url": "https://your-domain.com"}'
```

### 2. Domain Whitelisting

Contact the external API administrator to ensure your production domain is whitelisted in their WeChat Official Account's JS-SDK security domains.

### 3. Build and Deploy

```bash
# Build frontend assets
npm run build

# Deploy to production
git push production main
```

### 4. Verify in Production

1. Open your card page in WeChat browser
2. Check browser console for errors
3. Test share functionality
4. Monitor for any signature validation errors

## Troubleshooting Checklist

- [ ] External API is accessible from your server
- [ ] Current URL is sent correctly (without fragment)
- [ ] WeChat JS-SDK script loads successfully
- [ ] Signature API returns success response
- [ ] wx.config() is called with correct parameters
- [ ] wx.ready() callback fires
- [ ] Share methods are configured
- [ ] Domain is whitelisted in WeChat Official Account

## References

- [WeChat JS-SDK Official Documentation](https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/JS-SDK.html)
- [WeChat Official Account Platform](https://mp.weixin.qq.com/)
- [JS-SDK Demo](https://www.weixinsxy.com/jssdk/)

## Support

For issues related to:

**External API**:
- Contact: External API administrator
- API URL: https://www.qinglion.com/api/v1/wechat_signatures

**Frontend Implementation**:
- Check browser console for errors
- Review Stimulus controller logs
- Verify data-* attributes in HTML

**WeChat SDK**:
- Enable debug mode in controller
- Check WeChat official documentation
- Clear WeChat cache and retry
