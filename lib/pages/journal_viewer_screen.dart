import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:travel_journal/provider/encapsulation.dart';
import 'package:travel_journal/provider/models.dart';

class JournalViewScreen extends StatefulWidget {
  final Journal journal;

  const JournalViewScreen({super.key, required this.journal});

  @override
  JournalViewScreenState createState() => JournalViewScreenState();
}

class JournalViewScreenState extends State<JournalViewScreen> {
  bool _isLoading = false;

  void _setAsDefault() async {
    setState(() {
      _isLoading = true;
    });

    log(widget.journal.id.toString());
    await DatabaseEncapsulation.setDefaultJournal(widget.journal.id);

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal set as default')),
    );
  }

  void _deleteJournal() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal'),
        content: const Text('Are you sure you want to delete this journal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseEncapsulation.deleteJournal(widget.journal.id);
      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context); // Go back after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.journal.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _deleteJournal,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Journal ID: ${widget.journal.id}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            // TODO: view Already Set as Default if Journal is default.
            ElevatedButton(
              onPressed: _isLoading ? null : _setAsDefault,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Set as Default'),
            ),
          ],
        ),
      ),
    );
  }
}
