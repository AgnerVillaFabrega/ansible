# 📘 Guía de Ansible - Gestión de Configuración de Servidores

Este repositorio contiene playbooks, configuración de inventario y archivos de variables para tareas de administración de servidores usando Ansible.

## 🚀 Inicio Rápido con Makefile

### 🛠️ Comandos Principales
```bash
# Mostrar todos los comandos disponibles
make help

# Prueba básica de conectividad
make ping

# Configuración básica (ping + instalar paquetes)
make setup-basic

# Configuración completa (ping + usuarios + paquetes + nginx)
make full-setup
```

### 🔍 Conectividad y Validación
```bash
# Probar conexión a todos los servidores
make ping

# Validar sintaxis de todos los playbooks
make syntax-check

# Listar todos los hosts del inventario
make list-hosts
```

### 👥 Gestión de Usuarios
```bash
# Crear usuarios con acceso sudo
make create-users

# Eliminar usuarios del sistema
make delete-users
```

### 📦 Instalación de Paquetes
```bash
# Instalar paquetes básicos (curl, git)
make install-packages

# Instalar y configurar Nginx
make install-nginx
```

### ⚙️ Tareas de Configuración
```bash
# Ejecutar scripts de configuración
make run-scripts

# Cambiar MTU de red a 1500
make change-mtu
```

### 📊 Monitoreo del Sistema
```bash
# Recopilar información del sistema
make gather-facts

# Verificar tiempo de actividad del servidor
make uptime

# Verificar uso de disco
make disk-usage

# Verificar información de memoria
make memory-info
```

## 📁 Estructura del Repositorio

```
├── playbooks/          # Playbooks de Ansible para varias tareas
├── vars/               # Archivos de variables (usuarios, contraseñas)
├── scripts/            # Scripts shell ejecutados por playbooks
├── inventory.ini       # Configuración de inventario
├── Makefile           # Comandos automatizados
└── CLAUDE.md          # Instrucciones para Claude Code
```

### 🗂️ Grupos del Inventario
- `test` - Servidores de prueba
- `databases` - Servidores de base de datos
- `all_servers` - Grupo padre que contiene todos los grupos de servidores

## 📋 Playbooks Disponibles

### 👥 Gestión de Usuarios
- `create_users.yml` - Crea usuarios con contraseñas por defecto y acceso sudo
- `delete_users.yml` - Elimina usuarios y sus directorios home

### 📦 Instalación de Paquetes
- `install_package.yml` - Instala paquetes básicos (curl, git)
- `nginx_install.yml` - Instala y configura servidor web Nginx

### 🌐 Configuración de Red y Sistema
- `scripts.yml` - Copia y ejecuta el script setup.sh en servidores objetivo
- `change_mtu.yml` - Cambia MTU de interfaz de red a 1500 con verificación

## 📂 Archivos de Variables

### 👥 Gestión de Usuarios
- `vars/users.yml` - Lista de usuarios a crear con sus nombres completos
- `vars/users_to_delete.yml` - Lista de nombres de usuario a eliminar
- `vars/default_password.yml` - Contiene contraseña por defecto encriptada SHA512

### 🔐 Generación de Contraseñas
Para generar nuevas contraseñas encriptadas:
```bash
python3 -c "import crypt; print(crypt.crypt('<PASSWORD>', crypt.mksalt(crypt.METHOD_SHA512)))"
```

## 📁 Inventario y Grupos (Comandos Ansible Directos)

### 📋 Ver el inventario completo (formato YAML)
```bash
ansible-inventory -i inventory.ini --list -y
```

### 🗂️ Ver la estructura de grupos del inventario
```bash
ansible-inventory -i inventory.ini --graph
```

### 🧩 Estructura del `inventory.ini`
```ini
[test]
100.100.1.1

[databases]
100.100.3.1

[all_servers:children]
test
databases

[all_servers:vars]
ansible_user={{ ansible_user }}
ansible_password={{ ansible_password }}
ansible_become_password={{ ansible_become_password }}
```

El inventario soporta SSH heredado con:
```ini
ansible_ssh_common_args='-o HostkeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa -o StrictHostKeyChecking=no'
```

