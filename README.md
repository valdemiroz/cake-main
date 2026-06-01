# Guia de Instalação - Cake Main

## Informações do Projeto

**Descrição:** Esse é o primeiro aplicativo que desenvolvemos com nossos colegas (e apoio de IA) no projeto de TI, na escola QI, Canoas.

---

## Autores

| Nome | E-mail | Função |
|------|--------|--------|
| **GitHub Copilot** | copilot@github.com | Assistência em IA para Desenvolvimento |
| **Claude AI** | claude@anthropic.com | Assistência em IA para Desenvolvimento |
| **Alisson** | alissonsodregarcia@gmail.com | Full-stack |
| **Matheus** | matheus@gmail.com | Frontend |
| **Jefferson** | jefferson@gmail.com | Backend e desenvolvimento da mini I.A. |
| **Leonardo** | leonardoabadi@gmail.com | Analista e revisor do código |

---

## Pré-requisitos

### Para Android

- **Android 5.0** (API 21) ou superior
- **Espaço em disco**: Mínimo 100 MB
- **RAM**: Mínimo 2 GB recomendado
- **Conexão com Internet**: Para download do aplicativo

### Para Computador (Desenvolvimento)

#### Sistema Operacional
- **Windows 10+**, **macOS 10.14+**, ou **Linux (Ubuntu 18.04+)**

#### Ferramentas Obrigatórias (Para computadores)

1. **Flutter SDK** (v3.0+)
   - Download: https://flutter.dev/docs/get-started/install
   
2. **Dart SDK** (incluído no Flutter)
   - Automaticamente instalado com Flutter
   
3. **Git**
   - Windows: https://git-scm.com/download/win
   - macOS: `brew install git`
   - Linux: `sudo apt-get install git`
   
4. **Android Studio** (recomendado)
   - Download: https://developer.android.com/studio
   - Inclui SDK do Android, emulador e ferramentas de desenvolvimento
   
5. **JDK 11+**
   - Recomendado: OpenJDK 11
   - Download: https://adoptopenjdk.net/

#### Ferramentas Opcionais (Para computadores)

- **Visual Studio Code** com Flutter Extension
- **Xcode** (macOS apenas, para compilação iOS)
- **C++ Build Tools** (para suporte nativo em C++)

---

## Instalação para Android

### Método 1: Instalação via APK (Recomendado para Usuários)

#### Passo 1: Ativar Instalação de Fontes Desconhecidas
1. Vá para **Configurações** > **Segurança** (ou **Privacidade**)
2. Procure por **"Instalar aplicativos desconhecidos"** ou **"Fontes desconhecidas"**
3. Selecione seu navegador ou gerenciador de arquivos e marque a opção (Não se preocupe com vírus, pois o App NÃO CONTÉM; é comum para todos os dispositivos desconfiarem de apps recém-criados).

#### Passo 2: Baixar o APK
1. Acesse o repositório no GitHub: https://github.com/valdemiroz/cake-main
2. Procure pela seção **"Releases"** ou **"Downloads"**
3. Baixe o arquivo `.apk` mais recente

#### Passo 3: Instalar o APK
1. Localize o arquivo baixado (geralmente em `Downloads`)
2. Toque no arquivo `.apk`
3. Selecione **"Instalar"** quando solicitado
4. Aguarde a conclusão da instalação
5. Toque em **"Abrir"** para iniciar o app

### Método 2: Instalação via Computador com ADB (Para Desenvolvedores)

#### Passo 1: Preparar o Computador

Certifique-se de ter instalado:
- Android SDK Platform-Tools
- Windows: Baixe via Android Studio
- macOS: `brew install android-platform-tools`
- Linux: `sudo apt-get install android-platform-tools`

#### Passo 2: Ativar Modo de Desenvolvedor no Android

