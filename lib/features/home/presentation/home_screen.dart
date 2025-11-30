import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome ${auth.user?.userName ?? ''}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/profile'),
            child: const Text('Go to Profile Screen'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logged out')));
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
