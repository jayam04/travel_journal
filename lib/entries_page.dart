import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/provider/auth_provider.dart';

class EntriesPage extends StatefulWidget {
  const EntriesPage({super.key});

  @override
  State<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String user = "${authProvider.user}Hello";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entries'),
      ),
      
      body: Center(
        child: Text(user),
      )
    );
  }
}
