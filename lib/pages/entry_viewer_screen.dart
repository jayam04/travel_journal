import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:travel_journal/provider/models.dart';

class EntryViewerScreen extends StatelessWidget {
  final JournalEntry entry;

  const EntryViewerScreen({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 16.0),
              Text(
                'Date: ${entry.timestamp.toDate().toLocal()}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: 16.0),
              if (entry.location != null)
                Text(
                  'Location: ${entry.location}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              SizedBox(height: 16.0),
              if (entry.photos != null && entry.photos!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entry.photos!.map((photoUrl) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Image.network(photoUrl),
                    );
                  }).toList(),
                ),
              SizedBox(height: 16.0),
              if (entry.content.isNotEmpty)
                MarkdownBody(
                  data: entry.content,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
