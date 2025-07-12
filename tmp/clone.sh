#!/system/bin/sh

clear

# Variabel
REPO_URL="https://github.com/Citta123/ACMT" # URL repository GitHub
RAW_BASE_URL="https://raw.githubusercontent.com/Citta123/ACMT/main" # URL untuk unduhan file langsung
CLONE_DIR="/data/local/tmp/acmt_clone" # Direktori tempat file akan disimpan
ZIP_EXTENSION=".zip" # Ekstensi file ZIP

# Warna teks menggunakan ANSI escape codes
GREEN="\033[1;32m" # Hijau untuk pesan berhasil
RED="\033[1;31m"   # Merah untuk pesan gagal
RESET="\033[0m"    # Reset warna

# Memeriksa apakah skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Meminta akses root...${RESET}"
  exec su -c "sh $0 $*"
fi

# Fungsi membersihkan folder klon jika sudah ada
prepare_clone_directory() {
  if su -c "[ -d $CLONE_DIR ]"; then
    su -c "rm -rf $CLONE_DIR/*" && \
    echo -e "${GREEN}Folder berhasil dibersihkan.${RESET}" || \
    echo -e "${RED}Gagal membersihkan folder.${RESET}"
  else
    su -c "mkdir -p $CLONE_DIR" && \
    echo -e "${GREEN}Folder baru berhasil dibuat.${RESET}" || \
    echo -e "${RED}Gagal membuat folder baru.${RESET}"
  fi
}

# Fungsi menampilkan daftar file ZIP dari repository
list_repo_files() {
  FILES=$(su -c "curl -s $REPO_URL" | grep -Eo 'href="[^"]+\.zip"' | sed 's/^href="//;s/\"$//' | sort | uniq)
  if [ -z "$FILES" ]; then
    echo -e "${RED}Tidak ada file ZIP ditemukan di repository!${RESET}"
    exit 1
  fi

  FILE_ARRAY=()
  COUNT=1
  for FILE in $FILES; do
    BASENAME=$(basename $FILE)
    echo "$COUNT) $BASENAME"
    FILE_ARRAY+=("$BASENAME")
    COUNT=$((COUNT + 1))
  done
}

# Fungsi meminta input pengguna untuk memilih file
select_file() {
  echo -n "Masukkan nomor file yang ingin diunduh: "
  read USER_CHOICE
  SELECTED_FILE=${FILE_ARRAY[$((USER_CHOICE - 1))]}
  if [ -z "$SELECTED_FILE" ]; then
    echo -e "${RED}Pilihan tidak valid!${RESET}"
    exit 1
  fi
}

# Fungsi mengunduh file ZIP yang dipilih
download_zip_file() {
  su -c "curl -o $CLONE_DIR/$SELECTED_FILE $RAW_BASE_URL/$SELECTED_FILE" > /dev/null 2>&1 && \
  echo -e "${GREEN}File berhasil diunduh.${RESET}" || \
  echo -e "${RED}Gagal mengunduh file.${RESET}"
}

# Menjalankan proses
prepare_clone_directory
list_repo_files
select_file
download_zip_file