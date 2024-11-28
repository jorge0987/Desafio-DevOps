#!/bin/bash

echo "Parando aplicação..."
echo


if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose não encontrado!"
    echo "Necessário realizar a instalação do [Docker Compose] para parar a aplicação!"
    exit 1
fi


docker-compose down

if [ $? -eq 0 ]; then
    echo
    echo "Aplicação encerrada com sucesso!"
else
    echo
    echo "Falha ao encerrar a aplicação!"
fi