import 'package:flutter/material.dart';

void main (){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hi mr.john'),
          backgroundColor: Colors.blue,
        ),
                body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // จัดให้อยู่กึ่งกลางแนวตั้ง
            children: [
              const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16), // ตัวเว้นระยะห่างความสูง 16px
              const Text(
                'hello naja',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'ยินดีที่ได้รู้จัก Flutter',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  print('ปุ่มถูกกดแล้ว!');
                },
                child: const Text('กดตรงนี้เลย'),
              ),
            ],
          ),
        ),

      ),
    );
  }
}