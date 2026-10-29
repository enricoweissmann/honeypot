# 🤖 Low-Interaction HTTP Honeypot com Monitoramento Persistente

Um Honeypot de baixa interatividade desenvolvido em Ruby para captura, análise e monitoramento de varreduras de portas (*port scans*) e requisições de bots automatizados em tempo real. 

O diferencial deste projeto é a implementação do monitoramento de estado através de conexões persistentes, permitindo saber o momento exato em que o invasor desconectou do sensor.

## ⚙️ Arquitetura e Segurança

Para garantir a integridade do sistema operacional hospedeiro (*Host OS*), o projeto foi estruturado utilizando conceitos modernos de isolamento:

* **Isolamento de Processos:** Executado dentro de um contêiner Linux isolado via **Distrobox (Podman/Docker)** sobre o **Bazzite OS**. Isso garante proteção contra técnicas de *Container Escape*.
* **Escuta em Rede (Socket Bind):** O script realiza o *bind* do soquete TCP na interface `0.0.0.0` e porta `8080`, permitindo capturar tráfego de qualquer interface de rede (Localhost e Sub-rede).
* **Deep Packet Inspection (Parsing):** Análise em tempo real do fluxo de texto da requisição HTTP para isolar os campos `User-Agent` (identificação do scanner/bot) e `Accept-Language`.

---

## 🛠️ Como o Código Funciona (Análise Técnica)

1. **Bind Multicasting (`0.0.0.0`):** O servidor escuta em todas as placas de rede ativas (Loopback e Wi-Fi local).
2. **Multi-Threading (`Thread.start`):** Cada conexão gera uma nova thread independente. Se múltiplos bots atacarem ao mesmo tempo, o Honeypot processa todos concorrentemente sem travar.
3. **Spoofing de Serviço com Keep-Alive:** O script injeta a diretiva `Connection: keep-alive` no cabeçalho HTTP. Isso simula um servidor web Apache real e mantém o canal aberto com o atacante.
4. **Stateful Monitoring (`begin/rescue`):** O script tenta ler continuamente 1 byte do soquete (`client.read(1)`). Quando o visitante fecha a aba ou o bot interrompe a varredura, o canal TCP quebra, disparando a exceção que registra a desconexão no milissegundo exato.


## 🛠️ Tecnologias e Ferramentas Utilizadas

O ecossistema do projeto foi escolhido estrategicamente para simular um ambiente de produção seguro, dividindo-se entre a aplicação defensiva e a infraestrutura de isolamento:

* **Ruby (Lógica da Aplicação):** Escolhido por sua biblioteca nativa de alto nível para manipulação de redes (`socket`). O Ruby permitiu construir um servidor TCP multithread do zero, realizar o parsing manual de strings dos cabeçalhos HTTP (Deep Packet Inspection) e gerenciar o estado das sessões (`keep-alive`) sem a necessidade de frameworks pesados ou dependências externas (*gems*).
* **Distrobox (Camada de Compartimentação):** Utilizado para criar um ambiente de desenvolvimento (neste caso, um container Ubuntu) que compartilha o mesmo kernel do sistema hospedeiro, mas possui seu próprio espaço de usuários e pacotes. Ele funciona como a primeira linha de defesa (*sandbox*): caso o script Ruby sofra um exploit ou uma negação de serviço (DoS), o impacto fica estritamente restrito ao container.
* **Podman / Docker (Engine de Containerização):** O motor por trás do Distrobox. Diferente do Docker tradicional, o Podman opera em modo *rootless* (sem privilégios de superusuário no host) por padrão, o que adiciona uma camada extra de segurança contra ataques de *Container Breakout* (quando o atacante tenta escapar do container para o sistema principal).
* **Bazzite OS / Fedora Silverblue (Host Imutável):** O sistema operacional onde tudo roda. Por ser um sistema baseado em uma imagem imutável (onde o diretório raiz `/` é de apenas leitura), ele mitiga drasticamente a persistência de malwares avançados. Mesmo no pior cenário onde o atacante comprometa o container e o host, ele não conseguiria modificar os binários do sistema operacional principal.


---

## 📊 Telemetria e Logs (Exemplo de Saída)

```text
==========================================================
🤖 HONEYPOT ATIVO - Escutando na porta 8080...
==========================================================

[🟢 CONEXÃO ATIVA] Dispositivo 192.168.0.52 conectou!
════════════════════════════════════════════════════════════
⚠️  [ALERTA DE VARREDURA DETECTADA]
════════════════════════════════════════════════════════════
📅 DATA/HORA : 28/10/2026 às 18:08:12
🌐 ORIGEM    : 192.168.X.XX (Porta: 54321)
🗣️  IDIOMA    : pt-BR
💻 NAVEGADOR : Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)...
════════════════════════════════════════════════════════════
[🔴 CONEXÃO FINALIZADA] O invasor 192.168.0.52 fechou a página ou saiu.
```

---

## 🚀 Como Executar

1. **Clone o repositório:**
   ```bash
   git clone https://github.com
   cd NOME-DO-REPOSITORIO
   ```

2. **Inicie o Honeypot:**
   ```bash
   ruby honeypot.rb
   ```

## 📜 Licença

Este projeto é focado estritamente em fins educacionais e laboratórios de segurança defensiva.
