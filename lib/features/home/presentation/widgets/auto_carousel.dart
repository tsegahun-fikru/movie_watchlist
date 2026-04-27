import 'dart:async';
import 'package:flutter/material.dart';

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

        // LEFT BUTTON
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

        // RIGHT BUTTON
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
