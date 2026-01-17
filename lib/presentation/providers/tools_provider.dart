import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/tool_item.dart';

final toolsProvider = Provider<List<ToolItem>>((ref) {
  return [
    // Create & Convert
    const ToolItem(
      id: 'img_to_pdf',
      title: 'Image to PDF',
      icon: CupertinoIcons.photo_on_rectangle,
      color: Color(0xFF4CAF50),
      category: ToolCategory.create,
      route: '/img_to_pdf',
    ),
    const ToolItem(
      id: 'scan_pdf',
      title: 'Scan to PDF',
      icon: CupertinoIcons.viewfinder,
      color: Color(0xFF2196F3),
      category: ToolCategory.create,
      route: '/scan_pdf',
    ),
    const ToolItem(
      id: 'pdf_to_img',
      title: 'PDF to Image',
      icon: CupertinoIcons.photo,
      color: Color(0xFF8BC34A),
      category: ToolCategory.convert,
      route: '/pdf_to_img',
    ),
    const ToolItem(
      id: 'doc_to_pdf',
      title: 'Office to PDF',
      icon: CupertinoIcons.doc_text,
      color: Color(0xFF607D8B),
      category: ToolCategory.convert,
      route: '/doc_to_pdf',
      isNew: true,
    ),

    // Optimize
    const ToolItem(
      id: 'merge_pdf',
      title: 'Merge PDF',
      icon: CupertinoIcons.doc_on_doc,
      color: Color(0xFF673AB7),
      category: ToolCategory.organize,
      route: '/merge_pdf',
    ),
    const ToolItem(
      id: 'split_pdf',
      title: 'Split PDF',
      icon: CupertinoIcons.scissors,
      color: Color(0xFFFF9800),
      category: ToolCategory.organize,
      route: '/split_pdf',
    ),
    const ToolItem(
      id: 'compress_pdf',
      title: 'Compress PDF',
      icon: CupertinoIcons.arrow_down_to_line,
      color: Color(0xFFE91E63),
      category: ToolCategory.organize,
      route: '/compress_pdf',
    ),

    // Security
    const ToolItem(
      id: 'lock_pdf',
      title: 'Protect PDF',
      icon: CupertinoIcons.lock_fill,
      color: Color(0xFFF44336),
      category: ToolCategory.security,
      route: '/lock_pdf',
    ),
    const ToolItem(
      id: 'unlock_pdf',
      title: 'Unlock PDF',
      icon: CupertinoIcons.lock_open_fill,
      color: Color(0xFFFF5722),
      category: ToolCategory.security,
      route: '/unlock_pdf',
    ),

    // Edit
    const ToolItem(
      id: 'watermark',
      title: 'Watermark',
      icon: CupertinoIcons.drop,
      color: Color(0xFF00BCD4),
      category: ToolCategory.edit,
      route: '/watermark',
    ),
    const ToolItem(
      id: 'rotate_pdf',
      title: 'Rotate PDF',
      icon: CupertinoIcons.rotate_right,
      color: Color(0xFF607D8B),
      category: ToolCategory.edit,
      route: '/rotate_pdf',
    ),
  ];
});
