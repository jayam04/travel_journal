import 'package:flutter/material.dart';
import 'package:travel_journal/provider/database_handler.dart';

class JournalEditorScreen extends StatefulWidget {
  const JournalEditorScreen({super.key});

  @override
  _JournalEditorScreenState createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  String _journalName = '';
  String _journalDescription = '';
  bool _setAsDefault = false;

  void _saveJournal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save the journal to Firestore
      String journalId =
          await DatabaseHandler.addJournal(_journalName, _journalDescription);

      if (_setAsDefault) {
        await DatabaseHandler.setDefaultJournal(journalId);
      }

      Navigator.pop(context); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveJournal,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Journal Name Input
              TextFormField(
                decoration: const InputDecoration(labelText: 'Journal Name'),
                onSaved: (value) => _journalName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a journal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _journalDescription = value ?? '',
              ),
              const SizedBox(height: 16),

              // Set as Default Checkbox
              CheckboxListTile(
                title: const Text('Set as default journal'),
                value: _setAsDefault,
                onChanged: (bool? value) {
                  setState(() {
                    _setAsDefault = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
