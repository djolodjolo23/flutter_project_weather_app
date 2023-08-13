import 'package:flutter/material.dart';

class SpinningLettersWidget extends StatefulWidget {
  const SpinningLettersWidget({super.key});

  @override
  createState() => _SpinningLettersWidgetState();
}

class _SpinningLettersWidgetState extends State<SpinningLettersWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Text(
        'Flutter is fun!',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Screen3 extends StatelessWidget {
  const Screen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Project Weather App',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'This app is developed for the course\n 1DV535 at Linnaeus University using Flutter and \nthe OpenWeatherMap API. \n\n Developed by Djordje Dimitrov, student at Linnaeus University.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            SizedBox(height: 50),
            SpinningLettersWidget(),
          ],
        ),
      ),
    );
  }
}
