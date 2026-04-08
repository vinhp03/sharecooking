import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../recipes/screens/favorite_recipes_screen.dart';
import '../../user/screens/user_profile.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        final isAuthenticated = authProvider.isAuthenticated;

        return Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.orange,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: isAuthenticated && user != null
                      ? (user.avatar != null && user.avatar!.isNotEmpty
                          ? Image.network(
                              'http://localhost:3000${user.avatar}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person),
                            )
                          : const Icon(Icons.person))
                      : const Icon(Icons.person),
                ),
                accountName: Text(
                  isAuthenticated && user != null
                      ? user.username
                      : 'Chưa đăng nhập',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  isAuthenticated && user != null
                      ? user.email
                      : 'Đăng nhập để trải nghiệm',
                ),
              ),
              if (isAuthenticated) ...[
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Công thức yêu thích'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoriteRecipesScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Hồ sơ của tôi'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfileScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Đăng xuất'),
                  onTap: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          try {
                            await authProvider.logout();
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                ),
              ] else
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Đăng nhập/Đăng ký'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
