#!/bin/bash

echo "Parando aplicação..."
echo

# Verifica se o Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose não encontrado!"
    echo "Necessário realizar a instalação do [Docker Compose] para parar a aplicação!"
    exit 1
fi

# Para a aplicação
docker-compose down

if [ $? -eq 0 ]; then
    echo
    echo "Aplicação encerrada com sucesso!"
else
    echo
    echo "Falha ao encerrar a aplicação!"
fi