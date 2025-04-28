# Zabbix Server com MySQL usando Vagrant

Este projeto automatiza a criação de um ambiente virtual contendo um servidor Zabbix com MySQL em uma VM Ubuntu 22.04 (Jammy), usando Vagrant e VirtualBox.

## Pré-requisitos

Antes de começar, você precisará ter instalados os seguintes softwares no seu sistema:

- [Vagrant](https://www.vagrantup.com/downloads)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

# Configuração e Provisionamento

### 1. Clone este repositório:

```bash
git clone https://github.com/andreazevedo80/vagrant-zabbix.git
cd vagrant-zabbix
```

### 2. Personalize o Provisionamento (Opcional):
Se necessário, você pode ajustar o arquivo Vagrantfile ou o script de instalação para se adequar ao seu ambiente, como configurar a quantidade de memória RAM, CPUs, ou instalar outros pacotes adicionais.

### 3. Inicialize a VM:
No diretório do projeto, execute o seguinte comando para iniciar e provisionar a máquina virtual:

```bash
vagrant up
```
Este comando irá:

- Criar uma máquina virtual com Ubuntu 22.04 (Jammy).
- Configurar o nome da máquina como srv-zabbix.
- Instalar pacotes de Idioma (pt_BR)
- Definir o fuso horário (America/Sao_Paulo)
- Instalar o MySQL e Zabbix Server (6.4) na VM.
- Configurar a rede e redirecionar a porta 80 da VM para a porta 8000 do host.

### 4. Acesse a Interface Web do Zabbix:

Após a instalação, a interface do Zabbix pode ser acessada via navegador:

```bash
http://localhost:8000/zabbix/
```

## Detalhes do Provisionamento

O script de provisionamento install_zabbix.sh realiza as seguintes ações:

- Atualiza os pacotes do sistema.
- Instala o MySQL Server, altera a senha do root do mysql e cria um banco de dados e usuário para o Zabbix.
- Instala o Zabbix Server, frontend em PHP, e o agente Zabbix.
- Configura o Zabbix para usar o MySQL como banco de dados.
- Reinicia os serviços do Zabbix e Apache.

## Banco de Dados MySQL:
Senha Root MySQL: mysqlpwd
Nome do Banco: zabbix
Usuário: zabbix
Senha: zabbixpwd

## Usuário e senha inicial de login do Zabbix
Usuário: Admin 
Senha: zabbix