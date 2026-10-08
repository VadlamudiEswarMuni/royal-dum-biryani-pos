# Royal Dum Biryani POS v7 — Backend + PostgreSQL + H80i

This version keeps the existing H80i direct ESC/POS bridge and adds a real Node/Express + PostgreSQL + Prisma backend.

## Features
- PostgreSQL persistent storage for bills and menu items
- Every saved bill is synced to the backend
- Daily / weekly / monthly / custom-date reporting
- Payment-method totals and item-wise sales
- Bill search, print and delete
- CSV export and local JSON backup remain available
- H80i direct ESC/POS bridge retained
- Browser cache remains as an offline safety layer

## Requirements
- Node.js 22+ recommended
- Docker Desktop
- Windows H80i printer + existing bridge

## Start database
```powershell
docker compose up -d db
```

## Backend
```powershell
cd backend
copy .env.example .env
npm install
npx prisma generate
npx prisma migrate dev --name init
npm run dev
```
API: http://localhost:4000/api/health

## Frontend
Open `frontend/index.html` through a local web server (recommended VS Code Live Server) at http://localhost:5173.
The page uses http://localhost:4000 by default for the API.

## H80i
Run `start-bridge.bat` as before. The bridge is only for local printer access; PostgreSQL is the permanent business-data store.

## Production architecture
Frontend -> Node/Express API -> PostgreSQL
POS PC -> local print bridge -> H80i USB printer

Do not use GitHub Pages as the backend. GitHub Pages can host the static frontend only.
