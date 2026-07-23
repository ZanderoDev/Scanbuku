# Scan Buku Sekolah

Aplikasi scan barcode buku cetak sekolah. Barcode dipetakan ke judul/keterangan buku (misal "Buku MTK") — pas scan, langsung muncul info bukunya, jadi gampang cek pas curiga ketuker.

## Cara setup (sekali saja)

Kamu **tidak perlu install Flutter SDK sama sekali** di HP/Termux. Folder `android/` yang biasanya digenerate oleh `flutter create` sekarang otomatis dibuat oleh GitHub Actions setiap kali build — cukup push repo ini apa adanya.

1. Push repo ini ke GitHub kamu:
   ```bash
   git init
   git remote add origin https://github.com/ZanderoDev/Scanbuku.git
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git push -u origin main
   ```
2. Buka repo di GitHub → tab **Actions** → workflow "Build APK" otomatis jalan.
3. Setelah selesai (centang hijau ✅), scroll ke bagian **Artifacts** → download `app-release-apk` → install ke HP.

## Cara pakai aplikasi

- Tab **Scan**: buka kamera, arahkan ke barcode buku.
  - Kalau cocok → muncul "Buku ketemu!" + judul buku + barcodenya.
  - Kalau belum ada di data → muncul "Buku tidak ditemukan" + kotak isian judul + tombol **Simpan**, langsung tersimpan dari situ.
- Tab **Data Buku**: lihat semua data, tambah manual lewat tombol +, atau hapus data.

## Package yang dipakai (sudah dicek versi stabilnya per Juli 2026)

| Package | Versi | Fungsi |
|---|---|---|
| mobile_scanner | ^7.2.0 | scan kamera |
| sqflite | ^2.4.3 | database lokal |
| path | ^1.9.0 | helper path database |

Semua data disimpan lokal di HP (SQLite), tidak ada sinkronisasi cloud. Sengaja tidak pakai `file_picker`/`csv` karena `file_picker` punya riwayat bug build Android yang berulang (`GeneratedPluginRegistrant` gagal resolve plugin) di beberapa versi terakhirnya.
