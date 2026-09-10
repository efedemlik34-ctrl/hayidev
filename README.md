# HayiDev

Sesli sohbet + oyun platformu. 51 sistem.

## Kurulum

### Backend
```
cd backend
npm install
npm start
```

### Admin Panel
```
cd admin
npm install
npm run dev
```

### Mobil
```
cd mobile
flutter pub get
flutter run
```

## Admin Girisi
- E-posta: admin@hayidev.app
- Sifre: HayiDev@2026!Admin

## Sistemler (51)

### Temel (25)
Auth, User, TX, Daily, VIP, Rooms, Chat, 12 Hediye, 8 Gorev,
Davet, Liderlik, XP, 8 Cerceve, 7 Rozet, Klanlar, Kuponlar,
Raporlar, Carkifelek, 6 Oyun, Admin Panel

### Sosyal + Medya (18)
Follow, Block, Friends, Notifications, Posts, Comments, Likes,
Seats, Themes, Voice Messages, Party, Music, Mods, Kick/Mute,
Season, Tournament, Clan Wars, Live Stream

### AI + Ileri (8)
AI Chat Bot, AI Gift Suggest, Behavior Analytics,
Push Notifications, OAuth (Google + Apple), Voice Changer,
Analytics Dashboard, Weekly/Monthly Leaderboard

## APK Derleme
GitHub Actions otomatik derler:
1. Actions sekmesi
2. Son workflow
3. Artifacts -> hayidev-apk indir

Manuel:
```
cd mobile
flutter build apk --release
```

## Teknolojiler
- Backend: Node.js, Express, Socket.io, SQLite
- Mobil: Flutter
- Admin: React, Vite
- Realtime: Socket.io, Agora RTC
- Push: Firebase FCM

## Lisans
MIT
