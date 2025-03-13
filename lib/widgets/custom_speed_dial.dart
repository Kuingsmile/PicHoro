import 'package:flutter/material.dart';

class SpeedDial extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final List<SpeedDialChild> children;

  const SpeedDial({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.children,
  });

  @override
  SpeedDialState createState() => SpeedDialState();
}

class SpeedDialState extends State<SpeedDial> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._buildSpeedDialChildren(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'mainFAB',
              onPressed: _toggle,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 0.5 * 3.14,
                    child: Icon(_isOpen ? widget.activeIcon : widget.icon),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildSpeedDialChildren() {
    if (!_isOpen) {
      return [];
    }

    return widget.children.map((SpeedDialChild child) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (child.label != null)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      child.label!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            FloatingActionButton.small(
              heroTag: child.label,
              backgroundColor: child.backgroundColor,
              foregroundColor: child.foregroundColor,
              onPressed: () {
                _toggle();
                child.onTap?.call();
              },
              child: child.child,
            ),
          ],
        ),
      );
    }).toList();
  }
}

class SpeedDialChild {
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? label;
  final VoidCallback? onTap;

  SpeedDialChild({
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.label,
    this.onTap,
  });
}
