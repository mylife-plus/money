# MoneyApp - Project Structure

A professional Flutter app with GetX state management, ScreenUtil for responsive design, and clean architecture.

## 📁 Folder Structure

```
lib/
├── main.dart                    # App entry point with ScreenUtil & GetX setup
├── constants/                   # App-wide constants
│   ├── app_colors.dart         # Color palette
│   ├── app_text_styles.dart    # Text styles with Kumbh Sans font
│   └── app_constants.dart      # General constants (padding, radius, etc.)
├── routes/                      # Navigation & routing
│   ├── app_routes.dart         # Routes enum with path extension
│   └── app_pages.dart          # GetX pages & bindings configuration
├── screens/                     # UI screens
│   └── home/
│       └── home_screen.dart    # Home screen UI
├── controllers/                 # GetX controllers for state management
│   └── home_controller.dart    # Home screen controller
├── widgets/                     # Reusable custom widgets
│   └── custom_text.dart        # Custom text widget with variations
├── services/                    # API services, local storage, etc.
├── models/                      # Data models
└── utils/                       # Utility functions & helpers
```

## 🎨 Features

### 1. **ScreenUtil Integration**
- Design size: 393 x 852 (default reference size)
- Responsive text sizes (.sp)
- Responsive dimensions (.w, .h, .r)

### 2. **GetX State Management**
- Reactive state management with `.obs`
- Clean routing with enum-based routes
- Dependency injection with bindings

### 3. **Custom Text Widget**
- Multiple text style variations (h1-h6, body, label, caption, button)
- Kumbh Sans as default font via Google Fonts
- Easy-to-use static methods

### 4. **Professional Structure**
- Organized folder structure
- Constants for colors, text styles, and app settings
- Clean separation of concerns

## 🚀 How to Use

### Navigation
```dart
// Navigate to a screen
Get.toNamed(AppRoutes.home.path);

// Navigate with arguments
Get.toNamed(AppRoutes.home.path, arguments: {'id': 123});

// Go back
Get.back();
```

### Custom Text Widget
```dart
// Using static methods (recommended)
CustomText.h1('Large Heading'),
CustomText.bodyMedium('Regular text'),
CustomText.caption('Small caption', color: AppColors.textSecondary),

// Using constructor with custom style
CustomText(
  'Custom text',
  style: AppTextStyles.bodyLarge,
  color: AppColors.primary,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),
```

### GetX Controller
```dart
// In your controller
class YourController extends GetxController {
  final RxString name = 'John'.obs;

  void updateName(String newName) {
    name.value = newName;
  }
}

// In your UI
Obx(() => CustomText.h3(controller.name.value)),
```

### Responsive Design
```dart
// Responsive padding
Padding(
  padding: EdgeInsets.all(16.w), // Responsive to width
  child: Text('Hello'),
),

// Responsive font size
Text(
  'Hello',
  style: TextStyle(fontSize: 16.sp), // Responsive font size
),

// Responsive dimensions
Container(
  width: 200.w,  // Responsive width
  height: 100.h, // Responsive height
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r), // Responsive radius
  ),
),
```

## 📝 Adding New Screens

1. **Create the route** in `lib/routes/app_routes.dart`:
```dart
enum AppRoutes {
  home,
  profile, // New route
}

extension AppRoutesExtension on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.home:
        return '/home';
      case AppRoutes.profile:
        return '/profile'; // New path
    }
  }
}
```

2. **Create the controller** in `lib/controllers/`:
```dart
class ProfileController extends GetxController {
  // Your state and logic here
}
```

3. **Create the screen** in `lib/screens/profile/`:
```dart
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomText.h2('Profile Screen'),
      ),
    );
  }
}
```

4. **Register the route** in `lib/routes/app_pages.dart`:
```dart
GetPage(
  name: AppRoutes.profile.path,
  page: () => const ProfileScreen(),
  binding: ProfileBinding(),
),
```

5. **Create the binding**:
```dart
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
```

## 🎨 Customization

### Colors
Edit `lib/constants/app_colors.dart` to customize your color palette.

### Text Styles
Edit `lib/constants/app_text_styles.dart` to adjust typography.

### Design Size
Change the design size in `lib/main.dart`:
```dart
designSize: const Size(393, 852), // Your design dimensions
```

## 📦 Dependencies

- `get: ^4.6.6` - State management & routing
- `flutter_screenutil: ^5.9.0` - Responsive UI
- `google_fonts: ^6.2.1` - Kumbh Sans font

## 🎯 Next Steps

1. Add more screens as needed
2. Implement services (API, local storage)
3. Create data models
4. Add utilities and helpers
5. Set up environment configurations

---

Happy Coding! 🚀
