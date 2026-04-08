import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/api_service.dart';
import 'features/auth/services/auth_service.dart';
import 'features/recipes/services/recipe_service.dart';
import 'features/user/services/user_service.dart';
import 'features/home/screens/home_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        Provider<ApiService>(
          create: (_) => ApiService(prefs),
        ),

        // Services
        Provider<UserService>(
          create: (context) => UserService(
            apiService: context.read<ApiService>(),
          ),
        ),
        Provider<AuthService>(
          create: (context) {
            final authService = AuthService(
              apiService: context.read<ApiService>(),
            );
            return authService;
          },
        ),
        Provider<RecipeService>(
          create: (context) => RecipeService(
            apiService: context.read<ApiService>(),
          ),
        ),

        // Auth provider
        ChangeNotifierProvider<AuthProvider>(
          create: (context) {
            final provider = AuthProvider(
              userService: context.read<UserService>(),
              authService: context.read<AuthService>(),
            );
            // Initialize auth data once during creation
            Future.microtask(() async {
              try {
                await provider.loadAuthData();
              } catch (e) {
                print('Error initializing auth: $e');
              }
            });
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cooking Share',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        builder: (context, child) {
          return ScaffoldMessenger(
            child: Scaffold(
              body: child,
            ),
          );
        },
        home: const HomeScreen(),
      ),
    );
  }
}
