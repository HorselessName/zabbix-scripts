#!/bin/bash
# Crontab para backup automatico
#
# Todo domingo, meia noite
# 0 0 * * Sun /usr/local/bin/bkp_zabbix.sh >> /var/log/backup.log 2>> /var/log/backup.log

# Usuario da crontab (Supostamente o mesmo que LINUX_USER) deve ter permissoes

# Variaveis - Data, usuario, senha, nome do banco de dados.
# Deve existir um arquivo dadosDB com os dados do banco
DATA=`date +%Y-%m-%d`

echo "--------------------------------------------------------------------------------------------"
echo "Inicio do backup."
echo "--------------------------------------------------------------------------------------------"
echo "Data do Backup: $DATA"

# Pq usar aspas duplas: https://unix.stackexchange.com/a/68748/258344
# Preservando line breaks ao enviar output p/ variavel: https://stackoverflow.com/a/22101842/8297745

# Inserir usuario, senha e banco que será feito o backup no arquivo especificado seguindo o padrão abaixo.
LINUX_USER="administrator"

echo "Usuario: $LINUX_USER"

# Arquivo dentro do usuario com os dados do banco deve existir.
DB_USER=$(sed -n -e 's/^DB_USER=//p' <<< "$(cat /home/$LINUX_USER/dadosDB)")
DB_PASS=$(sed -n -e 's/^DB_PASS=//p' <<< "$(cat /home/$LINUX_USER/dadosDB)")
DB_NAME=$(sed -n -e 's/^DB_NAME=//p' <<< "$(cat /home/$LINUX_USER/dadosDB)")

# echo "Usuário MySQL: $DB_USER"
# echo "Senha  MySQL: $DB_PASS"
# echo "Banco  MySQL: $DB_NAME"

# Diretorio que armazena o backup e diretorio de config do Zabbix
BKP_DIR="/home/$LINUX_USER/backup"
# CONF_DIR="/etc/zabbix /usr/lib/zabbix"

echo "Diretorio de backup: $BKP_DIR"

echo "###########################################################################################"
echo "Iniciando DUMP DO SCHEMA"

# Dump da estrutura (Schema) e joga na pasta de backup
docker exec mysql-server /usr/bin/mysqldump --no-data --single-transaction -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" \
    --skip-set-charset --default-character-set=utf8 \
    >$BKP_DIR/bkp_$DB_NAME-schema-$DATA.sql 2>$BKP_DIR/ERROR_LOG

echo "###########################################################################################"
echo ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ."
echo "Iniciando DUMP DOS DADOS"

# Dump dos dados no banco de dados e joga na pasta de backup
# Manual: https://mariadb.com/kb/en/mysqldump/

docker exec mysql-server bash -c /usr/bin/mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" --single-transaction --skip-lock-tables --routines --triggers --no-create-info --no-create-db \
    --skip-set-charset --default-character-set=utf8 \
    --ignore-table="$DB_NAME.acknowledges" \
    --ignore-table="$DB_NAME.alerts" \
    --ignore-table="$DB_NAME.auditlog" \
    --ignore-table="$DB_NAME.auditlog_details" \
    --ignore-table="$DB_NAME.event_recovery" \
    --ignore-table="$DB_NAME.event_suppress" \
    --ignore-table="$DB_NAME.event_tag" \
    --ignore-table="$DB_NAME.events" \
    --ignore-table="$DB_NAME.history" \
    --ignore-table="$DB_NAME.history_log" \
    --ignore-table="$DB_NAME.history_str" \
    --ignore-table="$DB_NAME.history_str_sync" \
    --ignore-table="$DB_NAME.history_sync" \
    --ignore-table="$DB_NAME.history_text" \
    --ignore-table="$DB_NAME.history_uint" \
    --ignore-table="$DB_NAME.history_uint_sync" \
    --ignore-table="$DB_NAME.problem" \
    --ignore-table="$DB_NAME.problem_tag" \
    --ignore-table="$DB_NAME.task" \
    --ignore-table="$DB_NAME.task_acknowledge" \
    --ignore-table="$DB_NAME.task_check_now" \
    --ignore-table="$DB_NAME.task_close_problem" \
    --ignore-table="$DB_NAME.task_remote_command" \
    --ignore-table="$DB_NAME.task_remote_command_result" \
    --ignore-table="$DB_NAME.trends" \
    --ignore-table="$DB_NAME.trends_uint" \
    >$BKP_DIR/bkp_$DB_NAME-$DATA.sql 2>$BKP_DIR/ERROR_LOG

echo ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ."
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${RED}Fim do dump${NC}"

sleep 1

echo -n "Iniciando compactacao do arquivo"
cont=0
while [  $cont -lt 5 ]; do
    echo -n ". "
    let cont=cont+1
    sleep 1
done

# 1. Tar compacta e nomeia o arquivo;
# 2. -C diz onde o arquivo será criado;
# 3. Compacta o arquivo SQL;

tar -cvf $BKP_DIR/bkp_$DB_NAME-$DATA.tar -C $BKP_DIR/ bkp_$DB_NAME-$DATA.sql
tar -cvf $BKP_DIR/bkp_$DB_NAME-schema-$DATA.tar -C $BKP_DIR/ bkp_$DB_NAME-schema-$DATA.sql
# tar -cvf $BKP_DIR/bkp_zabbix-config-$DATA.tar -C $BKP_DIR/ $CONF_DIR

echo -e "${GREEN}Backup concluido!${NC}"
exit 0