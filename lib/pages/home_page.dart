import 'package:flutter/material.dart';
import 'package:travel_journal/pages/entries_page.dart';
import 'package:travel_journal/pages/journals_page.dart';
import 'package:travel_journal/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  void handleClick() {
    // TODO: Handle click
    if (currentPageIndex == 0) {
        print("Add Entry Clicked");
    }
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
        page = JournalsPage();
        break;
      case 2:
        page = const SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $currentPageIndex');
    }

    // Build the page
    return Scaffold(
      body: Center(
        child: page,
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
