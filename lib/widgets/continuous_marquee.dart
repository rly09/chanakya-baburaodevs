import 'dart:async';
import 'package:flutter/material.dart';

class ContinuousMarquee extends StatefulWidget {
  final List<String> items;
  final TextStyle textStyle;

  const ContinuousMarquee({
    super.key,
    required this.items,
    required this.textStyle,
  });

  @override
  State<ContinuousMarquee> createState() => _ContinuousMarqueeState();
}

class _ContinuousMarqueeState extends State<ContinuousMarquee> {
  late ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        
        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(currentScroll + 2.0); // Adjust speed here
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 30,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          // Infinite loop
          final item = widget.items[index % widget.items.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emergency, size: 12, color: Colors.redAccent),
                const SizedBox(width: 8),
                Text(item.toUpperCase(), style: widget.textStyle),
              ],
            ),
          );
        },
      ),
    );
  }
}
