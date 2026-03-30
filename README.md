<div align="center">

<img src="web/icons/Icon-192.png" width="100" alt="GiftLoop Logo" />

# GiftLoop — Amigo Oculto

**Organize sua dinâmica de amigo oculto de forma simples, segura e encantadora.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=flat&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-4CAF50?style=flat&logo=android&logoColor=white)](https://giftloop-41150.web.app)
[![License](https://img.shields.io/badge/License-MIT-BCA7FF?style=flat)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-F6B8D1?style=flat)](https://github.com/adelsonalvarez/giftloop/releases)

**[🌐 Acessar o App Web](https://giftloop-41150.web.app)**

</div>

---

## 🎬 Vídeo Demonstrativo

> Apresentação do funcionamento do aplicativo e explicação de onde cada requisito foi implementado no código.

[![Assistir no YouTube](https://img.shields.io/badge/YouTube-Assistir%20Demonstração-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/pjUXmRc6IiA)

---

## 📖 Sobre o projeto

O **GiftLoop** é um aplicativo mobile e web que permite organizar dinâmicas de amigo oculto de forma prática, segura e sem custo. O organizador cria o evento, cadastra os participantes e realiza o sorteio com um toque. Cada participante acessa o resultado usando um PIN pessoal criado por ele mesmo — nem o organizador sabe quem tirou quem.

Os dados são sincronizados em tempo real via Firebase, permitindo que o admin crie o evento no celular e os participantes acessem pelo navegador, pelo link enviado via WhatsApp.

> Projeto acadêmico desenvolvido para a disciplina **Desenvolvimento Mobile Profissional** da Pós-Graduação em **Desenvolvimento de Aplicativos Móveis** — PUC/PR (2024–2026).

---

## ✨ Funcionalidades

### 👑 Administrador
- Login seguro com Google Sign-In
- Criar e gerenciar múltiplas dinâmicas
- Cadastrar participantes com nome e telefone
- Editar informações do evento após a criação (nome, data, local, observações)
- Compartilhar convite completo via WhatsApp com código do evento
- Realizar sorteio com um toque — irreversível por segurança
- Excluir eventos com confirmação (long press no card)

### 🎯 Participante
- Acesso por código do evento + telefone + PIN pessoal
- PIN criado pelo próprio participante na primeira entrada (sem SMS, sem conta)
- Sessão local de 30 dias — não precisa digitar o PIN a cada acesso
- Ver a lista de participantes da dinâmica
- Revelar o amigo secreto após o sorteio
- Adicionar e gerenciar lista de presentes desejados
- Funciona em qualquer dispositivo — celular, tablet ou computador

### 🔒 Segurança
- PIN nunca armazenado em texto puro — apenas hash SHA-256 com salt (telefone)
- Administrador não tem acesso ao PIN do participante
- Sorteio realizado apenas uma vez — sem possibilidade de repetição
- Regras de segurança no Firestore separando leitura pública de escrita protegida

---

## 🛠️ Tecnologias

| Tecnologia | Versão | Uso |
|---|---|---|
| Flutter | 3.x | Framework multiplataforma (Android + Web) |
| Dart | 3.x | Linguagem de programação |
| Firebase Auth | ^5.3.0 | Autenticação do admin via Google Sign-In |
| Cloud Firestore | ^5.4.0 | Banco de dados em tempo real |
| Firebase Hosting | — | Hospedagem da versão Web (PWA) |
| Provider | ^6.1.1 | Gerenciamento de estado (MVVM) |
| SharedPreferences | ^2.2.2 | Sessão local do participante |
| crypto | ^3.0.3 | Hash SHA-256 do PIN |
| url_launcher | ^6.3.0 | Integração com WhatsApp |
| flutter_animate | ^4.5.0 | Animações de interface |
| intl | ^0.20.2 | Localização pt_BR e formatação de datas |

---

## 🏗️ Arquitetura — MVVM

O projeto segue o padrão **Model-View-ViewModel** com separação clara de responsabilidades e **Repository Pattern** para abstração do acesso a dados.

```
lib/
├── models/              # Entidades de dados: Event, Participant, Gift
├── repositories/        # Interface IEventRepository + implementação Firestore
├── services/            # ViewModel: EventProvider, AuthService, PinService, DrawService
├── screens/             # View: telas organizadas por papel
│   ├── admin/           #   → Home, Criar Evento, Meus Eventos, Participantes
│   ├── participant/     #   → Entrar com Código, PIN, Evento, Amigo Secreto
│   └── auth/            #   → Login Google
└── theme/               # Tema visual centralizado (AppTheme)
```

### Design Patterns aplicados

| Pattern | Onde |
|---|---|
| **Repository** | `IEventRepository` + `FirestoreEventRepository` — acesso a dados intercambiável |
| **Observer** | `ChangeNotifier` + `Consumer` — View atualizada automaticamente |
| **Strategy** | Repositório e DrawService injetáveis — trocáveis sem alterar o ViewModel |
| **Factory** | `Event.fromJson()` / `toJson()` — serialização encapsulada no model |

---

## 🧪 Testes

O projeto possui **64 testes unitários** cobrindo os principais componentes:

| Arquivo | Testes | Cobertura |
|---|---|---|
| `test/draw_service_test.dart` | 8 | Lógica do sorteio, ciclo hamiltoniano, determinismo |
| `test/models_test.dart` | 12 | Serialização/desserialização de Event, Participant, Gift |
| `test/event_provider_test.dart` | 28 | CRUD completo, participantes, presentes, MockRepository |
| `test/pin_service_test.dart` | 16 | Hash SHA-256, verificação de PIN, sessão local |

```bash
# Rodar todos os testes
flutter test

# Rodar com cobertura
flutter test --coverage
```

---

## 📱 Telas do aplicativo

| Tela | Papel | Descrição |
|---|---|---|
| Home | Todos | Landing para visitantes / dashboard para admin logado |
| Login | Admin | Autenticação via Google Sign-In |
| Criar Evento | Admin | Formulário com nome, data, local e observações |
| Meus Eventos | Admin | Lista de eventos com cards informativos |
| Participantes | Admin | Cadastro, sorteio e compartilhamento via WhatsApp |
| Entrar com Código | Participante | Acesso por código + telefone |
| PIN | Participante | Criação e verificação de PIN seguro |
| Evento | Participante | Informações, lista de participantes e amigo secreto |
| Sobre | Todos | Informações do app e requisitos acadêmicos |

### Fluxo de navegação

```
Splash
└── Home
    ├── [visitante] Criar → Login → Criar Evento → Participantes
    ├── [visitante] Entrar → Código + Telefone → PIN → Evento
    ├── [admin]    Criar → Criar Evento → Participantes
    ├── [admin]    Meus Eventos → Lista → Participantes
    └── [admin]    Entrar → Código + Telefone → PIN → Evento
```

---

## 🚀 Como executar

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.x
- [Firebase CLI](https://firebase.google.com/docs/cli) instalado
- Conta Google com projeto Firebase configurado
- Android Studio ou VS Code

### Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/adelsonalvarez/giftloop.git
cd giftloop

# 2. Instale as dependências
flutter pub get

# 3. Configure o Firebase
#    Crie um projeto em console.firebase.google.com
#    Ative: Authentication (Google), Firestore Database, Hosting
#    Gere os arquivos de configuração com o FlutterFire CLI:
dart pub global activate flutterfire_cli
flutterfire configure

#    Adicione manualmente:
#    → android/app/google-services.json
#    → lib/firebase_options.dart

# 4. Execute no Android
flutter run

# 5. Execute no Web
flutter run -d chrome
```

> **⚠️ Atenção:** Os arquivos `google-services.json` e `firebase_options.dart` contêm chaves privadas e **não estão incluídos** neste repositório por segurança. Você precisa configurar seu próprio projeto Firebase.

### Deploy para o Firebase Hosting

```bash
# Build + deploy em um comando
flutter build web && firebase deploy --only hosting

# Deploy apenas das regras do Firestore
firebase deploy --only firestore:rules
```

---

## 🔐 Regras do Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /events/{eventId} {
      // Leitura pública — participantes acessam pelo código sem conta
      allow read: if true;
      // Criação apenas por admin autenticado
      allow create: if request.auth != null
                    && request.resource.data.adminUid == request.auth.uid;
      // Atualização e exclusão apenas pelo admin dono do evento
      allow update, delete: if request.auth != null
                    && request.auth.uid == resource.data.adminUid;
    }
  }
}
```

---

## 👨‍💻 Desenvolvedor

**Adelson Fernando Alvarez Oliveira**

Bacharel em Sistemas de Informação  
Pós-graduando em Desenvolvimento de Aplicativos Móveis — PUC/PR (2024–2026)

[![GitHub](https://img.shields.io/badge/GitHub-adelsonalvarez-181717?style=flat&logo=github)](https://github.com/adelsonalvarez)

---

## 📄 Licença

Distribuído sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
