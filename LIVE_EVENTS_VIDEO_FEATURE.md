# Live Events Video Integration Feature

## Overview
This feature adds video link functionality to live events, allowing admins to add social media video links (Facebook, TikTok, YouTube, Instagram) and view them directly in a modal popup from the admin dashboard.

## Features Implemented

### 🗄️ **Database Changes**
- Added `video_url` field to store the social media video link
- Added `platform` field to specify the video platform (facebook, tiktok, youtube, instagram)
- Migration file: `20250922023440_add_video_fields_to_live_events.exs`

### 🎯 **Schema Updates**
- Updated `ECMS.Training.LiveEvent` schema with new fields
- Added validation for video URL format (must be valid HTTP/HTTPS URL)
- Added platform validation (facebook, tiktok, youtube, instagram)

### 📺 **Dashboard Integration**
- **Live Events Section**: Enhanced to show video links with platform-specific icons
- **Click to Watch**: Platform-specific buttons (📘 Facebook, 🎵 TikTok, 📺 YouTube, 📷 Instagram)
- **Alternative Access**: "Open in new tab" link for direct access
- **Fallback**: Shows "No video link available" when no URL is provided

### 🎬 **Video Modal Popup**
- **Full-screen Modal**: Professional modal overlay with video player
- **Platform Support**:
  - **Facebook**: Embedded iframe player
  - **YouTube**: Embedded iframe with automatic URL conversion
  - **TikTok**: Platform redirect (TikTok doesn't allow embedding)
  - **Instagram**: Platform redirect (Instagram doesn't allow embedding)
- **Modal Features**:
  - Click outside to close
  - Close button (X)
  - Event title display
  - Platform indicator
  - "Open in new tab" option

### 🔧 **Technical Implementation**

#### **Event Handlers**:
```elixir
def handle_event("show_video", %{"video_url" => video_url, "platform" => platform, "title" => title}, socket)
def handle_event("close_video", _params, socket)
```

#### **Helper Functions**:
- `get_youtube_embed_url/1`: Converts YouTube watch URLs to embed format
- Supports both `youtube.com/watch?v=` and `youtu.be/` formats

#### **Modal State Management**:
- `show_video_modal`: Boolean to control modal visibility
- `selected_video`: Map containing video details (url, platform, title)

## Usage Instructions

### 📝 **For Admins (Adding Video Links)**:
1. Go to Live Events management
2. When creating/editing a live event, add:
   - **Video URL**: The full URL from Facebook, TikTok, YouTube, or Instagram
   - **Platform**: Select the appropriate platform
3. Save the event

### 👀 **For Viewing Videos**:
1. Visit the Admin Dashboard
2. In the "LIVE EVENTS" section, you'll see:
   - Events with video links show platform-specific "Watch" buttons
   - Click the button to open the video in a modal
   - Alternatively, click "Open in new tab" for direct access
3. In the modal:
   - Facebook/YouTube videos play directly in the modal
   - TikTok/Instagram show a button to open on their platforms
   - Click outside the modal or the X button to close

## Platform-Specific Behavior

### 📘 **Facebook**
- ✅ **Embedded playback** in modal
- Uses Facebook's video plugin iframe
- Supports Facebook video posts and live streams

### 📺 **YouTube** 
- ✅ **Embedded playback** in modal
- Automatically converts watch URLs to embed format
- Supports both youtube.com and youtu.be links

### 🎵 **TikTok**
- ❌ **No embedding** (TikTok policy)
- Shows "Open TikTok" button in modal
- Redirects to TikTok platform

### 📷 **Instagram**
- ❌ **No embedding** (Instagram policy)
- Shows "Open Instagram" button in modal
- Redirects to Instagram platform

## Example URLs

### ✅ **Supported Formats**:
- Facebook: `https://www.facebook.com/username/videos/123456789/`
- YouTube: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
- YouTube Short: `https://youtu.be/dQw4w9WgXcQ`
- TikTok: `https://www.tiktok.com/@username/video/123456789`
- Instagram: `https://www.instagram.com/p/ABC123DEF/`

## Security & Validation

- ✅ **URL Validation**: All video URLs must be valid HTTP/HTTPS URLs
- ✅ **Platform Validation**: Only supported platforms are allowed
- ✅ **XSS Protection**: URLs are properly encoded for iframe embedding
- ✅ **Content Security**: External content is loaded in sandboxed iframes

## Future Enhancements

### Potential Improvements:
- **Auto-platform Detection**: Automatically detect platform from URL
- **Video Thumbnails**: Show preview thumbnails for videos
- **Live Status Integration**: Show real-time live status from platforms
- **Multiple Videos**: Support multiple video links per event
- **Video Analytics**: Track video view counts and engagement

This feature provides a seamless way for users to access live event videos directly from the dashboard while maintaining security and providing fallbacks for platforms that don't support embedding.
