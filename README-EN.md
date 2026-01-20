[中文](README.md)

# Farewell Notes 📝💌

A Flutter application designed to help users with emotional farewells. Through two core features—**Time Capsule Mailbox** and **Digital Footprint Cleanup**—it allows users to find emotional closure and release in the digital world.

## ✨ Features

### 💌 Time Capsule Mailbox

Write a letter to your future self or a specific person and set an unlock time. The letter remains sealed until the designated time arrives.

- 📝 Create and edit capsule letters
- ⏰ Set unlock time (any moment in the future)
- 👤 Select recipient type (Self/Specific Person/A Memory)
- 🔐 Content remains unviewable until unlocked
- 🔔 Push notification reminders upon unlocking

### 🧹 Digital Footprint Cleanup

Helps users organize and say goodbye to digital traces related to specific individuals.

- 👥 Add and manage farewell targets
- 🔍 Intelligent keyword scanning
- 📸 Photo album scanning (requires authorization)
- 📋 Categorized display of scan results
- 📦 Archive/Hide/Delete operations

> **Note**: Due to mobile permission restrictions, third-party social media data scanning is a simulated feature for demonstration purposes.

## 🎨 Design Philosophy

Adopts **Emotional Design** to convey warmth and healing:

| Element | Design Scheme |
|------|----------|
| 🎨 Colors | Warm gradients (Amber → Coral), Deep Purple → Deep Blue for Dark Mode |
| ✍️ Typography | Handwritten style headings + Clear body text |
| 💫 Animations | Capsule opening, letter unfolding, particle dissipation effects |
| 🔮 Icons | Rounded linear icons to convey softness |
| 🪟 Cards | Glassmorphism + Subtle shadows |

## 🏗️ Project Structure

```
lib/
├── main.dart                        # App Entry
├── models/
│   ├── time_capsule.dart            # Time Capsule Model
│   ├── farewell_target.dart         # Farewell Target Model
│   └── scan_record.dart             # Scan Record Model
├── screens/
│   ├── splash_screen.dart           # Splash Screen
│   ├── home_screen.dart             # Home/Navigation
│   ├── capsule_list_screen.dart     # Capsule List
│   ├── capsule_editor_screen.dart   # Capsule Editor
│   ├── capsule_detail_screen.dart   # Capsule Detail
│   ├── targets_screen.dart          # Target Management
│   └── scan_screen.dart             # Scan Results
├── services/
│   ├── database_service.dart        # Database Service (SQLite)
│   ├── notification_service.dart    # Notification Service
│   └── scan_service.dart            # Scan Service
├── providers/
│   ├── capsule_provider.dart        # Capsule State Management
│   └── target_provider.dart         # Target State Management
├── widgets/
│   ├── capsule_card.dart            # Capsule Card Widget
│   └── target_card.dart             # Target Card Widget
└── utils/
    └── app_theme.dart               # Theme Configuration
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Persistence**: SQLite (sqflite)
- **Local Notifications**: flutter_local_notifications
- **Photo Access**: photo_manager
- **Animations**: flutter_animate
- **Others**: intl (date formatting), uuid (UUID generation), timezone (timezone handling)

## 🚀 Quick Start

### Requirements

- Flutter SDK ^3.9.2
- Dart SDK ^3.9.2

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/zym9863/farewell_notes.git
   cd farewell_notes
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Windows Desktop
   flutter run -d windows

   # Web Browser
   flutter run -d chrome

   # Connected Mobile Device
   flutter run
   ```

## 📱 Supported Platforms

| Platform | Status |
|------|------|
| 🪟 Windows | ✅ Supported |
| 🌐 Web | ✅ Supported |
| 🍎 macOS | ✅ Supported |
| 🐧 Linux | ✅ Supported |
| 📱 Android | ✅ Supported |
| 📱 iOS | ✅ Supported |

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contribution

Issues and Pull Requests are welcome!

---

<p align="center">
  Say goodbye with heart, let go with grace 💝
</p>
