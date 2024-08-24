import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/pages/auth/login_screen.dart';
import 'package:travel_journal/provider/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Provider.of<AuthProvider>(context, listen: true).user == null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
           isLoggedIn ? ListTile(
            title: const Text('Login'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ) : ListTile(
            title: const Text('Logout'),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
          const Divider(
            height: 1,
          ),
          ListTile(
            title: Text(Provider.of<AuthProvider>(context, listen: true).user?.toString() ?? 'Guest'),
          )
        ],
      ),
    );
  }
}
