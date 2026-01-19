# Testing Live Events Video Feature

## How to Test the Video Link Feature

### 1. **Adding Video Links to Live Events**

1. **Navigate to Live Events Management:**
   - Go to `/admin/live_events` (Admin section)
   - Click "New Live event" or edit an existing event

2. **Fill in the Form:**
   - **Title**: e.g., "Weekly Training Session"
   - **Presenter**: e.g., "John Doe"
   - **Live**: Check if currently live
   - **Platform**: Select from dropdown (Facebook, YouTube, TikTok, Instagram)
   - **Video URL**: Paste a valid URL

### 2. **Sample URLs for Testing**

#### ✅ **Facebook (Embeddable)**
```
https://www.facebook.com/facebook/videos/10155278547321729/
https://www.facebook.com/watch/?v=123456789
```

#### ✅ **YouTube (Embeddable)**  
```
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://youtu.be/dQw4w9WgXcQ
https://www.youtube.com/watch?v=jNQXAC9IVRw
```

#### ⚠️ **TikTok (Redirect Only)**
```
https://www.tiktok.com/@username/video/123456789
https://vm.tiktok.com/ZMeAbCdEf/
```

#### ⚠️ **Instagram (Redirect Only)**
```
https://www.instagram.com/p/ABC123DEF/
https://www.instagram.com/reel/XYZ789GHI/
```

### 3. **Testing the Dashboard View**

1. **Go to Admin Dashboard:** `/admin/dashboard_admin`

2. **Find Live Events Section:** Look for the "📺 LIVE EVENTS" section on the right side

3. **Test Video Links:**
   - **With Video**: Events with video URLs will show platform-specific buttons
   - **Without Video**: Events without URLs show "No video link available"

### 4. **Testing the Modal**

1. **Click a "Watch" Button:** 
   - 📘 "Watch on Facebook"
   - 📺 "Watch on YouTube" 
   - 🎵 "Watch on TikTok"
   - 📷 "Watch on Instagram"

2. **Expected Behavior:**
   - **Facebook/YouTube**: Video plays in modal
   - **TikTok/Instagram**: Shows redirect button
   - **Modal closes**: Click outside or X button

### 5. **Form Validation Testing**

#### ✅ **Valid URLs**
- Must start with `http://` or `https://`
- Any valid web URL format

#### ❌ **Invalid URLs**
- `facebook.com/video` (missing protocol)
- `not-a-url` (invalid format)
- Empty string (should be allowed - optional field)

#### ✅ **Platform Options**
- facebook, youtube, tiktok, instagram
- Default: facebook

### 6. **Database Verification**

Check that data is saved correctly:
```sql
SELECT id, title, presenter, video_url, platform FROM live_events;
```

### 7. **Real Testing URLs**

#### **Safe YouTube URLs for Testing:**
- Rick Roll: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
- Sample Video: `https://www.youtube.com/watch?v=jNQXAC9IVRw`

#### **Facebook Public Videos:**
- Facebook's own page videos (usually public)
- Any public Facebook video URL

### 8. **Expected User Journey**

1. **Admin creates live event** with video URL
2. **Users visit dashboard** and see live events
3. **Users click "Watch" button** 
4. **Modal opens** with appropriate content:
   - Embedded video (Facebook/YouTube)
   - Redirect button (TikTok/Instagram)
5. **Users can close modal** or open in new tab

### 9. **Troubleshooting**

#### **Video Not Loading in Modal:**
- Check if URL is valid and public
- Facebook videos must be public
- YouTube videos must allow embedding

#### **Form Not Saving:**
- Check URL format validation
- Ensure platform is selected
- Check browser console for errors

#### **Modal Not Opening:**
- Check browser console for JavaScript errors
- Ensure video_url is not empty
- Verify event handlers are working

### 10. **Feature Limitations**

- **TikTok**: Cannot embed, redirects to platform
- **Instagram**: Cannot embed, redirects to platform  
- **Facebook**: Some videos may not be embeddable
- **YouTube**: Some videos disable embedding

This testing guide ensures the video link feature works correctly across all platforms and scenarios!