1. Vá para **Configurações** > **Sobre o Telefone**
2. Toque 7 vezes em **"Número da Versão"** até ver **"Modo de Desenvolvedor Ativado"**
3. Volte para **Configurações** > **Opções do Desenvolvedor**
4. Ative **"Depuração USB"**

#### Passo 3: Conectar e Instalar

```bash
# Conecte seu Android via USB ao computador
# Verifique a conexão
adb devices

# Instale o APK
adb install caminho/para/o/arquivo.apk

# Iniciar o app
adb shell am start -n com.example.cake/.MainActivity
```

---

## Instalação para Computador (Desenvolvimento)

### Passo 1: Clonar o Repositório

```bash
# Abra o terminal/prompt de comando
git clone https://github.com/valdemiroz/cake-main.git
cd cake-main
```

### Passo 2: Instalar Flutter

```bash
# Baixe o Flutter SDK em:
# https://flutter.dev/docs/get-started/install

# Após extrair, adicione ao PATH:
# Windows: Adicione a pasta flutter\bin às variáveis de ambiente
# macOS/Linux: export PATH="$PATH:$(pwd)/flutter/bin"

# Verifique a instalação
flutter --version
```

### Passo 3: Instalar Dependências do Projeto

```bash
# Dentro da pasta cake-main
flutter pub get
```

### Passo 4: Verificar Dispositivos Conectados

```bash
# Lista dispositivos disponíveis
flutter devices

# Ou com adb
adb devices
```

### Passo 5: Executar o Aplicativo

#### No Emulador Android

```bash
# Abrir emulador Android Studio ou:
emulator -avd nome_do_emulador &

# Executar a aplicação
flutter run
```

#### Em Dispositivo Físico

```bash
# Com dispositivo conectado e depuração USB ativada
flutter run

# Ou especificamente
flutter run -d seu_device_id
```

### Passo 6: Compilar APK para Distribuição

```bash
# Build em modo release (otimizado)
flutter build apk --release

# O arquivo gerado estará em:
# build/app/outputs/flutter-apk/app-release.apk
```

### Passo 7: Compilar Bundle Android (Google Play)

```bash
flutter build appbundle --release

# O arquivo gerado estará em:
# build/app/outputs/bundle/release/app-release.aab
```

---

## Estrutura do Projeto

```
cake-main/
├── lib/                # Código Dart (80.6%)
│   ├── main.dart       # Tela principal
│   ├── paginas/        # Telas do aplicativo
│   └── services/       # Serviços e lógica
├── android/            # Código nativo Android
├── ios/                # Código nativo iOS
├── windows/            # Código nativo Windows
├── linux/              # Código nativo Linux
├── macos/              # Código nativo macOS
├── web/                # Código web
├── cpp/                # Código C++ (9.7%)
├── pubspec.yaml        # Dependências do Flutter
├── CMakeLists.txt      # Configuração CMake (7.5%)
└── README.md           # Documentação
```

---

## Dúvidas

### Erro: "Flutter não é reconhecido"
- Adicione `flutter/bin` ao PATH do seu sistema
- Reinicie o terminal/prompt

### Erro: "Android SDK não encontrado"
- Instale Android Studio
- Configure a variável `ANDROID_HOME`
- Execute `flutter doctor` para verificar

### Erro: "Nenhum dispositivo encontrado"
- Ative a Depuração USB no Android
- Instale os drivers USB apropriados
- Execute `adb devices` para verificar

### Erro: "Dependências faltando"

```bash
flutter pub get
flutter pub upgrade
```

### Erro ao compilar C++
- Instale NDK do Android
- Configure CMake corretamente
- Verifique os pré-requisitos do compilador

---

## Suporte e Contribuição

Para reportar problemas ou sugerir melhorias:

1. Abra uma issue no repositório
2. Descreva o problema detalhadamente
3. Inclua logs e informações do sistema (saída do `flutter doctor`)

**Repositório:** https://github.com/valdemiroz/cake-main

---

**Desenvolvido em 2026, na Escola técnica QI, pela equipe Cake Main**
