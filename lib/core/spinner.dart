import 'dart:math';
import 'package:flutter/material.dart';

class Spinner extends StatefulWidget {
  const Spinner({super.key});

  @override
  State<Spinner> createState() => _BouncingLoaderState();
}

class _BouncingLoaderState extends State<Spinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double xPosition, yPosition;
  late double xVelocity, yVelocity;
  late List<double> xPositions, yPositions;
  late List<double> xVelocities, yVelocities;
  final double imageSize = 100.0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(_updatePosition);
    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final Size screenSize = MediaQuery.of(context).size;
      final random = Random();

      // Wyśrodkuj oba kwiatki względem środka ekranu, symetrycznie
      final centerX = (screenSize.width - imageSize) / 2;
      final centerY = (screenSize.height - imageSize) / 2;
      final offset = 120.0; // odległość od środka (możesz zmienić)

      xPositions = [centerX - offset, centerX + offset];
      yPositions = [centerY, centerY];
      xVelocities = [
        3 + random.nextDouble() * 2,
        -(3 + random.nextDouble() * 2),
      ];
      yVelocities = [
        3 + random.nextDouble() * 2,
        -(3 + random.nextDouble() * 2),
      ];

      _initialized = true;
    }
  }

  void _updatePosition() {
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      xPositions[0] += xVelocities[0];
      yPositions[0] += yVelocities[0];
      xPositions[1] += xVelocities[1];
      yPositions[1] += yVelocities[1];

      if (xPositions[0] <= 0 || xPositions[0] + imageSize >= screenSize.width) {
        xVelocities[0] = -xVelocities[0];
      }
      if (xPositions[1] <= 0 || xPositions[1] + imageSize >= screenSize.width) {
        xVelocities[1] = -xVelocities[1];
      }
      if (yPositions[0] <= 0 ||
          yPositions[0] + imageSize >= screenSize.height) {
        yVelocities[0] = -yVelocities[0];
      }
      if (yPositions[1] <= 0 ||
          yPositions[1] + imageSize >= screenSize.height) {
        yVelocities[01] = -yVelocities[1];
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // Prevent build errors before initialization
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        Positioned(
          left: xPositions[0],
          top: yPositions[0],
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: imageSize,
                  height: imageSize,
                ),
              );
            },
          ),
        ),
        Positioned(
          left: xPositions[1],
          top: yPositions[1],
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: imageSize,
                  height: imageSize,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
