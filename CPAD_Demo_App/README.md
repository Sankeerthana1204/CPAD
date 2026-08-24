# CPAD Demo Application

Demoable scoped e-commerce system for CPAD assignment.

## Implemented Scope

- Login Screen (email + password)
- Dashboard (product list with search)
- Product Detail page

## Architecture

- Flutter app for web + mobile client UI
- Node.js + Express REST backend
- SQLite database

## Project Structure

- `backend/` - REST API and SQL persistence
- `flutter_app/` - Flutter client app (web/mobile)

## Demo Credentials

- Email: `customer@demo.com`
- Password: `demo123`

## 1) Run Backend

```bash
cd backend
cp .env.example .env
npm install
npm start
```

Backend URL:
- `http://localhost:4000`

Key APIs:
- `POST /api/auth/login`
- `GET /api/products?search=...` (Bearer token)
- `GET /api/products/:id` (Bearer token)

## 2) Run Flutter App

Prerequisite: Flutter SDK must be installed and available in `PATH`.

```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

For Android emulator:
- API base URL already points to `http://10.0.2.2:4000/api` for non-web builds.

For iOS simulator / real mobile device:
- Replace the base URL in `flutter_app/lib/services/api_client.dart` with your machine IP, for example:
  - `http://192.168.1.5:4000/api`

## 3) Suggested Demo Flow

1. Open login screen and sign in using demo credentials
2. Show dashboard product list
3. Search for a product (for example `shoe`)
4. Open an item to display product detail page

## Notes

- Scope intentionally excludes cart, checkout, payment, shipping, and returns.
- Database is seeded automatically on first backend startup.
