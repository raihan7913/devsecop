#!/bin/bash
# Script untuk reset database di Railway

echo "🗑️  Menghapus database lama..."
rm -f academic_dashboard.db

echo "🔧 Inisialisasi database baru..."
node src/init_db.js

echo "✅ Database berhasil di-reset!"
echo "📊 Default users:"
echo "   Admin: admin / admin123"
echo "   Guru: guru1 / guru123"
echo "   Siswa: siswa1 / siswa123"
