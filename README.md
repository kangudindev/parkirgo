# ParkirGo

Aplikasi manajemen parkir tepi jalan (on-street parking) digital.

| Platform | Teknologi |
|---|---|
| Mobile App | Flutter (Android) |
| Backend API | Laravel 12 |
| Database | MySQL |
| Dashboard Admin | Inertia + Vue 3 (Velzon Theme) |

## Setup Backend

```bash
cd backend
docker compose up -d
docker exec parkirgo-backend php artisan migrate --force
docker exec parkirgo-backend php artisan db:seed --force
```

## Build APK

```bash
cd flutter_parkirgo
flutter build apk --release --dart-define=BASE_URL=https://parkirgo.eu.cc/api
```

## Login Test

| User | Login Method |
|---|---|
| Admin | `admin@parkirgo.test` via Web Dashboard |
| Jukir | Scan QR ID Card via mobile app |
