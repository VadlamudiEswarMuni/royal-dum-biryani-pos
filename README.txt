ROYAL DUM BIRYANI - H80i DIRECT PRINT v4

This version keeps the working local ESC/POS bridge and improves the receipt layout for the H80i 80mm printer.

Changes in v4:
- Approximately 3mm left margin using ESC/POS GS L.
- Controlled print area width using GS W.
- Receipt header remains centered; bill details remain left aligned.
- Feeds a small amount before cutting.
- Uses GS V 65 0 (feed to cutting position + full cut) instead of the previous partial-cut command.

Setup:
1. Keep the H80i installed in Windows and confirm its Windows test page works.
2. If Windows Smart App Control blocks start-bridge.bat, use the file Properties > Unblock option if available.
3. Run start-bridge.bat as Administrator and keep the black window open.
4. Open index.html.
5. Printer Settings > Refresh Printers.
6. Select POS-80(copy of 1) (or the actual H80i Windows queue shown).
7. Click Direct Test Print.

The bridge uses Windows RAW printing and does not open browser print preview.
