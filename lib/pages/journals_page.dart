import 'package:flutter/material.dart';
import 'package:travel_journal/pages/journal_editor_screen.dart';
import 'package:travel_journal/pages/journal_viewer_screen.dart';
import 'package:travel_journal/provider/encapsulation.dart';
import 'package:travel_journal/provider/models.dart';
import 'package:travel_journal/provider/journal_service.dart';

class JournalsPage extends StatefulWidget {
  JournalsPage({super.key});

  @override
  State<JournalsPage> createState() => _JournalsPageState();
}

class _JournalsPageState extends State<JournalsPage> {
  final JournalService journalService = JournalService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const JournalEditorScreen()));
        },
        tooltip: 'Add Entry',
        icon: const Icon(Icons.add),
        label: const Text("Journal"),
      ),
      appBar: AppBar(
        title: const Text('Journals'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search journals...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Journal>>(
        stream: DatabaseEncapsulation.fetchJournalStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<Journal>? journals = snapshot.data;

          if (journals == null || journals.isEmpty) {
            return Center(child: Text('No journals found'));
          }

          List<Journal> filteredJournals = journals.where((journal) {
            return journal.title.toLowerCase().contains(_searchQuery) ||
                journal.description.toLowerCase().contains(_searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: filteredJournals.length,
            itemBuilder: (context, index) {
              Journal journal = filteredJournals[index];
              return Card(
                child: ListTile(
                  title: Text(journal.title),
                  subtitle: Text(journal.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JournalViewScreen(
                          journal: journal,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
