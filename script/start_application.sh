#!/bin/bash

echo "Iniciando deploy do ambiente..."
echo

install_docker() {
    echo "Instalando Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "Docker instalado com sucesso!"
}

install_docker_compose() {
    echo "Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose instalado com sucesso!"
}

if ! command -v docker &> /dev/null; then
    echo "Docker não encontrado!"
    install_docker
else
    echo "Docker Ok!"
fi

echo

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose não encontrado!"
    install_docker_compose
else
    echo "Docker Compose Ok!"
fi

echo

# Parar e remover contêineres existentes
echo "Parando contêineres existentes..."
docker-compose down

echo

# Construir as imagens Docker
echo "Construindo as imagens Docker..."
docker-compose build

echo

# Iniciar os contêineres
echo "Executando docker-compose!"
docker-compose up -d

echo
docker-compose ps
sleep 20
echo

# Verificar o estado da aplicação
echo "Validando estado da aplicação..."
url="http://localhost/health-check"
max_retries=10
retry_count=0

while [ $retry_count -lt $max_retries ]; do
    echo "Tentando acessar $url (Tentativa $((retry_count+1)) de $max_retries)"
    status_code=$(curl -o /dev/null -s -w "%{http_code}" $url)
    echo "Código de status: $status_code"
    
    if [ "$status_code" -eq 200 ]; then
        echo "Health check bem-sucedido! Aplicação rodando normalmente!"
        exit 0
    fi
    
    retry_count=$((retry_count+1))
    sleep 5
done

echo "Falha no health check após $max_retries tentativas. Status: $status_code"
exit 1