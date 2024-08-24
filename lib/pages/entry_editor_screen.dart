import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/provider/auth_provider.dart';
import 'package:travel_journal/provider/encapsulation.dart';
import 'package:travel_journal/provider/models.dart';
import 'package:location/location.dart'; // Add this dependency for location picking

class JournalEntryScreen extends StatefulWidget {
  final JournalEntry entry;
  final bool isNewEntry;

  const JournalEntryScreen(
      {super.key, required this.entry, this.isNewEntry = false});

  @override
  _JournalEntryScreenState createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _journal;
  late String _content;
  String? _location;

  @override
  void initState() {
    super.initState();
    _title = widget.entry.title ?? '';
    _journal = widget.entry.content;
    _content = widget.entry.content;
    _location = widget.entry.location.toString();
  }

  Future<void> _pickLocation() async {
    final locationData = await Location().getLocation();
    if (locationData != null) {
      setState(() {
        _location = '${locationData.latitude}, ${locationData.longitude}';
      });
    }
  }

  void _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.entry.title = _title;
      widget.entry.journalId = _journal;
      widget.entry.content = _content;
      widget.entry.location = GeoPoint(0, 0);

      await DatabaseEncapsulation.addOrUpdateJournalEntry(
          Provider.of<AuthProvider>(context, listen: false).user, widget.entry);

      Navigator.pop(context); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewEntry ? 'New Entry' : widget.entry.title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _journal,
                decoration: const InputDecoration(labelText: 'Journal'),
                onSaved: (value) => _journal = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your journal content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextFormField(
                  initialValue: _content,
                  decoration: const InputDecoration(
                      labelText: 'Description (Markdown Supported)'),
                  onSaved: (value) => _content = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  maxLines: null,
                  expands:
                      true, // Allows the TextFormField to take up remaining space
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _pickLocation,
                    child: const Text('Pick Location'),
                  ),
                  // const SizedBox(width: 16),
                  if (_location != null)
                    Text('Location: $_location',
                        style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
