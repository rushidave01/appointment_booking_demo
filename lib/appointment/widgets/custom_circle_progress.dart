import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCircleProgress extends StatelessWidget {
  final double percentage;
  final int number;

  const CustomCircleProgress({super.key,
    required this.percentage,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 2,
              ),
            ],
            border:  Border.all(
              color:
              const Color.fromRGBO(0, 226, 0, 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomPaint(
              painter: CircleProgressPainter(
                percentage: percentage,
                progressColor: const Color.fromRGBO(255, 180, 171, 1),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        Text(
          number.toString(),
          style: GoogleFonts.lato(fontWeight: FontWeight.w500,fontSize: 16,color: const Color.fromRGBO(0, 101, 144, 1)),
        ),
      ],
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double percentage;
  final Color progressColor;
  final Color backgroundColor;

  CircleProgressPainter({
    required this.percentage,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint circlePaint = Paint()
      ..color = const Color.fromRGBO(246, 250, 255, 1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double startAngle = -pi / 2;
    double sweepAngle = 2 * pi * percentage;

    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2,
      circlePaint,
    );

    canvas.drawArc(
      Rect.fromCenter(center: size.center(Offset.zero), width: size.width, height: size.height),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
