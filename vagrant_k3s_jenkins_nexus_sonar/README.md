# Considerações Gerais

Ter instalado no WINDOWS:
- Oracle VM Virtual BOX instalado
- Vagrant
- Visual Studio Code (Todos os arquivos / comandos foram criados/executados pelo terminal)

# Instalação do Sonarqube

acessar a pasta Challenge\sonar
executar:
vagrant up
vagrant provision

Após:
acessar o sonar: localhost:9000
usuário: admin
senha: admin
* alterar a senha

# Instalar o Kubernets
- acessar a pasta Challenge\k3s e executar:
vagrant up
vagrant provision

# Instação do Jenkins

- acessar a pasta Challenge\jenkins e executar:
vagrant up
vagrant provision

- após instalação acessar via ssh
vagrant ssh

- copiar a senha do administrador: 
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
*copia a senha

-acessar o jenkins: localhost:8080
cola a senha

- Instalar as extensões sugeridas

criar usuário jenkins/jenkins

- criar um trabalho
- criar pipeline
Nome: API_Comentario
- Pipeline
- Definition
Pileline script
- SCM
Git
-repositório
https://github.com/XXXX/API_Comentario.git
-Credentials:
-add

# instalar extensão do sonar no jenkins
- painel de controle
- gerenciar jenkins
- Plugins
- Extensões disponíveis
SonarQube Scanner
instalar

#configurar servidor do sonar no jenkins
- painel de controle
- gerenciar jenkins
- System
- SonarQube servers
Environment variables
Name: soanr-server
server URL: http://192.168.10.6:9000
- add Credentials
- kind
secret text
- Secret
copia o token do sonar
- id
secret-sonar

# Configuar a ferramenta do sonar-scanner no Jenkins
- painel de controle
- Gerenciar Jenkins
- Tools
- SonarQube Scanner
- Name
sonar-scanner
- SONAR_RUNNER_HOME
/opt/sonar-scanner

# Criando usuário nexus
acessar via ssh o jenkins
# acessar o docker no Nexux
docker exec -it nexus bash
cat /nexus-data/admin.password

altere a senha para nexus, usuário admin
disable anonymous access

- server administration
- usermod
- create local user
id: jenkins
first name: jenkins
last name: jenkins
e-mail: jenkins@jenkins.com.br
password: jenkins
confirm password: jenkins
status: Active
roles: nx-admin

# configurar o kuctl no jenkins
Acessar o manager (MV do k3s) e copiar (cat /etc/rancher/k3s/k3s.yaml)
Acessar o jenkins e editar o arquivo configs e colar
vi ~/.kube/configs

su -s /bin/bash jenkins
ID
kubectl

# criar repositório docker

- repository
- repositories
- create repository
docker (hosted)
Name: docker-repo
HTTP: 8123

# Configurar o Nexus no Jenkins
- painel de controle
- gerenciar jenkins
- System
- Propriedades globais
- Váriaveis de ambiente
- Adicionar

nome: NEXUS_URL
valor: localhost:8123

- painel de controle
- gerenciar jenkins
- Credentials
- System
- Global credentials (unrestricted)
- Add Credentials
username: jenkins
password: jenkins
ID: nexus-user