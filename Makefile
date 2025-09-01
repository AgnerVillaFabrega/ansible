# Makefile para automatizar tareas de Ansible
# Configuración de servidores usando inventory.ini

INVENTORY = inventory.ini
PLAYBOOK_DIR = playbooks
GROUP = all_servers

# Colores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

.PHONY: help ping syntax-check create-users delete-users install-packages install-nginx run-scripts change-mtu

help: ## Mostrar ayuda
	@echo "$(BLUE)Ansible Makefile - Comandos disponibles:$(NC)"
	@echo ""
	@echo "$(GREEN)Conectividad:$(NC)"
	@echo "  ping          - Verificar conectividad con todos los servidores"
	@echo ""
	@echo "$(GREEN)Validación:$(NC)"
	@echo "  syntax-check  - Verificar sintaxis de todos los playbooks"
	@echo ""
	@echo "$(GREEN)Gestión de usuarios:$(NC)"
	@echo "  create-users  - Crear usuarios definidos en vars/users.yml"
	@echo "  delete-users  - Eliminar usuarios definidos en vars/users_to_delete.yml"
	@echo ""
	@echo "$(GREEN)Instalación de paquetes:$(NC)"
	@echo "  install-packages - Instalar paquetes básicos (curl, git)"
	@echo "  install-nginx    - Instalar y configurar Nginx"
	@echo ""
	@echo "$(GREEN)Scripts y configuración:$(NC)"
	@echo "  run-scripts   - Ejecutar script de configuración setup.sh"
	@echo "  change-mtu    - Cambiar MTU de interfaces de red a 1500"
	@echo ""
	@echo "$(GREEN)Tareas combinadas:$(NC)"
	@echo "  setup-basic   - Ping + install-packages (configuración básica)"
	@echo "  full-setup    - Ping + create-users + install-packages + install-nginx"

ping: ## Verificar conectividad con todos los servidores
	@echo "$(YELLOW)Verificando conectividad con todos los servidores...$(NC)"
	ansible $(GROUP) -i $(INVENTORY) -m ping --become

syntax-check: ## Verificar sintaxis de todos los playbooks
	@echo "$(YELLOW)Verificando sintaxis de playbooks...$(NC)"
	@for playbook in $(PLAYBOOK_DIR)/*.yml; do \
		echo "$(BLUE)Verificando $$playbook$(NC)"; \
		ansible-playbook $$playbook -i $(INVENTORY) --syntax-check -vvvv; \
	done

create-users: ## Crear usuarios con contraseña default y acceso sudo
	@echo "$(YELLOW)Creando usuarios en todos los servidores...$(NC)"
	ansible-playbook $(PLAYBOOK_DIR)/create_users.yml -i $(INVENTORY) -l $(GROUP) --become

delete-users: ## Eliminar usuarios del sistema
	@echo "$(YELLOW)Eliminando usuarios de todos los servidores...$(NC)"
	ansible-playbook $(PLAYBOOK_DIR)/delete_users.yml -i $(INVENTORY) -l $(GROUP) --become

install-packages: ## Instalar paquetes básicos (curl, git)
	@echo "$(YELLOW)Instalando paquetes básicos en todos los servidores...$(NC)"
	ansible-playbook $(PLAYBOOK_DIR)/install_package.yml -i $(INVENTORY) -l $(GROUP) --become

install-nginx: ## Instalar y configurar Nginx
	@echo "$(YELLOW)Instalando Nginx en todos los servidores...$(NC)"
	ansible-playbook $(PLAYBOOK_DIR)/nginx_install.yml -i $(INVENTORY) -l $(GROUP) --become

run-scripts: ## Ejecutar script de configuración
	@echo "$(YELLOW)Ejecutando scripts de configuración...$(NC)"
	ansible-playbook $(PLAYBOOK_DIR)/scripts.yml -i $(INVENTORY) -l $(GROUP) --become

change-mtu: ## Cambiar MTU de interfaces de red
	@echo "$(YELLOW)Cambiando MTU de interfaces de red...$(NC)"
	ansible-playbook $(PLAYBOOK_DIR)/change_mtu.yml -i $(INVENTORY) -l $(GROUP) --become

setup-basic: ping install-packages ## Configuración básica: ping + paquetes básicos
	@echo "$(GREEN)Configuración básica completada$(NC)"

full-setup: ping create-users install-packages install-nginx ## Configuración completa
	@echo "$(GREEN)Configuración completa finalizada$(NC)"

# Comandos adicionales de utilidad
list-hosts: ## Listar todos los hosts del inventario
	@echo "$(YELLOW)Hosts disponibles en el inventario:$(NC)"
	ansible-inventory -i $(INVENTORY) --list -y

gather-facts: ## Recopilar información del sistema de todos los servidores
	@echo "$(YELLOW)Recopilando información del sistema...$(NC)"
	ansible $(GROUP) -i $(INVENTORY) -m setup --become

uptime: ## Mostrar uptime de todos los servidores
	@echo "$(YELLOW)Obteniendo uptime de servidores...$(NC)"
	ansible $(GROUP) -i $(INVENTORY) -a "uptime" --become

disk-usage: ## Mostrar uso de disco
	@echo "$(YELLOW)Verificando uso de disco...$(NC)"
	ansible $(GROUP) -i $(INVENTORY) -a "df -h" --become

memory-info: ## Mostrar información de memoria
	@echo "$(YELLOW)Verificando memoria del sistema...$(NC)"
	ansible $(GROUP) -i $(INVENTORY) -a "free -h" --become