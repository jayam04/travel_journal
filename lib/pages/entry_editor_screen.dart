import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/current_location_picker_screen.dart';
import 'package:travel_journal/provider/auth_provider.dart';
import 'package:travel_journal/provider/encapsulation.dart';
import 'package:travel_journal/provider/models.dart';
import 'package:location/location.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImages(ImageSource source) async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Permission denied. Please enable it in settings.')),
      );
    }
  }

  Future<void> _pickLocation() async {
    final locationData = await Location().getLocation();
    if (locationData != null) {
      setState(() {
        _location = '${locationData.latitude}, ${locationData.longitude}';
      });
    }
  }

  Future<void> _uploadImages() async {
    for (var image in _selectedImages) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('journal_entries/${widget.entry.id}/$fileName');

      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();

      // Save the download URL to the entry or elsewhere as needed
      widget.entry.photos?.add(downloadUrl);
    }
  }

  void _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      if (_selectedImages.isNotEmpty) {
        await _uploadImages();
      }

      widget.entry.title = _title;
      widget.entry.journalId = _journal;
      widget.entry.content = _content;
      widget.entry.location =
          GeoPoint(0, 0); // Update this with actual location

      await DatabaseEncapsulation.addOrUpdateJournalEntry(
          Provider.of<AuthProvider>(context, listen: false).user, widget.entry);

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context); // Go back after saving
    }
  }

  @override
  void initState() {
    super.initState();
    _title = widget.entry.title ?? '';
    _journal = widget.entry.content;
    _content = widget.entry.content;
    _location = widget.entry.location.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_location == null) {
      _pickLocation();
    }

    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewEntry ? 'New Entry' : widget.entry.title),
        actions: [
          IconButton(
            icon: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Icon(Icons.save),
            onPressed: _isLoading ? null : _saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                FutureBuilder<Map<String, Journal>>(
                  future:
                      DatabaseEncapsulation.getJournalMap(authProvider.user),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No journals available');
                    } else {
                      return DropdownButtonFormField<String>(
                        value: _journal.isNotEmpty ? _journal : null,
                        decoration: const InputDecoration(labelText: 'Journal'),
                        items: snapshot.data!.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value.title),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _journal = newValue!;
                          });
                        },
                        onSaved: (value) => _journal = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a journal';
                          }
                          return null;
                        },
                      );
                    }
                  },
                ),

                const SizedBox(height: 8),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final LatLng? pickedLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LocationPickerScreen()),
                        );
                        if (pickedLocation != null) {
                          setState(() {
                            _location =
                                '${pickedLocation.latitude}, ${pickedLocation.longitude}';
                          });
                        }
                      },
                      child: const Text('Pick Location'),
                    ),
                    if (_location != null)
                      Text('Location: $_location',
                          style: const TextStyle(fontSize: 14)),
                  ],
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedImages.map((image) {
                    return Image.file(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
                Row(
                  children: [
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.photo_library),
                      onPressed: () async {
                        await _requestPermission(Permission.photos);
                        _pickImages(ImageSource.gallery);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () async {
                        await _requestPermission(Permission.camera);
                        _pickImages(ImageSource.camera);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
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
                  expands: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
