import 'package:flutter/material.dart';
import 'package:travel_journal/entries_page.dart';
import 'package:travel_journal/journals_page.dart';
import 'package:travel_journal/settings_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  void handleClick() {
    // TODO: Handle click
  }
  @override
  Widget build(BuildContext context) {
    // Handle navigation
    Widget page;
    switch (currentPageIndex) {
      case 0:
        page = const EntriesPage();
        break;
      case 1:
        page = const JournalsPage();
        break;
      case 2:
        page = const SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $currentPageIndex');
    }

    // Build the page
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Center(
        child: page,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: handleClick,
        tooltip: currentPageIndex == 0 ? 'Add Entry' : 'Add Journal',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.transparent,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Entries',
          ),
          NavigationDestination(
              selectedIcon: Icon(Icons.airplane_ticket),
              icon: Icon(Icons.airplane_ticket_outlined),
              label: "Journals"),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_rounded),
            icon: Icon(Icons.person_outline_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
