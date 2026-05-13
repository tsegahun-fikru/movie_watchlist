// lib/features/home/presentation/widgets/auto_carousel.dart
// Auto-advancing PageView carousel used for the trending movies banner on the
// home screen. Advances every 5 seconds and supports manual prev/next buttons.

import 'dart:async';
import 'package:flutter/material.dart';

/// A [PageView]-based carousel that automatically advances every 5 seconds.
///
/// [items] is the list of data objects to display.
/// [itemBuilder] converts each item into a widget.
/// [showNavigation] toggles the left/right arrow buttons (default: true).
class AutoCarousel extends StatefulWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext, dynamic) itemBuilder;
  final bool showNavigation;

  const AutoCarousel({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.showNavigation = true,
  });

  @override
  State<AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<AutoCarousel> {
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    // Auto-advance to the next page every 5 seconds; wraps around to page 0
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && widget.items.isNotEmpty) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= widget.items.length) nextPage = 0;

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
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

  void _next() {
    if (!_pageController.hasClients) return;

    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void _previous() {
    if (!_pageController.hasClients) return;

    _pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.items.length,
          itemBuilder: (context, index) =>
              widget.itemBuilder(context, widget.items[index]),
        ),

        // Left navigation arrow
        if (widget.showNavigation)
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: _previous,
              ),
            ),
          ),

        // Right navigation arrow
        if (widget.showNavigation)
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: _next,
              ),
            ),
          ),
      ],
    );
  }
}
