import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/entry_viewer_screen.dart';
import 'package:travel_journal/provider/models.dart';
import 'package:travel_journal/provider/auth_provider.dart';
import 'package:travel_journal/provider/journal_entry_service.dart';
import 'package:travel_journal/provider/journal_service.dart';

class EntriesPage extends StatefulWidget {
  const EntriesPage({super.key});

  @override
  State<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  final JournalEntryService journalEntryService = JournalEntryService();
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String user = "${authProvider.user}Hello";

    return Scaffold(
        appBar: AppBar(
          title: const Text('Journal Entries'),
        ),

        //   body: ListView(
        //     children: <Widget>[
        //       Card(child: ListTile(title: Text('One-line ListTile'))),
        //       Card(
        //         child: ListTile(
        //           leading: FlutterLogo(),
        //           title: Text('One-line with leading widget'),
        //         ),
        //       ),
        //       Card(
        //         child: ListTile(
        //           title: Text('One-line with trailing widget'),
        //           trailing: Icon(Icons.more_vert),
        //         ),
        //       ),
        //       Card(
        //         child: ListTile(
        //           leading: FlutterLogo(),
        //           title: Text('One-line with both widgets'),
        //           trailing: Icon(Icons.more_vert),
        //         ),
        //       ),
        //       Card(
        //         child: ListTile(
        //           title: Text('One-line dense ListTile'),
        //           dense: true,
        //         ),
        //       ),
        //       Card(
        //         child: ListTile(
        //           leading: FlutterLogo(size: 56.0),
        //           title: Text('Two-line ListTile'),
        //           subtitle: Text('Here is a second line'),
        //           trailing: Icon(Icons.more_vert),
        //         ),
        //       ),
        //       Card(
        //         child: ListTile(
        //           leading: FlutterLogo(size: 72.0),
        //           title: Text('Three-line ListTile'),
        //           subtitle:
        //               Text('A sufficiently long subtitle warrants three lines.'),
        //           trailing: Icon(Icons.more_vert),
        //           isThreeLine: true,
        //         ),
        //       ),

        //     ],
        //   ),
        // );
        body: StreamBuilder<List<JournalEntry>>(
          stream: journalEntryService.fetchStream("sdf"),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            List<JournalEntry>? entries = snapshot.data;
            if (entries == null || entries.isEmpty) {
              return Center(child: Text('No entries found'));
            }
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                JournalEntry entry = entries[index];
                return Card(
                  child: ListTile(
                    title: Text(entry.title),
                    subtitle: Text("Hi"),
                    trailing: Icon(Icons.more_vert),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntryViewerScreen(entry: entry),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ));
  }
}
