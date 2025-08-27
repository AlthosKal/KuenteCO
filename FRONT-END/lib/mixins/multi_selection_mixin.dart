import 'package:flutter/material.dart';

mixin MultiSelectionMixin<T extends StatefulWidget> on State<T> {
  bool _isSelectionMode = false;
  Set<int> _selectedCategoryIds = {};
  Set<String> _selectedEnrollmentKeys = {};

  bool get isSelectionMode => _isSelectionMode;
  Set<int> get selectedCategoryIds => _selectedCategoryIds;
  Set<String> get selectedEnrollmentKeys => _selectedEnrollmentKeys;

  void toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        clearSelection();
      }
    });
  }

  void toggleCategorySelection(int categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
      
      _exitSelectionModeIfEmpty();
    });
  }

  void toggleEnrollmentSelection(String enrollmentKey) {
    setState(() {
      if (_selectedEnrollmentKeys.contains(enrollmentKey)) {
        _selectedEnrollmentKeys.remove(enrollmentKey);
      } else {
        _selectedEnrollmentKeys.add(enrollmentKey);
      }
      
      _exitSelectionModeIfEmpty();
    });
  }

  void selectAllCategories(List<dynamic> categories) {
    setState(() {
      _selectedCategoryIds.clear();
      for (final category in categories) {
        _selectedCategoryIds.add(category.id);
      }
    });
  }

  void selectAllEnrollments(List<dynamic> enrollments) {
    setState(() {
      _selectedEnrollmentKeys.clear();
      for (final enrollment in enrollments) {
        final key = '${enrollment.categoryName}-${enrollment.profileEmail}-${enrollment.userEmail}';
        _selectedEnrollmentKeys.add(key);
      }
    });
  }

  void clearSelection() {
    setState(() {
      _selectedCategoryIds.clear();
      _selectedEnrollmentKeys.clear();
      _isSelectionMode = false;
    });
  }

  void _exitSelectionModeIfEmpty() {
    if (_selectedCategoryIds.isEmpty && _selectedEnrollmentKeys.isEmpty) {
      _isSelectionMode = false;
    }
  }

  void enterSelectionMode() {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
      });
    }
  }
}