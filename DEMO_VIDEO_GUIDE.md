# Demo Video Recording & Integration Guide

## Step 1: Record Your Demo Video

### Using macOS Screen Recording (Recommended)

1. **Open the emulator** - Make sure your Flutter app is running
2. **Press `Cmd + Shift + 5`** - Opens macOS screenshot toolbar
3. **Select "Record Selected Portion"** (4th icon from left)
4. **Drag to select just the emulator window**
5. **Click "Record"** button (or press Enter)
6. **Wait 3 seconds** countdown
7. **Demonstrate the app features:**

#### Demo Script (60-90 seconds):

**Scene 1: Landing Page (10 sec)**
- Show "List Vault" landing page with three cards
- Hover over each section briefly

**Scene 2: Weekly Shopping List (30 sec)**
- Click on "Weekly Shopping List"
- Enter family name (e.g., "Smith Family")
- Click "+ Add Item" button
- Add first item: "Milk" - Quantity: 2 - Category: Dairy
- Add second item: "Apples" - Quantity: 5 - Category: Fruits
- Add third item: "Bread" - Quantity: 1 - Category: Bakery
- Check one item as done (checkbox animation)

**Scene 3: Features Showcase (20 sec)**
- Toggle dark mode button (show dark theme)
- Toggle back to light mode
- Show quick-add chips at the top
- Click one quick-add chip to demonstrate

**Scene 4: Event List (15 sec)**
- Go back to home
- Click "Event List"
- Show creating an event list (e.g., "Birthday Party")

**Scene 5: Custom List (10 sec)**
- Go back to home
- Click "Custom List"
- Show custom lists screen

**End (5 sec)**
- Return to landing page
- Show full app overview

8. **Press `Cmd + Ctrl + Esc`** to stop recording
9. **Video saved to Desktop** as "Screen Recording [date].mov"

---

## Step 2: Convert & Optimize Video

### Option A: Use Online Converter
1. Go to https://www.freeconvert.com/video-compressor
2. Upload your .mov file
3. Set target size to ~5MB (good for web)
4. Choose MP4 format
5. Download optimized video

### Option B: Use FFmpeg (if installed)
```bash
# Convert and compress
ffmpeg -i "Screen Recording.mov" -vcodec h264 -acodec aac -b:v 1000k -vf "scale=720:-2" demo.mp4

# Create WebM version (better for web)
ffmpeg -i "Screen Recording.mov" -c:v libvpx-vp9 -crf 30 -b:v 0 -vf "scale=720:-2" demo.webm
```

---

## Step 3: Move Video to Project

```bash
mv ~/Desktop/"Screen Recording"*.mov /Users/maduodiraaperpetua/Documents/LIST_APP/family_list_app/demo_videos/list_vault_demo.mov

# Or if you converted it:
mv ~/Downloads/demo.mp4 /Users/maduodiraaperpetua/Documents/LIST_APP/family_list_app/build/web/assets/demo.mp4
```

---

## Step 4: Option A - Host on YouTube (Recommended)

### Benefits:
- Free hosting
- No bandwidth costs
- Better SEO
- Easy embedding

### Steps:
1. Go to https://youtube.com/upload
2. Upload your video
3. Title: "List Vault - Family Shopping List App Demo"
4. Description:
   ```
   List Vault is a collaborative shopping list app built with Flutter and Supabase.

   Features:
   - Real-time synchronization across devices
   - Family group collaboration
   - Voice input for hands-free adding
   - Dark mode support
   - Weekly list management
   - Event and custom lists

   Try it live: [Your Netlify URL]
   GitHub: [Your GitHub repo]
   ```
5. Set as "Unlisted" or "Public"
6. Copy the video URL (e.g., https://www.youtube.com/watch?v=ABC123)

---

## Step 5: Option B - Host Video in Web Build

If you want to self-host:

1. **Copy video to web assets:**
```bash
cp demo_videos/demo.mp4 build/web/assets/demo.mp4
```

2. **Update web build:**
```bash
flutter build web --release
```

---

## Step 6: Embed in Your Web App

I've created `video_landing_page.html` with the video player ready.

### For YouTube:
Replace the iframe src with your YouTube URL:
```html
<iframe
  width="100%"
  height="600"
  src="https://www.youtube.com/embed/YOUR_VIDEO_ID"
  frameborder="0"
  allowfullscreen>
</iframe>
```

### For Self-Hosted:
```html
<video controls width="100%" style="max-width: 800px; border-radius: 15px;">
  <source src="assets/demo.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>
```

---

## Tips for a Great Demo Video

### DO:
✅ Keep it under 2 minutes
✅ Show actual functionality (not just UI)
✅ Demonstrate key features
✅ Use smooth, deliberate movements
✅ Show both light and dark modes
✅ Add items with realistic names
✅ Show real-time sync if possible (multiple devices)

### DON'T:
❌ Rush through features
❌ Show errors or crashes
❌ Include personal information
❌ Make the video too long
❌ Forget to show the app name
❌ Use Lorem Ipsum text

---

## Next Steps

1. Record your demo video following the script
2. Optimize the video (compress if needed)
3. Upload to YouTube OR copy to web build
4. Update `video_landing_page.html` with video URL
5. Rebuild web: `flutter build web --release`
6. Deploy to Netlify

Your deployed web app will now have a professional video demo!
