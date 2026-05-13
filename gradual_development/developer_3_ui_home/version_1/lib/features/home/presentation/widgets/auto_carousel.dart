// lib/features/home/presentation/widgets/auto_carousel.dart
// VERSION 1 - Simple carousel (same across all versions)

import 'package:flutter/material.dart';
import 'dart:async';

/// Auto-scrolling carousel for trending movies.
class AutoCarousel extends StatefulWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext, dynamic) itemBuilder;

  const AutoCarousel({
    super.key,
    required this.items,
    required this.itemBuilder,
  });

  @override
  State<AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<AutoCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_currentPage < widget.items.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.items.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemBuilder: (context, index) {
        return widget.itemBuilder(context, widget.items[index]);
      },
    );
  }
}
