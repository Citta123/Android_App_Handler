#!/data/data/com.termux/files/usr/bin/bash

clear

# Warna teks
GREEN="\033[1;32m" # Hijau untuk pesan berhasil
RED="\033[1;31m"   # Merah untuk pesan gagal
RESET="\033[0m"    # Reset warna

# Pastikan Anda memiliki akses root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Meminta akses root...${RESET}"
  exec su -c "sh $0 $*"
fi

# Menonaktifkan pengaturan tanggal dan waktu yang diberikan oleh jaringan
settings put global auto_time 0
settings put global auto_time_zone 0

# Verifikasi perubahan
if [ "$(settings get global auto_time)" -eq 0 ] && [ "$(settings get global auto_time_zone)" -eq 0 ]; then
    echo -e "${GREEN}Pengaturan tanggal dan waktu otomatis telah dinonaktifkan.${RESET}"
else
    echo -e "${RED}Gagal menonaktifkan pengaturan tanggal dan waktu otomatis.${RESET}"
    exit 1
fi

# Mengambil tahun dan bulan saat ini
YEAR=$(date +'%Y')
MONTH=$(date +'%m')

# Meminta pengguna memasukkan tanggal
echo -n "Masukkan tanggal (1-31): "
read DAY

# Memastikan bahwa tanggal valid
case "$DAY" in
    [1-9]|[12][0-9]|3[01])
        ;; # Tanggal valid
    *)
        echo -e "${RED}Tanggal tidak valid. Harap masukkan tanggal antara 1 dan 31.${RESET}"
        exit 1
        ;;
esac

# Menghitung jumlah hari dalam bulan saat ini
DAYS_IN_MONTH=$(cal "$MONTH" "$YEAR" | awk 'NF {DAYS = $NF}; END {print DAYS}')

# Rollover jika tanggal lebih besar dari jumlah hari dalam bulan
if [ "$DAY" -gt "$DAYS_IN_MONTH" ]; then
    echo -e "${RED}Tanggal $DAY tidak valid untuk bulan ini. Mengatur menjadi hari terakhir bulan tersebut.${RESET}"
    DAY=$DAYS_IN_MONTH
fi

# Mengatur waktu sistem ke jam 07:00
HOUR=7
MINUTE=0

# Memformat tanggal untuk perintah date
FORMATTED_DATE=$(printf "%02d%02d%02d%02d%04d" "$MONTH" "$DAY" "$HOUR" "$MINUTE" "$YEAR")

# Mengatur waktu sistem
if su -c "date $FORMATTED_DATE"; then
    echo -e "${GREEN}Waktu sistem berhasil diatur.${RESET}"
else
    echo -e "${RED}Gagal mengatur waktu sistem.${RESET}"
    exit 1
fi

# Mengatur zona waktu ke GMT+7
if su -c "setprop persist.sys.timezone 'Asia/Jakarta'"; then
    echo -e "${GREEN}Zona waktu berhasil diatur.${RESET}"
else
    echo -e "${RED}Gagal mengatur zona waktu.${RESET}"
    exit 1
fi

echo -e "${GREEN}Proses selesai. Tanggal berhasil diubah.${RESET}"