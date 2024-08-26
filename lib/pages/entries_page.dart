import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/components/list_item.dart';
import 'package:travel_journal/pages/entry_editor_screen.dart';
import 'package:travel_journal/pages/entry_viewer_screen.dart';
import 'package:travel_journal/provider/database_handler.dart';
import 'package:travel_journal/provider/models.dart';
import 'package:travel_journal/provider/auth_provider.dart';
import 'package:travel_journal/provider/journal_entry_service.dart';
import 'package:intl/intl.dart';
import 'package:travel_journal/provider/view_providers/entries_page.dart';

class EntriesPage extends StatefulWidget {
  const EntriesPage({super.key});

  @override
  State<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  final JournalEntryService journalEntryService = JournalEntryService();
  final ScrollController _scrollController = ScrollController();
  bool _showSearchBar = false;
  String _searchQuery = '';
  // TODO: convert it to use Journals as Chips or maybe tags
  List<String> _selectedChips = [];

  final List<String> _availableChips = ['Travel', 'Food', 'Adventure', 'Work'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset <= 0 && !_showSearchBar) {
      setState(() => _showSearchBar = true);
    } else if (_scrollController.offset > 0 && _showSearchBar) {
      setState(() => _showSearchBar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    ViewProvider viewProvider = Provider.of<ViewProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: remove this requirement of temp jouranl
          final newEntry = JournalEntry(
            id: "TEMPX", // Generate a new unique ID
            journalId: '',
            title: '',
            content: '',
            timestamp: Timestamp.now(),
            photos: [],
          );

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      JournalEntryScreen(entry: newEntry, isNewEntry: true)));
        },
        tooltip: 'Add Entry',
        icon: const Icon(Icons.add),
        label: const Text("Entry"),
      ),
      appBar: AppBar(
        // TODO: Fix search bar not working
        title: _showSearchBar
            ? TextField(
                decoration: const InputDecoration(
                  hintText: 'Search entries...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              )
            : const Text('Journal Entries'),
        actions: [
          IconButton(
            icon: Icon(viewProvider.currentView == ViewType.Timeline
                ? Icons.view_list
                : Icons.grid_view),
            onPressed: () {
              setState(() {
                viewProvider.setView(
                    viewProvider.currentView == ViewType.Timeline
                        ? ViewType.Gallery
                        : ViewType.Timeline);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildChips(),
          Expanded(
            child: StreamBuilder<List<JournalEntry>>(
              stream:
                  DatabaseHandler.fetchJournalEntryStream(authProvider.user),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<JournalEntry>? entries = snapshot.data;
                if (entries == null || entries.isEmpty) {
                  return const Center(child: Text('No entries found'));
                }

                // Filter entries based on selected chips
                if (_selectedChips.isNotEmpty) {
                  entries = entries
                      .where((entry) => _selectedChips
                          .any((chip) => entry.journalId.contains(chip)))
                      .toList();
                }

                if (_searchQuery.isNotEmpty) {
                  entries = entries
                      .where((entry) =>
                          entry.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          entry.content
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                return viewProvider.currentView == ViewType.Timeline
                    ? _buildTimelineView(entries)
                    : _buildGalleryView(entries);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChips() {
    return Wrap(
      spacing: 8.0,
      children: _availableChips.map((String chip) {
        return FilterChip(
          label: Text(chip),
          selected: _selectedChips.contains(chip),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedChips.add(chip);
              } else {
                _selectedChips.remove(chip);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTimelineView(List<JournalEntry> entries) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        JournalEntry entry = entries[index];
        Widget itemWidget = CompactCard(
          title: entry.title,
          content: entry.content,
          location: entry.location.toString(),
          imageUrl:
              "https://avatars.githubusercontent.com/u/93824505?v=4", // TODO: Fix this
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EntryViewerScreen(entry: entry),
              ),
            );
          },
        );

        if (index == 0 ||
            !_isSameDay(entries[index - 1].timestamp.toDate(),
                entry.timestamp.toDate())) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  DateFormat('MMMM d, y').format(entry.timestamp.toDate()),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              itemWidget,
            ],
          );
        }

        return itemWidget;
      },
    );
  }

  Widget _buildGalleryView(List<JournalEntry> entries) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 5 / 7,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        JournalEntry entry = entries[index];

        return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EntryViewerScreen(entry: entry),
                ),
              );
            },
            child: ListItem(
              title: entry.title,
              content: entry.content,
              location:
                  '${entry.location?.latitude}, ${entry.location?.longitude}',
              imageUrl:
                  // TODO: Fix this
                  "https://avatars.githubusercontent.com/u/93824505?v=4",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EntryViewerScreen(entry: entry),
                  ),
                );
              },
            ));
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
