#!/system/bin/sh

clear

# Variabel
APP_DB_DIR="/data/data/co.id.iconpln.acmt/databases"
APP_PREFS_DIR="/data/data/co.id.iconpln.acmt/shared_prefs"
BASE_BACKUP_DIR="/data/local/tmp/acmt_backup"
DB_FILE="$APP_DB_DIR/icmo_api" # Path lengkap file database
XML_FILE="$APP_PREFS_DIR/iCMOLogin.xml" # Path lengkap file XML
ZIP_PASSWORD="Hard@0077"
PACKAGE_NAME="co.id.iconpln.acmt"

# Warna teks
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

# Cek apakah script dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Silakan jalankan skrip ini sebagai root.${RESET}"
  exec su -c "sh $0 $*"
fi

# Fungsi menghentikan aplikasi
stop_app() {
  su -c "am force-stop $PACKAGE_NAME" && \
  echo -e "${GREEN}Aplikasi berhasil dihentikan.${RESET}" || \
  echo -e "${RED}Gagal menghentikan aplikasi.${RESET}"
}

# Fungsi meminta input folder backup
get_backup_folder() {
  echo -n "Masukkan nama folder backup (A-G): "
  read BACKUP_FOLDER
  if ! echo "$BACKUP_FOLDER" | grep -Eq '^[A-Ga-g]$'; then
    echo -e "${RED}Nama folder tidak valid! Harap masukkan huruf A-G.${RESET}"
    exit 1
  fi
  BACKUP_DIR="$BASE_BACKUP_DIR/$BACKUP_FOLDER"
  ZIP_FILE="$BASE_BACKUP_DIR/$BACKUP_FOLDER.zip"
}

# Fungsi mempersiapkan direktori backup
prepare_backup_directory() {
  if su -c "[ -d $BACKUP_DIR ]"; then
    su -c "rm -rf $BACKUP_DIR/*" && \
    echo -e "${GREEN}Direktori backup berhasil dibersihkan.${RESET}" || \
    echo -e "${RED}Gagal membersihkan direktori backup.${RESET}"
  else
    su -c "mkdir -p $BACKUP_DIR" && \
    echo -e "${GREEN}Direktori backup berhasil dibuat.${RESET}" || \
    echo -e "${RED}Gagal membuat direktori backup.${RESET}"
  fi
}

# Fungsi mencadangkan file database dan XML
backup_files() {
  su -c "cp $DB_FILE $BACKUP_DIR/icmo_api" && \
  su -c "cp $XML_FILE $BACKUP_DIR/iCMOLogin.xml" && \
  echo -e "${GREEN}File berhasil dicadangkan.${RESET}" || \
  echo -e "${RED}Gagal mencadangkan file.${RESET}"
}

# Fungsi mencadangkan izin file
backup_permissions() {
  su -c "stat -c '%a %u %g' $DB_FILE > $BACKUP_DIR/icmo_api_stat" && \
  su -c "stat -c '%a %u %g' $XML_FILE > $BACKUP_DIR/iCMOLogin.xml_stat" && \
  echo -e "${GREEN}Izin file berhasil dicadangkan.${RESET}" || \
  echo -e "${RED}Gagal mencadangkan izin file.${RESET}"
}

# Fungsi membuat file ZIP dengan sandi
create_zip() {
  su -c "/data/data/com.termux/files/usr/bin/7z a -p$ZIP_PASSWORD -tzip $ZIP_FILE $BACKUP_DIR/*" > /dev/null 2>&1 && \
  su -c "rm -rf $BACKUP_DIR" && \
  echo -e "${GREEN}File ZIP berhasil dibuat.${RESET}" || \
  echo -e "${RED}Gagal membuat file ZIP.${RESET}"
}

# Fungsi mengaktifkan pengaturan tanggal dan waktu otomatis
enable_auto_datetime() {
  su -c "settings put global auto_time 1" && su -c "settings put global auto_time_zone 1" && \
  echo -e "${GREEN}Pengaturan tanggal dan waktu otomatis berhasil diaktifkan.${RESET}" || \
  echo -e "${RED}Gagal mengaktifkan pengaturan tanggal dan waktu otomatis.${RESET}"
}

# Fungsi menghapus file di folder aplikasi
delete_files_in_app_folder() {
  su -c "rm -f $DB_FILE" && su -c "rm -f $XML_FILE" && \
  echo -e "${GREEN}File berhasil dihapus dari folder aplikasi.${RESET}" || \
  echo -e "${RED}Gagal menghapus file dari folder aplikasi.${RESET}"
}

# Fungsi mengaktifkan kembali internet untuk aplikasi
enable_internet_for_app() {
  APP_UID=$(su -c "dumpsys package $PACKAGE_NAME | grep userId= | awk -F'=' '{print \$2}'")
  if [ -z "$APP_UID" ]; then
    echo -e "${RED}Gagal mendapatkan UID aplikasi.${RESET}"
    exit 1
  fi

  su -c "iptables -D OUTPUT -m owner --uid-owner $APP_UID -j DROP" && \
  echo -e "${GREEN}Internet berhasil diaktifkan kembali untuk aplikasi.${RESET}" || \
  echo -e "${RED}Gagal mengaktifkan kembali internet untuk aplikasi.${RESET}"
}

# Menjalankan proses backup
stop_app
get_backup_folder
prepare_backup_directory
backup_files
backup_permissions
create_zip
enable_auto_datetime
delete_files_in_app_folder
enable_internet_for_app
echo -e "${GREEN}Proses backup selesai.${RESET}"