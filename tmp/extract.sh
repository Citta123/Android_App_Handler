#!/system/bin/sh

clear

# Variabel
CLONE_DIR="/data/local/tmp/acmt_clone" # Lokasi file ZIP hasil kloning
EXTRACT_DIR="/data/local/tmp/acmt_ext" # Lokasi untuk menyimpan hasil ekstraksi
ZIP_EXTENSION=".zip" # Ekstensi file ZIP
ZIP_PASSWORD="Hard@0077" # Kata sandi file ZIP
P7ZIP_PATH="/data/data/com.termux/files/usr/bin/7z" # Jalur lengkap p7zip

# Warna teks menggunakan ANSI escape codes
GREEN="\033[1;32m" # Hijau untuk pesan berhasil
RED="\033[1;31m"   # Merah untuk pesan gagal
RESET="\033[0m"    # Reset warna

# Memeriksa apakah skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Meminta akses root...${RESET}"
  exec su -c "sh $0 $*"
fi

# Fungsi mendeteksi folder ekstraksi
prepare_extract_directory() {
  if su -c "[ -d $EXTRACT_DIR ]"; then
    su -c "rm -rf $EXTRACT_DIR" && \
    echo -e "${GREEN}Folder hasil ekstraksi berhasil dihapus.${RESET}" || \
    echo -e "${RED}Gagal menghapus folder hasil ekstraksi.${RESET}"
  fi
  su -c "mkdir -p $EXTRACT_DIR" && \
  echo -e "${GREEN}Folder ekstraksi baru berhasil dibuat.${RESET}" || \
  echo -e "${RED}Gagal membuat folder ekstraksi baru.${RESET}"
}

# Fungsi menemukan file ZIP di folder kloning
find_zip_file() {
  ZIP_FILE=$(su -c "find $CLONE_DIR -maxdepth 1 -type f -name '*$ZIP_EXTENSION'" | head -n 1)
  if [ -z "$ZIP_FILE" ]; then
    echo -e "${RED}Tidak ada file ZIP ditemukan!${RESET}"
    exit 1
  fi
  echo -e "${GREEN}File ZIP ditemukan.${RESET}"
}

# Fungsi mengekstrak file ZIP dengan kata sandi menggunakan p7zip
extract_zip_file() {
  su -c "$P7ZIP_PATH x -p$ZIP_PASSWORD -o$EXTRACT_DIR $ZIP_FILE" > /dev/null 2>&1 && \
  echo -e "${GREEN}Ekstraksi selesai.${RESET}" || \
  echo -e "${RED}Ekstraksi gagal. Periksa sandi atau file ZIP.${RESET}"
}

# Menjalankan proses
prepare_extract_directory
find_zip_file
extract_zip_file