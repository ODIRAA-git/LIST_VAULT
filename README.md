# 🛒 List Vault

A real-time shared shopping list for families, built with **Flutter** and **Supabase**.
Family members create or join a shared group with a short code, and every change
appears instantly on everyone's device. One codebase runs on **Android** and the
**web** (desktop and mobile browsers).

<p>
  <a href="https://listvault.netlify.app"><b>▶ Try the live demo</b></a> &nbsp;·&nbsp;
  <a href="https://github.com/ODIRAA-git/LIST_VAULT/releases/latest/download/list-vault.apk"><b>📱 Download for Android (APK)</b></a> &nbsp;·&nbsp;
  <a href="demo_videos/list_vault_demo.mp4"><b>🎬 Watch the demo video</b></a>
</p>

## 👋 Recruiter or reviewer? Try it in under a minute

No sign-up needed.

1. Open **[listvault.netlify.app](https://listvault.netlify.app)** and tap **Try the demo**
   (or create a family named `demo@listvault.com`).
2. You get a family list pre-filled with sample items, plus a **6-character family code**.
3. On your phone, open the same link (scan the QR code below) → **Weekly Shopping List** →
   **Join Family** → enter the code with any name.
4. Add or tick off an item on one device and watch it update on the other in real time.

<img src="https://api.qrserver.com/v1/create-qr-code/?size=160x160&data=https://listvault.netlify.app" width="140" alt="QR code that opens the live demo on your phone">

<!--
## 📸 Screenshots
Add screenshots to a screenshots/ folder and uncomment this section.

| Phone | Desktop |
|---|---|
| <img src="screenshots/phone.png" width="250"> | <img src="screenshots/desktop.png" width="500"> |
-->

## ✨ Features

- **Family groups:** create a family, share a short join code, and join from any device
- **Real-time sync:** items added, ticked or deleted appear instantly for every member
- **Pick up where you left off:** each device remembers the families it has joined
- **Weekly lists:** finish a week with one tap; unchecked items can be carried over to the next week
- **Quick add:** tap a recent item to add it again
- **Categories:** Fruits, Vegetables, Dairy, Bakery and more
- **Voice input:** add items by speaking (Android)
- **Event and custom lists:** separate lists for parties, holidays or anything else
- **Dark mode**
- **Responsive layout:** designed for phones, and centered for comfortable use on desktop

## 🧱 Tech stack

| Layer | Technology |
|---|---|
| App | Flutter, Dart, Material Design |
| Backend | Supabase (PostgreSQL, Realtime) |
| Local storage | Hive |
| State management | Provider |
| Device features | speech_to_text, flutter_local_notifications |
| Hosting | Netlify (web), GitHub Releases (Android APK) |

## 🏗️ How it works

```
 Phone (Android)             Supabase                Browser (web)
┌─────────────┐     ┌──────────────────────┐     ┌─────────────┐
│ Flutter app │◄───►│ family_groups        │◄───►│ Flutter app │
│ Hive cache  │     │ family_members       │     │ Hive cache  │
└─────────────┘     │ items (Realtime)     │     └─────────────┘
                    │ weekly_lists         │
                    └──────────────────────┘
```

- **Families** are stored in Supabase (`family_groups`, `family_members`) and found by a
  unique 6-character join code, so any device can join.
- **Items** belong to a family through `family_group_id`. Each client subscribes to
  Supabase Realtime changes filtered to its own family, so updates arrive without refreshing.
- **Joining with an existing member's name** brings you back in as that member, so moving
  between devices doesn't create duplicate members.
- **Each device caches** the families it has joined in Hive, for one-tap return.
- **The demo:** creating a family named `demo@listvault.com` seeds a fresh group with sample
  items, so each reviewer gets their own sandbox.

## 🚀 Run it locally

Requirements: [Flutter](https://docs.flutter.dev/get-started/install) 3.38+ and a Supabase project.

```bash
git clone https://github.com/ODIRAA-git/LIST_VAULT.git
cd LIST_VAULT
flutter pub get

flutter run -d chrome     # web
flutter run               # Android emulator or device
```

**Database setup:** in the Supabase dashboard, open the SQL Editor and run
[`supabase_setup.sql`](supabase_setup.sql), then
[`supabase_family_groups.sql`](supabase_family_groups.sql).
Then set your project URL and anon key in [`lib/main.dart`](lib/main.dart).

**Build for release:**

```bash
flutter build web --release   # output in build/web (deployed to Netlify)
flutter build apk --release   # output in build/app/outputs/flutter-apk/
```

## 🗺️ Roadmap

- Real user accounts (Supabase Auth) with database access rules scoped to each family
- Wire up the existing barcode scanning, shopping mode and week history screens
- iOS release through TestFlight

## 👤 Author

Built by **[ODIRAA-git](https://github.com/ODIRAA-git)**.
