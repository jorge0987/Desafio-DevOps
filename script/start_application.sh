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

echo "Executando docker-compose!"
docker-compose up -d

echo
docker-compose ps
sleep 5
echo

echo "Validando estado da aplicação..."
url="http://localhost:3333/health-check"
status_code=$(curl -o /dev/null -s -w "%{http_code}" $url)

if [ "$status_code" -eq 200 ]; then
    echo "Health check bem-sucedido! Aplicação rodando normalmente!"
else
    echo "Falha no health check! Status: $status_code"
fi