## 🧪 Pruebas de Conectividad

### Probar conexión SSH a todos los grupos
```bash
ansible all_servers -i inventory.ini -m ping --ask-pass
```

### Probar conexión a un grupo específico
```bash
ansible <grupo> -i inventory.ini -m ping --ask-pass
```

## 🚀 Ejecutar Playbooks

### ▶️ Con usuario y contraseña (pregunta en consola)
```bash
ansible-playbook playbooks/<playbook>.yml -i inventory.ini -l <grupo> --ask-pass --ask-become-pass
```

### ▶️ Ejecutar sobre múltiples grupos
```bash
ansible-playbook playbooks/<playbook>.yml -i inventory.ini -l "dev-k8s,databases" --ask-pass --ask-become-pass
```

### ▶️ Ejecutar usando credenciales definidas en el inventory
```bash
ansible-playbook playbooks/<playbook>.yml -i inventory.ini -l <grupo> --become
```

### 🧪 Ejemplo concreto
```bash
ansible-playbook playbooks/scripts.yml -i inventory.ini -l test --ask-pass --ask-become-pass
```

## ⚙️ Ejecutar Comandos Ad-Hoc

### 🔹 Uptime en grupo `test`
```bash
ansible test -i inventory.ini -a "uptime" --ask-pass
```

### 🔹 Ver uso de disco en `all_servers`
```bash
ansible all_servers -i inventory.ini -a "df -h" --ask-pass
```

## ✅ Validación

### Verificar sintaxis del playbook
```bash
ansible-playbook playbooks/<playbook>.yml -i inventory.ini --syntax-check
```

# 🔐 Manejo de Credenciales con Vault

### 1️⃣ Crear archivo de autenticación cifrado
```bash
ansible-vault create secrets.yml
```

#### Ejemplo de contenido
```yaml
ansible_user: user_server
ansible_password: tu_password
ansible_become_password: tu_password
```

#### Uso en inventario
```ini
[all_servers:vars]
ansible_user={{ ansible_user }}
ansible_password={{ ansible_password }}
ansible_become_password={{ ansible_become_password }}
```

### 2️⃣ Ejecutar con Vault
```bash
ansible-playbook playbooks/scripts.yml -i inventory.ini -l test --ask-vault-pass -e "@secrets.yml"
```

### 3️⃣ Evitar ingresar la contraseña cada vez
```bash
echo "miClaveVault" > ~/.vault_pass.txt
chmod 600 ~/.vault_pass.txt
```

```bash
ansible-playbook playbooks/scripts.yml -i inventory.ini -l test --vault-password-file ~/.vault_pass.txt -e "@secrets.yml"
```

# 🧑‍💻 Playbooks

## 👥 Creación de Usuarios

### 🔐 Generar contraseña encriptada (SHA512)
```bash
python3 -c "import crypt; print(crypt.crypt('<PASSWORD_DEFAULT>', crypt.mksalt(crypt.METHOD_SHA512)))"
```

#### Ejemplo de resultado
```bash
$6$aZ4jA2OtNFHgCV/a$foaQV0e5AI3ix88HnziEF0H/tNJNF7oUALAf.ZvvnLMwFkuNXC39SVDw7ipbsgXG.hsphsCfm6XG2ISp7aVFU0
```

### 👉 Pega el hash en `./vars/default_password.yml`

# 📦 Cómo usar grupos en los comandos y playbooks

## En comandos de Ansible
```bash
# Para ejecutar playbooks
ansible-playbook playbooks/<playbook>.yml -i inventory.ini -l "test,databases"

ansible dev-k8s -i inventory.ini -m ping
ansible -i inventory.ini -l "test,databases" -m ping
```

## En los playbooks (hosts)
```yaml
- name: Configuración inicial
  hosts: all_servers
  become: true
  vars_files:
    - ../vars/default_password.yml
  tasks:
    - name: Ejemplo de tarea
      ansible.builtin.ping:
```

O para un solo grupo:
```yaml
- name: Configuración test
  hosts: test
  become: true
  tasks:
    - name: Ejemplo de tarea
      ansible.builtin.ping:
```