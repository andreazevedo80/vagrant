#!/bin/bash

# Atualização do sistema e instalação de ferramentas básicas
yum update -y
yum install epel-release -y
yum install wget git net-tools telnet unzip java-11-openjdk-devel -y

# Instalação do Jenkins
sudo wget --no-check-certificate -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y
sudo systemctl daemon-reload
sudo systemctl start jenkins

# Configuração do usuário Jenkins
usermod -s /bin/bash jenkins
sudo su - jenkins
mkdir ~/.kube

# Instalação do Docker e Docker Compose
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo usermod -aG docker jenkins

# Instalação do Sonar Scanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip
unzip sonar-scanner-cli-4.6.2.2472-linux.zip -d /opt/
mv /opt/sonar-scanner-4.6.2.2472-linux /opt/sonar-scanner
chown -R jenkins:jenkins /opt/sonar-scanner
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile

# Instalação do Node.js
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
sudo yum install nodejs -y

# Instalação do K3s
curl -sfL https://get.k3s.io | sh -s - --cluster-init --tls-san 192.168.10.2 --node-ip 192.168.10.2 --node-external-ip 192.168.10.2

# Configuração do Nexus
docker volume create --name nexus-data
docker run -d -p 8081:8081 -p 8123:8123 --name nexus -v nexus-data:/nexus-data sonatype/nexus3

# Instalação do kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Habilitar a inicialização automática de serviços
sudo systemctl enable jenkins
sudo systemctl enable docker
sudo systemctl enable k3s
sudo systemctl enable nexus

# Validando a instalação
echo "Validando instalação..."
echo "Serviços instalados:"
systemctl status jenkins docker k3s nexus | grep active
echo "Verificando Sonar Scanner..."
sonar-scanner --version
echo "Verificando kubectl..."
kubectl version

# Validação de Usuários
echo "Validando usuários..."

# Verificar se o usuário jenkins existe
echo "Verificar se o usuário jenkins existe"
if [[ $(id -u jenkins) ]]; then
  echo "Usuário jenkins encontrado."
else
  echo "Usuário jenkins não encontrado. Criando..."
  sudo useradd jenkins
  sudo passwd jenkins
fi

# Verificar se o usuário jenkins pertence ao grupo docker
echo "Verificar se o usuário jenkins pertence ao grupo docker"
if [[ $(groups jenkins | grep -c docker) -gt 0 ]]; then
  echo "Usuário jenkins pertence ao grupo docker."
else
  echo "Usuário jenkins não pertence ao grupo docker. Adicionando..."
  sudo usermod -aG docker jenkins
fi

# Verificar se o usuário jenkins possui o shell bash como shell padrão
echo "Verificar se o usuário jenkins possui o shell bash como shell padrão"
if [[ $(cat /etc/passwd | grep jenkins | awk '{print $6}') == "/bin/bash" ]]; then
  echo "Usuário jenkins possui o shell bash como shell padrão."
else
  echo "Usuário jenkins não possui o shell bash como shell padrão. Alterando..."
  sudo usermod -s /bin/bash jenkins
fi

# Verificar se o diretório home do usuário jenkins possui permissões corretas
echo "Verificar se o diretório home do usuário jenkins possui permissões corretas"
if [[ $(stat -c "%a" /home/jenkins) == "755" ]]; then
  echo "Diretório home do usuário jenkins possui permissões corretas."
else
  echo "Diretório home do usuário jenkins não possui permissões corretas. Alterando..."
  sudo chmod 755 /home/jenkins
fi

# Verificar se o diretório .kube do usuário jenkins possui permissões corretas
echo "Verificar se o diretório .kube do usuário jenkins possui permissões corretas"
if [[ $(stat -c "%a" /home/jenkins/.kube) == "700" ]]; then
  echo "Diretório .kube do usuário jenkins possui permissões corretas."
else
  echo "Diretório .kube do usuário jenkins não possui permissões corretas. Alterando..."
  sudo chmod 700 /home/jenkins/.kube
fi

# Finalização
