#!/system/bin/sh

clear

# Variabel
BACKUP_DIR="/data/local/tmp/acmt_backup"
UPLOAD_DIR="/data/local/tmp/upload_ext"
APP_DB_DIR="/data/data/co.id.iconpln.acmt/databases"
APP_PREFS_DIR="/data/data/co.id.iconpln.acmt/shared_prefs"
DB_FILE="icmo_api"
XML_FILE="iCMOLogin.xml"
STAT_DB_FILE="$UPLOAD_DIR/${DB_FILE}_stat"
STAT_XML_FILE="$UPLOAD_DIR/${XML_FILE}_stat"
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

# Fungsi memilih file ZIP untuk di-upload
select_zip() {
  FILES=$(su -c "ls $BACKUP_DIR | grep '.zip'")
  if [ -z "$FILES" ]; then
    echo -e "${RED}Tidak ada file ZIP ditemukan.${RESET}"
    exit 1
  fi
  echo "$FILES" | nl
  echo -n "Pilih nomor file: "
  read CHOICE
  SELECTED_FILE=$(echo "$FILES" | sed -n "${CHOICE}p")
  if [ -z "$SELECTED_FILE" ]; then
    echo -e "${RED}Pilihan tidak valid.${RESET}"
    exit 1
  fi
}

# Fungsi ekstraksi file ZIP
extract_zip() {
  su -c "rm -rf $UPLOAD_DIR && mkdir -p $UPLOAD_DIR" && \
  su -c "/data/data/com.termux/files/usr/bin/7z x -p$ZIP_PASSWORD -o$UPLOAD_DIR $BACKUP_DIR/$SELECTED_FILE" > /dev/null 2>&1 && \
  echo -e "${GREEN}File berhasil diekstrak.${RESET}" || \
  echo -e "${RED}Gagal mengekstrak file ZIP.${RESET}"
}

# Fungsi menyalin file ke direktori aplikasi
copy_files() {
  su -c "cp $UPLOAD_DIR/$DB_FILE $APP_DB_DIR/$DB_FILE" && \
  su -c "cp $UPLOAD_DIR/$XML_FILE $APP_PREFS_DIR/$XML_FILE" && \
  echo -e "${GREEN}File berhasil disalin ke direktori aplikasi.${RESET}" || \
  echo -e "${RED}Gagal menyalin file.${RESET}"
}

# Fungsi mengatur izin file berdasarkan stat
restore_permissions() {
  if [ -f "$STAT_DB_FILE" ] && [ -f "$STAT_XML_FILE" ]; then
    DB_UID=$(awk '{print $1}' $STAT_DB_FILE)
    DB_GID=$(awk '{print $2}' $STAT_DB_FILE)
    XML_UID=$(awk '{print $1}' $STAT_XML_FILE)
    XML_GID=$(awk '{print $2}' $STAT_XML_FILE)
    su -c "chown $DB_UID:$DB_GID $APP_DB_DIR/$DB_FILE && chmod 660 $APP_DB_DIR/$DB_FILE"
    su -c "chown $XML_UID:$XML_GID $APP_PREFS_DIR/$XML_FILE && chmod 660 $APP_PREFS_DIR/$XML_FILE" && \
    echo -e "${GREEN}Izin file berhasil dipulihkan.${RESET}" || \
    echo -e "${RED}Gagal memulihkan izin file.${RESET}"
  else
    echo -e "${RED}File stat tidak ditemukan.${RESET}"
    exit 1
  fi
}

# Fungsi membersihkan direktori sementara
cleanup() {
  su -c "rm -rf $UPLOAD_DIR" && \
  echo -e "${GREEN}Direktori sementara berhasil dibersihkan.${RESET}" || \
  echo -e "${RED}Gagal membersihkan direktori sementara.${RESET}"
}

# Fungsi mengaktifkan data seluler
enable_mobile_data() {
  su -c "svc data enable" && \
  echo -e "${GREEN}Data seluler berhasil diaktifkan.${RESET}" || \
  echo -e "${RED}Gagal mengaktifkan data seluler.${RESET}"
}

# Fungsi mengaktifkan pengaturan tanggal dan waktu otomatis
enable_auto_datetime() {
  su -c "settings put global auto_time 1 && settings put global auto_time_zone 1" && \
  echo -e "${GREEN}Pengaturan tanggal dan waktu otomatis berhasil diaktifkan.${RESET}" || \
  echo -e "${RED}Gagal mengaktifkan pengaturan tanggal dan waktu otomatis.${RESET}"
}

# Fungsi meluncurkan aplikasi
launch_app() {
  su -c "am start -n $PACKAGE_NAME/.MainActivity" && \
  echo -e "${GREEN}Aplikasi berhasil diluncurkan.${RESET}" || \
  echo -e "${RED}Gagal meluncurkan aplikasi.${RESET}"
}

# Menjalankan proses
stop_app
select_zip
extract_zip
copy_files
restore_permissions
cleanup
enable_mobile_data
enable_auto_datetime
launch_app
echo -e "${GREEN}Proses upload selesai.${RESET}"