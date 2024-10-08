import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_journal/components/image_grid.dart';
import 'package:travel_journal/components/map_view.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        tooltip: 'Edit Entry',
        icon: const Icon(Icons.edit),
        label: const Text("Edit"),
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
              const SizedBox(height: 16.0),
              Text(
                'Date: ${entry.timestamp.toDate().toLocal()}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16.0),
              if (entry.location != null)
                Text(
                  'Location: ${entry.location}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              const SizedBox(height: 16.0),
              if (entry.content.isNotEmpty)
                MarkdownBody(
                  data: entry.content,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                ),
              const SizedBox(height: 16.0),
              if (entry.photos.isNotEmpty)
                ImageGrid(imageUrls: entry.photos),
              const SizedBox(height: 16.0),
              if (entry.location != null)
                MapView(
                    location: LatLng(entry.location?.latitude ?? 0,
                        entry.location?.longitude ?? 0)),
            ],
          ),
        ),
      ),
    );
  }
}
