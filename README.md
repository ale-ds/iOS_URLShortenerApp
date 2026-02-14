# URL Shortener — Desafio Técnico iOS Sênior (Versão 4.0)

Este projeto consiste em uma aplicação iOS desenvolvida como parte de um processo seletivo para Engenheiro de Software Sênior. O objetivo é demonstrar proficiência em arquitetura limpa, boas práticas de engenharia, testes automatizados e domínio da plataforma Apple.

O aplicativo permite que o usuário insira uma URL, encurte-a utilizando uma API remota e visualize um histórico das URLs encurtadas recentemente, gerenciando diversos estados de interface de forma explícita e resiliente.

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Arquitetura](#-arquitetura)
- [Decisões Técnicas](#-decisões-técnicas)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Instalação e Execução](#-instalação-e-execução)
- [Testes](#-testes)
- [API](#-api)
- [Princípios de Engenharia](#-princípios-de-engenharia)

---

## 📱 Visão Geral

O aplicativo foi construído com foco em **robustez** e **previsibilidade**.

### Funcionalidades
- **Encurtamento de URL**: Input validado para envio à API.
- **Histórico**: Lista em memória das últimas URLs encurtadas.
- **Estados de UI**: Feedback visual claro para `Idle`, `Loading`, `Empty`, `Error` e `Success`.
- **Tratamento de Erros**: Mensagens amigáveis e mecanismo de **Retry** para falhas de rede.
- **Offline**: Monitoramento de conectividade (o app reage a mudanças de rede).

### Requisitos Técnicos Atendidos
- **Linguagem**: Swift (iOS 15+).
- **UI**: UIKit 100% ViewCode (sem Storyboards/XIBs).
- **Concorrência**: Swift Concurrency (`async/await`).
- **Gerenciamento de Dependências**: Swift Package Manager (SPM).
- **Build System**: XcodeGen.

---

## 🏛 Arquitetura

O projeto segue rigorosamente o padrão **Clean Swift (VIP)**, escolhido por sua capacidade de separar responsabilidades e facilitar testes unitários granulares. O fluxo de dados é **unidirecional**.

### Ciclo VIP

1.  **View (ViewController)**: Captura interações do usuário e exibe dados. Não contém lógica de negócio.
2.  **Interactor**: Recebe ações da View, executa a lógica de negócios (chamando Workers/UseCases) e manipula o estado atual.
3.  **Presenter**: Recebe os dados brutos do Interactor e os formata para exibição (ViewModel), decidindo *como* a View deve mostrar a informação.

### Camadas Adicionais

-   **Coordinator**: Responsável pela navegação e injeção de dependências, removendo essa responsabilidade das ViewControllers.
-   **Use Cases (Domain)**: Encapsulam regras de negócio puras, agnósticas de UI.
-   **Networking**: Camada de serviço robusta, com tratamento de erros tipado (`NetworkError`) e suporte a `async/await`.
-   **State Management**: A UI é guiada por estados imutáveis (`ViewState`), garantindo que a tela sempre reflita uma única fonte de verdade.

---

## 🛠 Decisões Técnicas

### 1. ViewCode & Auto Layout
A interface foi construída programaticamente para evitar conflitos de merge comuns em Storyboards e garantir controle total sobre o ciclo de vida das views. `NSLayoutConstraint` foi utilizado para layout responsivo.

### 2. Swift Concurrency (Async/Await)
Substituição completa do GCD para um código mais legível, seguro e livre de "callback hell". O tratamento de erros é feito via `do-catch` com propagação de erros customizados.

### 3. XcodeGen
O projeto não versiona o arquivo `.xcodeproj`. Utilizamos o `XcodeGen` para gerar o projeto a partir do arquivo `project.yml`. Isso elimina conflitos de arquivo de projeto em times grandes e garante que a configuração do build seja explícita e auditável.

### 4. Localização (Strings)
Nenhuma string literal é usada no código. Todas as strings estão centralizadas em arquivos `Localizable.strings` e acessadas via Enums fortemente tipados (`LocalizedKey`), prevenindo erros de digitação e facilitando a internacionalização.

### 5. Testabilidade
A arquitetura VIP foi desenhada para testabilidade. Protocolos (Input/Output) definem as fronteiras entre os componentes, permitindo o uso de Spies e Mocks para validar o comportamento de cada camada isoladamente.

---

## 📂 Estrutura do Projeto

A estrutura física de pastas reflete a separação lógica das camadas:

```text
URLShortener/
├── App/                # Configurações do App (AppDelegate, Info.plist)
├── Core/               # Componentes transversais (Extensions, Coordinator, State)
├── Domain/             # Regras de Negócio (Entities, UseCases, Errors)
├── Networking/         # Camada de Rede (HTTPClient, Endpoints, Services)
├── Resources/          # Assets e Localizable.strings
├── Scenes/             # Telas (VIP)
│   └── URLShortener/   # Feature principal
└── URLShortenerTests/  # Testes Unitários e Snapshots
```

---

## 🚀 Instalação e Execução

### Pré-requisitos
- Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) instalado (`brew install xcodegen`)

### Como Rodar

1.  Clone o repositório.
2.  Abra o terminal na raiz do projeto.
3.  Gere o arquivo de projeto:
    ```bash
    xcodegen generate
    ```
4.  Abra o arquivo gerado `URLShortener.xcodeproj`.
5.  Aguarde a resolução dos pacotes SPM.
6.  Execute o esquema `URLShortener` no simulador (iPhone 17 recomendado).

---

## ✅ Testes

O projeto conta com uma suíte abrangente de testes automatizados.

### Unit Tests
Cobrem a lógica de:
-   **Interactors**: Fluxo de dados, manipulação de estado e chamadas de UseCase.
-   **Presenters**: Formatação de dados para a View.
-   **UseCases**: Regras de negócio e integração com serviços.
-   **Networking**: Mapeamento de erros e construção de requisições.
-   **Coordinators**: Navegação.

### Snapshot Tests
Utilizando a biblioteca `SnapshotTesting`, garantimos que a UI não sofra regressões visuais. Testamos os estados:
-   Loading
-   Empty
-   Error (com e sem Retry)
-   Success (Lista preenchida)

### Executando os Testes
No Xcode, pressione `Cmd + U` para rodar toda a suíte de testes.

---

## 🌐 API

O backend utilizado é público e segue a seguinte especificação:

-   **Base URL**: `https://url-shortener-server.onrender.com/api/alias`
-   **POST /api/alias**: Cria um alias para uma URL.
    -   Body: `{ "url": "https://google.com" }`
    -   Response: `{ "alias": "...", "_links": { "self": "...", "short": "..." } }`
-   **GET /api/alias/:id**: Recupera a URL original (usado internamente, não exposto na UI principal).

---

## 💡 Princípios de Engenharia

Este projeto demonstra:
1.  **Separação de Conceitos**: Cada classe tem uma responsabilidade única.
2.  **Injeção de Dependência**: Facilita a troca de implementações e testes.
3.  **Tratamento de Erros**: O app não falha silenciosamente; o usuário é sempre informado.
4.  **Clean Code**: Código legível, autoexplicativo e sem números/strings mágicas.

---
**Desenvolvido como parte do Desafio Técnico iOS - Nubank.**
