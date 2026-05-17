# QuickBite - Food Delivery App 🍕

A modern, full-featured food delivery mobile application built with Flutter and Dart.

## 📱 Features

- **Multi-Restaurant Support**: Browse menus from KFC, Pizza Hut, and McDonald's
- **Smart Shopping Cart**: Add, remove, and manage items with real-time price calculation
- **Secure Checkout**: Multiple payment options (Cash on Delivery & Card Payment)
- **Interactive Location Selection**: Choose delivery address using OpenStreetMap integration
- **Order History**: Track past orders with complete details
- **AI-Powered Chatbot**: Get instant help with Google Gemini AI assistant
- **User Authentication**: Secure login and registration with Firebase
- **Beautiful UI**: Clean red-and-white theme following Material Design

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Database**: SQLite (local storage)
- **Maps**: OpenStreetMap with flutter_map
- **AI**: Google Gemini API
- **Authentication**: Firebase
- **State Management**: StatefulWidget
- **Location Services**: Geolocator, Geocoding

## 📦 Dependencies

```yaml
dependencies:
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  google_generative_ai: ^0.4.3
  sqflite: ^2.3.0
  path: ^1.8.3
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
```bash
   git clone https://github.com/ayan999-tech/Food-Delivery-App.git
   cd Food-Delivery-App
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Configure API Keys**
   
   Add your API keys in the respective files:
   - Gemini API: `lib/pages/chatbot_page.dart`
   - Get your key from: https://aistudio.google.com/app/apikey

4. **Run the app**
```bash
   flutter run
```

## 🎯 App Flow

1. **Onboarding** → User registration/login
2. **Home Screen** → Browse restaurants
3. **Restaurant Menu** → View and select items
4. **Cart** → Review order and quantities
5. **Checkout** → Select payment method and delivery location
6. **Order Tracking** → View order history
7. **AI Assistant** → Get help anytime

## 🗺️ Key Features Explained

### Location Selection
- Interactive map powered by OpenStreetMap
- Real-time address geocoding
- Current location detection
- Manual location selection by dragging map

### Payment Methods
- Cash on Delivery
- Card Payment (with validation)
- Secure checkout process

### AI Chatbot
- Powered by Google Gemini 1.5 Flash
- Context-aware responses
- Helps with orders, recommendations, and support

## 📁 Project Structure

lib/
├── pages/
│   ├── Homescreen.dart
│   ├── login.dart
│   ├── onboarding.dart
│   ├── Checkout.dart
│   ├── chatbot_page.dart
│   ├── map_location_screen.dart
│   ├── KFC.dart
│   ├── McDonald.dart
│   ├── PizzaHut.dart
│   ├── History.dart
│   └── Profile.dart
├── database_helper.dart
└── main.dart

## 🔐 Security Note

⚠️ **Important**: API keys are currently hardcoded for development purposes. For production:
- Use environment variables
- Implement backend API
- Never expose API keys in public repositories

## 🤝 Contributing

This is an academic project. Contributions, issues, and feature requests are welcome!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Ayan**
- GitHub: [@ayan999-tech](https://github.com/ayan999-tech)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- OpenStreetMap contributors
- Google Gemini AI for chatbot capabilities
- All open-source packages used in this project

---

**Made with ❤️ using Flutter**
