# Crontab:
# Todo domingo, uma hora
# 0 1 * * 0 su - -c "~/copiar_para_onedrive.sh > /dev/null 2> /dev/null"

# Enviar BKP local p/ OneDrive
# Ferramenta utilizada: https://github.com/HorselessName/onedrive

BKP_DIR="$HOME/backup"
ONEDRIVE_DIR="$HOME/onedrive_files/zabbix_bkp"
# Sincroniza os arquivos de uma pasta com outra, ignorando caso o arquivo já exista
rsync -a -v --ignore-existing $BKP_DIR/ $ONEDRIVE_DIR/
# Faz upload dos arquivos sincronizados para o OneDrive e libera o espaço em disco local utilizado
# Atençao, o arquivo de configuração deve estar configurado da seguinte forma:

# Configuração do OneDrive:
# mkdir -p $HOME/.config/onedrive/
# wget -O $HOME/.config/onedrive/config https://raw.githubusercontent.com/abraunegg/onedrive/master/config
# vi $HOME/.config/onedrive/config
# sync_dir = "$HOME/onedrive_files"
# upload_only = "true"
# local_first = "true"
# no_remote_delete = "true"

onedrive --synchronize