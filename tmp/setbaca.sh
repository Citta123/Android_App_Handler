#!/system/bin/sh

clear

# Variabel
EXTRACT_DIR="/data/local/tmp/acmt_ext" # Lokasi hasil ekstraksi
APP_DB_DIR="/data/data/co.id.iconpln.acmt/databases" # Direktori database aplikasi
APP_PREFS_DIR="/data/data/co.id.iconpln.acmt/shared_prefs" # Direktori shared_prefs aplikasi
STAT_FILE="/data/local/tmp/tmp_stat" # File sementara untuk menyimpan UID dan GID
DB_FILE="icmo_api" # Nama file database
XML_FILE="iCMOLogin.xml" # Nama file XML
PACKAGE_NAME="co.id.iconpln.acmt" # Nama paket aplikasi

# Warna teks
GREEN="\033[1;32m" # Hijau untuk pesan berhasil
RED="\033[1;31m"   # Merah untuk pesan gagal
RESET="\033[0m"    # Reset warna

# Memeriksa apakah skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Meminta akses root...${RESET}"
  exec su -c "sh $0 $*"
fi

# Fungsi menyimpan UID dan GID file asli
save_stat() {
  if su -c "stat -c '%u %g' $APP_DB_DIR/$DB_FILE > $STAT_FILE"; then
    echo -e "${GREEN}UID dan GID berhasil disimpan.${RESET}"
  else
    echo -e "${RED}Gagal menyimpan UID dan GID.${RESET}"
    exit 1
  fi
}

# Fungsi menampilkan pilihan jalur A-G
select_folder() {
  FOLDERS=$(su -c "ls -1 $EXTRACT_DIR | grep -E '^.{1,2}$'")
  if [ -z "$FOLDERS" ]; then
    echo -e "${RED}Tidak ada folder target ditemukan!${RESET}"
    exit 1
  fi

  echo "$FOLDERS" | nl
  echo -n "PILIH HARI BACA: "
  read CHOICE

  TARGET_FOLDER=$(echo "$FOLDERS" | sed -n "${CHOICE}p")
  if [ -z "$TARGET_FOLDER" ]; then
    echo -e "${RED}Pilihan tidak valid!${RESET}"
    exit 1
  fi

  TARGET_DB="$EXTRACT_DIR/$TARGET_FOLDER/databases/$DB_FILE"
  TARGET_XML="$EXTRACT_DIR/$TARGET_FOLDER/shared_prefs/$XML_FILE"

  if [ ! -f "$TARGET_DB" ] || [ ! -f "$TARGET_XML" ]; then
    echo -e "${RED}File database atau XML tidak ditemukan!${RESET}"
    exit 1
  fi
}

# Fungsi menyalin file ke direktori aplikasi
copy_files() {
  if su -c "cp $TARGET_DB $APP_DB_DIR/$DB_FILE" && su -c "cp $TARGET_XML $APP_PREFS_DIR/$XML_FILE"; then
    echo -e "${GREEN}File berhasil disalin.${RESET}"
  else
    echo -e "${RED}Gagal menyalin file.${RESET}"
    exit 1
  fi
}

# Fungsi mengatur UID dan GID berdasarkan stat asli
restore_permissions() {
  if [ -f "$STAT_FILE" ]; then
    UID=$(awk '{print $1}' $STAT_FILE)
    GID=$(awk '{print $2}' $STAT_FILE)

    if su -c "chown $UID:$GID $APP_DB_DIR/$DB_FILE" && su -c "chown $UID:$GID $APP_PREFS_DIR/$XML_FILE"; then
      echo -e "${GREEN}UID dan GID berhasil dipulihkan.${RESET}"
    else
      echo -e "${RED}Gagal memulihkan UID dan GID.${RESET}"
      exit 1
    fi
  else
    echo -e "${RED}File stat tidak ditemukan.${RESET}"
    exit 1
  fi
}

# Fungsi menghapus folder hasil ekstraksi
cleanup_extracted_folder() {
  if su -c "rm -rf $EXTRACT_DIR"; then
    echo -e "${GREEN}Folder hasil ekstraksi berhasil dihapus.${RESET}"
  else
    echo -e "${RED}Gagal menghapus folder hasil ekstraksi.${RESET}"
  fi
}

# Fungsi menonaktifkan internet pada aplikasi
disable_internet_for_app() {
  APP_UID=$(su -c "dumpsys package $PACKAGE_NAME | grep userId= | awk -F'=' '{print \$2}'")
  if [ -z "$APP_UID" ]; then
    echo -e "${RED}Gagal mendapatkan UID aplikasi.${RESET}"
    exit 1
  fi

  if su -c "iptables -A OUTPUT -m owner --uid-owner $APP_UID -j DROP"; then
    echo -e "${GREEN}Internet berhasil dinonaktifkan untuk aplikasi.${RESET}"
  else
    echo -e "${RED}Gagal menonaktifkan internet.${RESET}"
    exit 1
  fi
}

# Menjalankan proses
save_stat
select_folder
copy_files
restore_permissions
cleanup_extracted_folder
disable_internet_for_app
echo -e "${GREEN}Proses selesai.${RESET}"
