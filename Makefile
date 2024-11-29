PROJECT_NAME = DevOps-Showcase
SONAR_URL = {SONAR_URL}
SONAR_TOKEN = {SONAR_TOKEN}
DOCKER_COMPOSE_FILE = docker-compose.yml
TRIVY_SEVERITY = "HIGH,CRITICAL"
REPORT_DIR = reports/security
DOCKER_REGISTRY = your-registry-url
DOCKER_IMAGE = $(DOCKER_REGISTRY)/$(PROJECT_NAME):latest

# Setup simplificado do Docker
setup:
	@echo "Instalando Docker e Docker Compose..."
	# Instalar Docker
	@sudo apt-get update
	@sudo apt-get install -y docker.io
	# Instalar Docker Compose
	@sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
	@sudo chmod +x /usr/local/bin/docker-compose
	# Configurar permissões
	@sudo usermod -aG docker $$USER
	@sudo systemctl start docker
	@sudo systemctl enable docker
	@echo "Setup concluído! Por favor, reinicie sua sessão para aplicar as alterações."

# Análise com SonarQube
sonar:
	@echo "Executando análise com SonarQube..."
	@docker run --rm \
		-e SONAR_HOST_URL=$(SONAR_URL) \
		-e SONAR_LOGIN=$(SONAR_TOKEN) \
		-v "$(PWD):/usr/src" \
		sonarsource/sonar-scanner-cli

# Construir a imagem Docker
build:
	@echo "Construindo as imagens Docker..."
	docker-compose -f $(DOCKER_COMPOSE_FILE) build --no-cache

# Scan de segurança dos containers com Trivy
container-scan:
	@echo "Iniciando scan de segurança dos containers com Trivy..."
	@mkdir -p $(REPORT_DIR)
	@for img in $$(docker-compose -f $(DOCKER_COMPOSE_FILE) config | grep 'image:' | awk '{print $$2}'); do \
		echo "Escaneando imagem: $$img"; \
		docker run --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $(PWD)/$(REPORT_DIR):/reports \
			aquasec/trivy image \
			--severity $(TRIVY_SEVERITY) \
			--format template \
			--template "@/contrib/html.tpl" \
			--output /reports/trivy-$$img.html \
			$$img; \
	done
	@echo "Relatórios de segurança gerados em $(REPORT_DIR)/"

# Verificar o estado da aplicação
health-check:
	@echo "Verificando o estado da aplicação..."
	@curl -o /dev/null -s -w "%{http_code}\n" http://localhost/health-check

# Iniciar os contêineres
up:
	@echo "Iniciando os contêineres..."
	bash ./script/start_application.sh

# Parar e remover os contêineres
down:
	@echo "Parando e removendo os contêineres..."
	bash ./script/stop_application.sh

# Ver logs dos contêineres
logs:
	@echo "Exibindo logs dos contêineres..."
	docker-compose -f $(DOCKER_COMPOSE_FILE) logs -f

# Deploy da aplicação
restart: down up
	@echo "Aplicação restartada com sucesso!"

# Verificação de dependências
dependency-check:
	@echo "Verificando dependências do projeto..."
	@npm install
	@echo "Dependências verificadas com sucesso!"

# Fazer o build da aplicação e subir para o registry Docker
push-registry: build
	@echo "Subindo a imagem do container para o registry..."
	@docker tag $(PROJECT_NAME)_api_solarys:latest $(DOCKER_IMAGE)
	@docker login $(DOCKER_REGISTRY)
	@docker push $(DOCKER_IMAGE)
	@echo "Imagem subida com sucesso para $(DOCKER_REGISTRY)"