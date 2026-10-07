Clokk — Staff Attendance App

Clock in. Clock out. Done.

Clokk is a mobile-first staff attendance management system built for Malaysian SMEs. It replaces paper sign-in sheets and WhatsApp check-in messages with a clean, reliable geolocation-based attendance system — deployable in under 5 minutes.

Features
Staff

Geolocation check-in — check in only when physically within 100m of the office
Live location map — real-time map showing distance from office using OpenStreetMap
Document upload — submit MC, emergency leave, and other documents (PDF/JPG/PNG)
Leave management — apply annual leave, emergency leave, and unpaid leave
Overtime requests — submit OT for approval
Claims submission — medical, transport, and other claims
Pay slip — download monthly payslip
Calendar — view leave status, company events, and public holidays
Announcements — birthday notifications, company events, HR announcements
Dark & light mode — full theme support with toggle

Admin / Owner

QR code generator — auto-refreshing QR (every 30s) for manual check-in fallback
Real-time dashboard — live staff attendance status (present, absent, late)
Push notifications — instant FCM alert when staff check in or out
Staff management — add and manage staff accounts
Report export — export attendance logs to Excel


Tech Stack
Mobile (Flutter)
Framework: Flutter 3.x
State management: GetX
HTTP client: Dio
Local storage: geolocator
Map: google_maps_flutter
File upload: file_picker
Push notifications: firebase_messaging
Font: Poppins (Google Fonts)

## Current Implementation

- Staff dashboard, attendance, requests, documents, notifications, profile
- Admin dashboard, approvals, team attendance, reports, employee management
- Attendance history, detail, correction request, shift schedule
- Leave balance detail, request status tracker, document expiry / renewal
- Department dashboard, payroll prep, holiday management, role access management
- Dark mode support
- App version display from `pubspec.yaml`

## Notes

- the current login and data layer still use mock responses in `lib/api/api_client.dart`
- emails containing `admin` will open the admin flow, other valid emails open the staff flow
- production auth and backend integration can be connected later

## Run Locally

```bash
flutter pub get
flutter run
```
