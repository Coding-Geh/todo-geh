# Todo Geh

[![Flutter](https://img.shields.io/badge/Flutter-3.5+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-blue.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A beautiful, modern Todo app built with Flutter. Manage your tasks with style!

## ✨ Features

- ✅ Create, edit, and delete tasks
- 🎯 Priority levels (Low, Medium, High)
- 📅 Due date tracking
- 🌙 Dark/Light theme support
- 🌍 Multi-language (English & Indonesian)
- 💾 Local SQLite storage
- 🌐 Web support with GitHub Pages

## 🚀 Live Demo

**[Try Todo Geh →](https://coding-geh.github.io/todo-geh/)**

## 📦 Installation

### Prerequisites

- Flutter SDK (3.5.0 or higher)
- Dart SDK (3.5.0 or higher)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Coding-Geh/todo-geh.git
   cd todo-geh
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔨 Build for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/    # App constants
│   └── theme/        # Theme configuration
├── models/           # Data models (Todo)
├── services/         # Database service
├── viewmodels/       # State management (Riverpod)
└── views/            # UI screens & widgets
```

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Database**: SQLite (sqflite)
- **Localization**: easy_localization
- **Code Generation**: freezed, json_serializable

## 📄 License

This project is licensed under the MIT License.

---

Made with ❤️ by [Coding Geh](https://codinggeh.com)
