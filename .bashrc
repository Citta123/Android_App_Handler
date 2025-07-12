# Alias
alias ll='ls -alh --color=auto'
alias update='pkg update && pkg upgrade'

# Custom Prompt
export PS1="\033[1;32m\u@\h:\w\033[0m$ "

# Tambahkan direktori ke PATH
export PATH=$PATH:/data/data/com.termux/files/usr/bin

# Pesan Selamat Datang
echo "Selamat datang di Termux! Shell Anda siap digunakan."

# Jalankan main.sh saat shell dibuka
if [ -f ~/main.sh ]; then
    bash ~/main.sh
fi