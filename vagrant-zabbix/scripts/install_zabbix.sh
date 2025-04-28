# [Passos de instalação de acordo com fabricante para a distribuição selecionada Ubuntu 22.04 (Jammy)] Fonte: https://www.zabbix.com/download?zabbix=6.4&os_distribution=ubuntu&os_version=22.04&components=server_frontend_agent&db=mysql&ws=apache

#!/bin/bash

# Variáveis
MYSQL_ROOT_PASSWORD="mysqlpwd"
ZABBIX_DB="zabbix"
ZABBIX_USER="zabbix"
ZABBIX_PASSWORD="zabbixpwd"

# Atualizar pacotes
sudo apt-get update -y && sudo apt-get upgrade -y

# Instalar o MySQL
sudo apt-get install -y mysql-server

# Iniciar e habilitar o MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Configurar a senha root do MySQL e reforçar a segurança inicial
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"  # Remover usuários anônimos
sudo mysql -e "DROP DATABASE IF EXISTS test;"          # Remover banco de dados de teste
sudo mysql -e "FLUSH PRIVILEGES;"                      # Atualizar as permissões

# Configurar o banco de dados do Zabbix
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE $ZABBIX_DB character set utf8mb4 collate utf8mb4_bin;
CREATE USER '$ZABBIX_USER'@'localhost' IDENTIFIED BY '$ZABBIX_PASSWORD';
GRANT ALL PRIVILEGES ON $ZABBIX_DB.* TO '$ZABBIX_USER'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
EOF

# Baixar o repositório do Zabbix
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb

# Instalar o repositório
sudo dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb

# Atualizar a lista de pacotes
sudo apt-get update

# Instalar o Zabbix server, frontend, e agent
sudo apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# Importar o esquema inicial do Zabbix
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u$ZABBIX_USER -p$ZABBIX_PASSWORD $ZABBIX_DB

# Configurar o Zabbix server
sed -i "s/# DBPassword=/DBPassword=$ZABBIX_PASSWORD/" /etc/zabbix/zabbix_server.conf

# Reiniciar e habilitar serviços
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2


