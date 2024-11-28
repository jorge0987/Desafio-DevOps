# DevOps-Showcase

Uma aplicação Node.js com Nginx como proxy reverso, completamente containerizada e com scripts de automação para deploy.

---
## 🚀 Tecnologias

- Node.js com Express
- Nginx
- Docker & Docker Compose
- Shell Script

---
## 🏗️ Arquitetura

O projeto consiste em dois serviços principais:

1. *API (Node.js)*
    - Porta: 3333
    - Endpoints:
      - /: Hello World
      - /health-check: Monitoramento de uptime

2. *Proxy Reverso (Nginx)*
    - Porta: 80
    - Features:
      - Headers de segurança
      - Limite de request body (10MB)
      - Proxy pass para API

## 📋 Pré-requisitos

Antes de executar o projeto, certifique-se de ter os seguintes itens instalados no sistema:

- *Git*
- Docker
- Docker Compose

> Nota: Os scripts de instalação gerenciam automaticamente estes requisitos em ambientes Debian/Ubuntu.

---
## 🚀 Como executar

1. Clone o repositório e navegue até o diretório do projeto:
    ```bash
    git clone https://github.com/jorge0987/Desafio-DevOps
    cd Desafio-DevOps
    ```

2. Execute o script de deploy:
    ```bash
    bash ./script/start_application.sh
    ```

3. Acesse a aplicação no navegador:
    - URL: [http://localhost](http://localhost)

4. Para cessar a aplicação execute:
    ```bash
    bash ./script/stop_application.sh
    ```

---
## 📂 Estrutura do projeto

```plaintext
Desafio-DevOps/
├── app/
│   ├── app.js           # Aplicação Express com endpoints / e /health-check
│   └── package.json     # Configuração do Node.js e dependências
├── proxy/
│   └── default.conf     # Configuração do Nginx como proxy reverso
├── script/
│   ├── start_application.sh  # Script de inicialização com instalação de dependências
│   └── stop_application.sh   # Script para parar a aplicação
├── Dockerfile          # Configuração de build do container
├── docker-compose.yml  # Orquestração dos serviços (API + Nginx)
└── README.md           # Documentação do projeto
```

---
## 💡 Escolhas Feitas Durante o Desenvolvimento

1. *Uso do Node:*  
    Escolhido pela sua simplicidade e eficiência para criar APIs.

2. *Docker e Docker Compose:*  
    - Docker: Utilizado para isolar a aplicação, garantindo consistência entre diferentes ambientes.  
    - Docker Compose: Escolhido para facilitar a orquestração de serviços e simplificar o fluxo de execução.

3. *Script de Deploy:*  
    Criado para automatizar o processo de build, inicialização e testes do ambiente, proporcionando facilidade na execução.

4. *Estrutura do Repositório:*  
    A organização dos arquivos foi planejada para garantir clareza, seguindo boas práticas para projetos DevOps.

6. *Documentação:*  
    O README foi estruturado de forma detalhada para facilitar a compreensão do projeto e agilizar a replicação do ambiente.

7. *Monitoramento:*  
    A aplicação possui um endpoint de health check que retorna:
    - Status da aplicação
    - Tempo de uptime

### Docker Compose
O trecho abaixo, implementado no docker-compose, inclui uma verificação de saúde (health check) que monitora o estado do contêiner e reinicia-o se necessário:

```yaml

  healthcheck:
        test: ["CMD", "curl", "-f", "http://localhost/health-check"]
        interval: 1m30s
        timeout: 10s
        retries: 3
  restart: unless-stopped
```

7. Segurança

O Nginx está configurado com:

- Headers de proteção contra XSS
- Headers de proteção contra Clickjacking
- Headers para prevenção de MIME-type sniffing
- Limitação do tamanho máximo permitido para o corpo da solicitação do cliente a 10MB
### Nginx Configuration

```nginx
server {
     listen 80;

     location / {
          proxy_pass http://app:3333;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          # Segurança
          add_header X-Frame-Options "DENY";
          add_header X-Content-Type-Options "nosniff";
          add_header X-XSS-Protection "1; mode=block";
     }
     client_max_body_size 10M;
}
```
