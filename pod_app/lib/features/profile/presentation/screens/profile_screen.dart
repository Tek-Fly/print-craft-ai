import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text field with the user's current display name
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _textController.text = authProvider.user?.displayName ?? '';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.status == AuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!authProvider.isAuthenticated || authProvider.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please sign in to view your profile.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger Google Sign-In
                      authProvider.signInWithGoogle();
                    },
                    child: const Text('Sign in with Google'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  'Email: ${authProvider.user!.email}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final newName = _textController.text.trim();
                    if (newName.isNotEmpty) {
                      authProvider.updateProfile(displayName: newName);
                    }
                  },
                  child: const Text('Update Profile'),
                ),
                const Divider(height: 40),
                ElevatedButton(
                  onPressed: () {
                    authProvider.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
