# Crontab para backup automatico
#
# Todo domingo, meia noite
# 0 0 * * 0 su - -c "/root/bkp_zabbix.sh > /dev/null 2> /dev/null"

# Variaveis - Data, usuario, senha, nome do banco de dados.
# Deve existir um arquivo dadosDB com os dados do banco
DATA=`date +%Y-%m-%d`

# Pq usar aspas duplas: https://unix.stackexchange.com/a/68748/258344
# Preservando line breaks ao enviar output p/ variavel: https://stackoverflow.com/a/22101842/8297745

DB_USER=$(sed -n -e 's/^DB_USER=//p' <<< "$(cat /root/dadosDB)")
DB_PASS=$(sed -n -e 's/^DB_PASS=//p' <<< "$(cat /root/dadosDB)")
DB_NAME=$(sed -n -e 's/^DB_NAME=//p' <<< "$(cat /root/dadosDB)")

# Diretorio que armazena o backup e diretorio de config do Zabbix
BKP_DIR="/root/backup"
CONF_DIR="/etc/zabbix /usr/lib/zabbix"

# Dump da estrutura (Schema) e joga na pasta de backup
mysqldump --no-data --single-transaction -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" \
    --skip-set-charset --default-character-set=utf8 \
    >$BKP_DIR/bkp_$DB_NAME-schema-$DATA.sql

# Dump dos dados no banco de dados e joga na pasta de backup
# Manual: https://mariadb.com/kb/en/mysqldump/

mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" --single-transaction --skip-lock-tables --routines --triggers --no-create-info --no-create-db \
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
    >$BKP_DIR/bkp_$DB_NAME-$DATA.sql
    2>$BKP_DIR/ERROR_LOG

# Fim do dump

# 1. Tar compacta e nomeia o arquivo; 
# 2. -C diz onde o arquivo será criado; 
# 3. Compacta o arquivo SQL; 

tar -cvf $BKP_DIR/bkp_$DB_NAME-$DATA.tar -C $BKP_DIR/ bkp_$DB_NAME-$DATA.sql
tar -cvf $BKP_DIR/bkp_$DB_NAME-schema-$DATA.tar -C $BKP_DIR/ bkp_$DB_NAME-schema-$DATA.sql
tar -cvf $BKP_DIR/bkp_zabbix-config-$DATA.tar -C $BKP_DIR/ $CONF_DIR
exit 0
