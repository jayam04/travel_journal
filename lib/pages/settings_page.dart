import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/pages/auth/login_screen.dart';
import 'package:travel_journal/provider/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    bool isLoggedIn =
        Provider.of<AuthProvider>(context, listen: true).user == null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(Provider.of<AuthProvider>(context, listen: true)
                    .user
                    ?.displayName ??
                'Guest'),
          ),
          const Divider(
            height: 1,
          ),
          isLoggedIn
              ? ListTile(
                  title: const Text('Login'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                )
              : ListTile(
                  title: const Text('Logout'),
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).signOut();
                  },
                ),
        ],
      ),
    );
  }
}
