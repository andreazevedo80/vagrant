#!/bin/bash

# Criar usuário Sonar
  sudo useradd sonar

# Atualização do sistema e instalação de ferramentas básicas
yum update -y
yum install wget unzip java-11-openjdk-devel net-tools telnet -y

# Download do SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.1.0.47736.zip

# Descompactar e mover para diretório final
unzip sonarqube-9.1.0.47736.zip -d /opt/
mv /opt/sonarqube-9.1.0.47736 /opt/sonarqube

# Alterar proprietário do diretório SonarQube
chown -R sonar:sonar /opt/sonarqube

# Criar e configurar o serviço SonarQube systemd
touch /etc/systemd/system/sonar.service
echo > /etc/systemd/system/sonar.service
cat <<EOT >> /etc/systemd/system/sonar.service
[Unit]
Description=Sonarqube service
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
[Install]
WantedBy=multi-user.target
EOT

# Iniciar o serviço SonarQube
systemctl daemon-reload
systemctl start sonar

# Download do Sonar Scanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip

# Descompactar e mover para diretório final
unzip sonar-scanner-cli-4.6.2.2472-linux.zip -d /opt/
mv /opt/sonar-scanner-4.6.2.2472-linux /opt/sonar-scanner

# Alterar proprietário do diretório Sonar Scanner
chown -R sonar:sonar /opt/sonar-scanner

# Configurar PATH para Sonar Scanner (adicionado ao /etc/profile)
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile

# Instalar o Node.js
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
sudo yum install nodejs -y

# Habilitar inicialização automática de serviços
sudo systemctl enable sonar

# Validação da instalação
echo "Validando instalação..."

# Verificar status do serviço SonarQube
echo "Verificando status do serviço SonarQube..."
systemctl status sonar | grep active

# Verificar se o SonarQube está acessível
echo "Verificando acessibilidade do SonarQube..."
curl -s http://localhost:9000

# Verificar versão do Sonar Scanner
echo "Verificando versão do Sonar Scanner..."
sonar-scanner --version