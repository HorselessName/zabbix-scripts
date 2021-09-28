# Enviar BKP local p/ OneDrive
# Ferramenta utilizada: https://github.com/HorselessName/onedrive

BKP_DIR="/root/backup"
ONEDRIVE_DIR="/root/onedrive_files/zabbix_bkp"
# Sincroniza os arquivos de uma pasta com outra, ignorando caso o arquivo já exista
rsync -a -v --ignore-existing $BKP_DIR/ $ONEDRIVE_DIR/
# Faz upload dos arquivos sincronizados para o OneDrive e libera o espaço em disco local utilizado
onedrive --synchronize --upload-only --local-first