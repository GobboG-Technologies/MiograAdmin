import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icons ;

  StatsCard({required this.title, required this.count, required this.color, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Fixed height
      width: 270,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icons, color: Colors.white, size: 30),
                Text(title, style: TextStyle(color: Colors.white, fontSize: 35)),
              ],
            ),
            SizedBox(height: 5,),
            Text(count, style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}