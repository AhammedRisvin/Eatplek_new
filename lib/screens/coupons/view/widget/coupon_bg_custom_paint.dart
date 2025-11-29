import 'package:flutter/material.dart';

// CustomPainter for the wavy divider
class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.1792984, size.height * -0.001457053);
    path_0.cubicTo(
      size.width * 0.1792984,
      size.height * 0.03074612,
      size.width * 0.2054043,
      size.height * 0.05685213,
      size.width * 0.2376074,
      size.height * 0.05685213,
    );
    path_0.cubicTo(
      size.width * 0.2698106,
      size.height * 0.05685213,
      size.width * 0.2959165,
      size.height * 0.03074612,
      size.width * 0.2959165,
      size.height * -0.001457053,
    );
    path_0.lineTo(size.width * 0.3542255, size.height * -0.001457053);
    path_0.cubicTo(
      size.width * 0.3542255,
      size.height * 0.03074612,
      size.width * 0.3803314,
      size.height * 0.05685213,
      size.width * 0.4125346,
      size.height * 0.05685213,
    );
    path_0.cubicTo(
      size.width * 0.4447378,
      size.height * 0.05685213,
      size.width * 0.4708436,
      size.height * 0.03074612,
      size.width * 0.4708436,
      size.height * -0.001457053,
    );
    path_0.lineTo(size.width * 0.5291527, size.height * -0.001457053);
    path_0.cubicTo(
      size.width * 0.5291527,
      size.height * 0.03074612,
      size.width * 0.5552606,
      size.height * 0.05685213,
      size.width * 0.5874628,
      size.height * 0.05685213,
    );
    path_0.cubicTo(
      size.width * 0.6196649,
      size.height * 0.05685213,
      size.width * 0.6457713,
      size.height * 0.03074612,
      size.width * 0.6457713,
      size.height * -0.001457053,
    );
    path_0.lineTo(size.width * 0.7040798, size.height * -0.001457053);
    path_0.cubicTo(
      size.width * 0.7040798,
      size.height * 0.03074612,
      size.width * 0.7301862,
      size.height * 0.05685213,
      size.width * 0.7623883,
      size.height * 0.05685213,
    );
    path_0.cubicTo(
      size.width * 0.7945904,
      size.height * 0.05685213,
      size.width * 0.8206968,
      size.height * 0.03074612,
      size.width * 0.8206968,
      size.height * -0.001457053,
    );
    path_0.lineTo(size.width * 0.9052447, size.height * -0.001457053);
    path_0.cubicTo(
      size.width * 0.9567713,
      size.height * -0.001457053,
      size.width * 0.9985426,
      size.height * 0.04031229,
      size.width * 0.9985426,
      size.height * 0.09183723,
    );
    path_0.lineTo(size.width * 0.9985426, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.9838351, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.9838351, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.9985426, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.9985426, size.height * 0.9052500);
    path_0.cubicTo(
      size.width * 0.9985426,
      size.height * 0.9567713,
      size.width * 0.9567713,
      size.height * 0.9985426,
      size.width * 0.9052447,
      size.height * 0.9985426,
    );
    path_0.lineTo(size.width * 0.09183457, size.height * 0.9985426);
    path_0.cubicTo(
      size.width * 0.04030968,
      size.height * 0.9985426,
      size.width * -0.001459649,
      size.height * 0.9567713,
      size.width * -0.001459649,
      size.height * 0.9052500,
    );
    path_0.lineTo(size.width * -0.001459649, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.01324574, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.01324574, size.height * 0.4941697);
    path_0.lineTo(size.width * -0.001459649, size.height * 0.4941697);
    path_0.lineTo(size.width * -0.001459649, size.height * 0.09183723);
    path_0.cubicTo(
      size.width * -0.001459649,
      size.height * 0.04031229,
      size.width * 0.04030968,
      size.height * -0.001457053,
      size.width * 0.09183457,
      size.height * -0.001457053,
    );
    path_0.lineTo(size.width * 0.1792984, size.height * -0.001457053);
    path_0.close();
    path_0.moveTo(size.width * 0.04265936, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.07207021, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.07207021, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.04265936, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.04265936, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.1014809, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.1308947, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.1308947, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.1014809, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.1014809, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.1603053, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.1897160, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.1897160, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.1603053, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.1603053, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.2191298, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.2485404, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.2485404, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.2191298, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.2191298, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.2779511, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.3073649, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.3073649, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.2779511, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.2779511, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.3367755, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.3661862, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.3661862, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.3367755, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.3367755, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.3956000, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.4250106, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.4250106, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.3956000, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.3956000, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.4544213, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.4838351, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.4838351, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.4544213, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.4544213, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.5132457, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.5426596, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.5426596, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.5132457, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.5132457, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.5720691, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.6014787, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.6014787, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.5720691, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.5720691, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.6308936, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.6603032, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.6603032, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.6308936, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.6308936, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.6897181, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.7191277, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.7191277, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.6897181, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.6897181, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.7485426, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.7779521, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.7779521, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.7485426, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.7485426, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.8073670, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.8367766, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.8367766, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.8073670, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.8073670, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.8661862, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.8956011, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.8956011, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.8661862, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.8661862, size.height * 0.5058314);
    path_0.close();
    path_0.moveTo(size.width * 0.9250106, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.9544202, size.height * 0.5058314);
    path_0.lineTo(size.width * 0.9544202, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.9250106, size.height * 0.4941697);
    path_0.lineTo(size.width * 0.9250106, size.height * 0.5058314);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Color(0xff3CC06F).withOpacity(1.0);
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
