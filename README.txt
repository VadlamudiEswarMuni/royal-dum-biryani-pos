ROYAL DUM BIRYANI - H80i DIRECT PRINT v6

Features:
- H80i 80mm direct ESC/POS printing through local start-bridge.bat
- Sequential bill numbers RDB-0001, RDB-0002...
- Bills, menu and printer settings stored in IndexedDB with localStorage fallback
- Automatic ISO timestamp on every bill
- Daily, weekly (Mon-Sun), monthly and custom date sales reports
- Filtered bill list and CSV export
- Full data backup/restore JSON
- Existing v5 localStorage data is migrated into v6 on first run

Important:
This standalone version stores data on the current browser/device. It is not a cloud database and data is not automatically shared between computers. For the multi-vendor SaaS version, use the PostgreSQL backend.

Start the print bridge before using Direct ESC/POS:
1. Right-click start-bridge.bat -> Run as administrator (if Windows requires it).
2. Open index.html or serve the folder from a local web server.
