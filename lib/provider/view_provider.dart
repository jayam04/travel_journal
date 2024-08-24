/*
Provides View for the Journal Entries Page
*/

import 'package:flutter/material.dart';

// ignore: constant_identifier_names
enum ViewType { Timeline, Gallery }


class ViewProvider extends ChangeNotifier {
  ViewType _currentView = ViewType.Timeline;

  ViewType get currentView => _currentView;

  void setView(ViewType viewType) {
    _currentView = viewType;
    notifyListeners();
  }
}