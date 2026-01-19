# Rick & Morty Explorer 🌌

![Flutter](https://img.shields.io/badge/Flutter-3.7.2-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

A premium, modern, and responsive Flutter application for exploring the Rick and Morty universe. Built with a focus on UI/UX excellence, performance, and clean architecture.

![Home Preview](docs/assets/home_preview.png)

## ✨ Key Features

- **🚀 Modern Navigation**: Seamless transitions and deep linking support using `go_router`.
- **📱 Fully Responsive**: Adaptive layouts that look great on Mobile, Tablet, and Desktop.
  - **Dynamic Grids**: Lists transform into grids on larger screens.
  - **Content Constraints**: Readable max-widths for comfortable viewing on monitors.
- **🎨 Premium UI**:
  - **Dark Theme**: Immersive "Space Dark" color palette (`#1E1E1E`).
  - **Skeleton Loading**: Smooth shimmer effects during data fetching.
  - **High-Res Imagery**: Optimized image caching with `cached_network_image`.
- **🔍 Powerful Search**:
  - **Debounced Search**: Efficient real-time filtering for Characters, Episodes, and Locations.
  - **Smart Filtering**: Heuristic search for episode codes (e.g., "S01E01").
- **⚡ Performance**:
  - **Pagination**: Infinite scrolling for large datasets.
  - **State Management**: efficient state handling with `Provider`.

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **Navigation**: GoRouter
- **Networking**: HTTP
- **Assets**: Cached Network Image, Flutter Launcher Icons
- **Architecture**: MVVM (Model-View-ViewModel)

## 📸 Screenshots

|             Desktop View              |               Mobile Detail               |
| :-----------------------------------: | :---------------------------------------: |
| ![Home](docs/assets/home_preview.png) | ![Detail](docs/assets/detail_preview.png) |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.7.2`
- Dart SDK

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/rick-morty-explorer.git
   cd rick-morty-explorer
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── data/           # Models and API services
├── viewmodels/     # State management logic (Providers)
├── views/          # UI Components
│   ├── pages/      # Full application screens
│   └── widgets/    # Reusable UI elements
├── router/         # Navigation configuration
└── main.dart       # Entry point
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

_Developed with ❤️ using Flutter_
