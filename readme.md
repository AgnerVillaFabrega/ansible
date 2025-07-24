# COMMANDS ANSIBLE

## 📋 Ver el inventario completo (formato YAML)
```bash
ansible-inventory -i inventory.ini --list -y
```
## 🗂️ Ver la estructura de grupos del inventario
```bash
ansible-inventory -i inventory.ini --graph
```

## 🔍 Probar conectividad (ping SSH):
```bash
ansible all_servers -i inventory.ini -m ping --ask-pass
```

### También puedes probar contra un grupo específico:
```bash
ansible <GRPS> -i inventory.ini -m ping --ask-pass
```

## 🚀 Ejecutar un playbook con user & password
### ▶️ Usando usuario y contraseña SSH
```bash
ansible-playbook playbooks/<playbook>.yml \
  -i inventory.ini \
  -l <grupo> \
  --ask-pass \
  --ask-become-pass
```
### ▶️ Ejecutar en varios grupos
```bash
ansible-playbook playbooks/<playbook>.yml \
  -i inventory.ini \
  -l "dev-k8s,databases" \
  --ask-pass \
  --ask-become-pass
```

### 🧪 Ejemplo concreto:
```bash
ansible-playbook playbooks/scripts.yml \
  -i inventory.ini \
  -l test \
  --ask-pass \
  --ask-become-pass
```


## ⚡ Ejecutar un comando
### 🔹 Uptime en grupo test:
```bash
ansible test -i inventory.ini -a "uptime" --ask-pass
```

### 🔹 Listar espacio en disco:
```bash
ansible all_servers -i inventory.ini -a "df -h" --ask-pass
```


## Verificar sintaxis del playbook
```bash
ansible-playbook playbooks/scripts.yml -i inventory.ini --syntax-check
```

# 🔐 1. Crear un archivo de autenticación cifrado
Este comando solicitara una contraseña para el vault en como medida de seguridad
```bash
ansible-vault create secrets.yml
```

## Ejemplo de contenido:
```yml
ansible_user: user_server
ansible_password: tu_password
ansible_become_password: tu_password
```

Luego en el inventario puedes utilizar las variables de la siguente forma
```ini
[test]
100.100.1.1

[all_servers:children]
test

[all_servers:vars]
ansible_user={{ ansible_user }}
ansible_password={{ ansible_password }}
ansible_become_password={{ ansible_become_password }}
```

## Y al ejecutar:
```bash
ansible-playbook playbooks/scripts.yml -i inventory.ini -l test --ask-vault-pass -e "@secrets.yml"
```

### 🔐 Si no quieres pedir la contraseña a cada rato
Puedes crear un archivo plano con la contraseña del vault y usar --vault-password-file:
```bash
echo "miClaveVault" > ~/.vault_pass.txt
chmod 600 ~/.vault_pass.txt
```

Y luego ejecutas el playbook así:
```bash
ansible-playbook playbooks/scripts.yml -i inventory.ini -l test --vault-password-file ~/.vault_pass.txt -e "@secrets.yml"
```

## O como alternativa mas rapida asignar el usuario y el password en el archivo .ini
```ini
[test]
100.100.1.1 ansible_user=admin ansible_ssh_pass=clave123
```