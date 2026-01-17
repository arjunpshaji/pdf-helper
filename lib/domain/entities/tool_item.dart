import 'package:flutter/material.dart';

enum ToolCategory { create, edit, organize, convert, security }

class ToolItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final ToolCategory category;
  final String route;
  final bool isNew;

  const ToolItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.category,
    required this.route,
    this.isNew = false,
  });
}
