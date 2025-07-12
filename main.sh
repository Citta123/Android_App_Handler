#!/system/bin/sh

clear

# Variabel
SCRIPT_DIR="/data/local/tmp/bashW" # Direktori tempat skrip berada
CLONE_SCRIPT="$SCRIPT_DIR/clone.sh"
EXTRACT_SCRIPT="$SCRIPT_DIR/extract.sh"
SETBACA_SCRIPT="$SCRIPT_DIR/setbaca.sh"
SETDATE_SCRIPT="$SCRIPT_DIR/setdate.sh"
BACKUP_SCRIPT="$SCRIPT_DIR/backup.sh"
UPLOAD_SCRIPT="$SCRIPT_DIR/upload.sh"
PACKAGE_NAME="co.id.iconpln.acmt" # Nama paket aplikasi

# Cek apakah script dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
  echo "Meminta akses root..."
  exec su -c "sh $0 $*"
fi

# Validasi ketersediaan skrip pendukung
validate_scripts() {
  REQUIRED_SCRIPTS=("$CLONE_SCRIPT" "$EXTRACT_SCRIPT" "$SETBACA_SCRIPT" "$SETDATE_SCRIPT" "$BACKUP_SCRIPT" "$UPLOAD_SCRIPT")
  for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ ! -f "$script" ]; then
      echo "Skrip $script tidak ditemukan. Pastikan semua skrip tersedia." >&2
      exit 1
    fi
  done
}

# Fungsi menampilkan menu utama
main_menu() {
  echo "Menu Utama:"
  echo "1. BACA METER"
  echo "2. BACKUP"
  echo "3. UPLOAD"
  echo "4. KELUAR"
  echo -n "Pilih opsi (1-4): "
  read CHOICE

  case $CHOICE in
    1) baca_meter ;;
    2) backup ;;
    3) upload ;;
    4) echo "Keluar..."; exit 0 ;;
    *) echo "Pilihan tidak valid!"; main_menu ;;
  esac
}

# Fungsi untuk opsi BACA METER
baca_meter() {
  echo "Menjalankan BACA METER..."
  
  su -c "am force-stop $PACKAGE_NAME" || { echo "Gagal menghentikan aplikasi."; exit 1; }
  su -c "sh $CLONE_SCRIPT" || { echo "Gagal menjalankan clone.sh"; exit 1; }
  su -c "sh $EXTRACT_SCRIPT" || { echo "Gagal menjalankan extract.sh"; exit 1; }
  su -c "sh $SETBACA_SCRIPT" || { echo "Gagal menjalankan setbaca.sh"; exit 1; }
  su -c "sh $SETDATE_SCRIPT" || { echo "Gagal menjalankan setdate.sh"; exit 1; }
  su -c "am start -n $PACKAGE_NAME/.MainActivity" || { echo "Gagal memulai aplikasi."; exit 1; }
  echo "BACA METER selesai!"
}

# Fungsi untuk opsi BACKUP
backup() {
  echo "Menjalankan BACKUP..."
  su -c "sh $BACKUP_SCRIPT" || { echo "Gagal menjalankan backup.sh"; exit 1; }
  echo "BACKUP selesai!"
}

# Fungsi untuk opsi UPLOAD
upload() {
  echo "Menjalankan UPLOAD..."
  su -c "sh $UPLOAD_SCRIPT" || { echo "Gagal menjalankan upload.sh"; exit 1; }
  echo "UPLOAD selesai!"
}

# Menjalankan validasi dan menu utama
validate_scripts
main_menu