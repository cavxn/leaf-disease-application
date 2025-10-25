import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/theme_provider.dart';
import 'providers/disease_history_provider.dart';
import 'providers/plant_care_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/garden_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/growth_provider.dart';
import 'providers/garden_journal_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'utils/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to load .env file, but don't fail if it doesn't exist
  try {
    await dotenv.load();
  } catch (e) {
    print('⚠️ .env file not found, using default configuration');
  }
  
  // Automatically grant camera permissions silently
  await _grantPermissionsSilently();
  
  runApp(const LeafDiseaseApp());
}

Future<void> _grantPermissionsSilently() async {
  try {
    // Request camera permission silently
    await Permission.camera.request();
    print('📱 Camera permission granted silently');
    
    // Request photos permission silently
    await Permission.photos.request();
    print('📱 Photos permission granted silently');
    
    // Also request photo library add permission
    await Permission.photosAddOnly.request();
    print('📱 Photo library add permission granted silently');
    
  } catch (e) {
    print('📱 Error granting permissions silently: $e');
  }
}

class LeafDiseaseApp extends StatelessWidget {
  const LeafDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DiseaseHistoryProvider()),
        ChangeNotifierProvider(create: (_) => PlantCareProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => GardenProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => GrowthProvider()),
        ChangeNotifierProvider(create: (_) => GardenJournalProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Leaf Disease Detector',
            debugShowCheckedModeBanner: false,
            
            // Localization
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
            ],
            
            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Navigation
            home: const MainNavigationScreen(),
            
            // Route generation
            onGenerateRoute: (settings) {
              // Add route generation logic here
              return null;
            },
          );
        },
      ),
    );
  }
}