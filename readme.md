# 📘 Guía Rápida de Ansible

## 📁 Inventario y Grupos

### 📋 Ver el inventario completo (formato YAML)
```bash
ansible-inventory -i inventory.ini --list -y
```

### 🗂️ Ver la estructura de grupos del inventario
```bash
ansible-inventory -i inventory.ini --graph
```

### 🧩 Estructura típica del `inventory.ini`
```ini
[test]
100.100.1.1

[dev-k8s]
100.100.2.1

[databases]
100.100.3.1

[all_servers:children]
test
dev-k8s
databases

[all_servers:vars]
ansible_user={{ ansible_user }}
ansible_password={{ ansible_password }}
ansible_become_password={{ ansible_become_password }}
```

También puedes declarar los datos directamente:
```ini
[test]
100.100.1.1 ansible_user=admin ansible_ssh_pass=clave123
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