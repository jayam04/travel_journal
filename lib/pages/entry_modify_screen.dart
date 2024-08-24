import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_journal/provider/models.dart';
import 'package:travel_journal/provider/journal_entry_service.dart';
import 'package:travel_journal/provider/journal_service.dart';
import 'package:location/location.dart'; // Add this dependency for location picking

class JournalEntryScreen extends StatefulWidget {
  final JournalEntry entry;
  final bool isNewEntry;

  const JournalEntryScreen({Key? key, required this.entry, this.isNewEntry = false}) : super(key: key);

  @override
  _JournalEntryScreenState createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _journal;
  late String _description;
  String? _location;

  @override
  void initState() {
    super.initState();
    _title = widget.entry.title ?? '';
    _journal = widget.entry.content;
    _description = widget.entry.description ?? '';
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
      widget.entry.content = _journal;
      widget.entry.description = _description;
      widget.entry.location = GeoPoint(0, 0);

      if (widget.isNewEntry) {
        await JournalEntryService().addJournalEntry(widget.entry);
      } else {
        await JournalEntryService().updateJournalEntry(widget.entry);
      }

      Navigator.pop(context); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewEntry ? 'New Entry' : 'Edit Entry'),
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
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _journal,
                decoration: InputDecoration(labelText: 'Journal'),
                onSaved: (value) => _journal = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your journal content';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(labelText: 'Description (Markdown Supported)'),
                  onSaved: (value) => _description = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  maxLines: null,
                  expands: true, // Allows the TextFormField to take up remaining space
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickLocation,
                    child: Text('Pick Location'),
                  ),
                  SizedBox(width: 16),
                  if (_location != null)
                    Text('Location: $_location', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
