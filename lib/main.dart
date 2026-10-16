import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return const MaterialApp(
      home: GreetingPage(),
    );
  }
}
// สร้างหน้าจอแบบ StatefulWidget (หน้าจอที่จดจำค่าและเปลี่ยนแปลงได้)
class GreetingPage extends StatefulWidget {
  const GreetingPage({super.key});

  @override
  State<GreetingPage> createState() => _GreetingPageState();
}

class _GreetingPageState extends State<GreetingPage>{
  final TextEditingController _nameController = TextEditingController();

  String _greetingMessage = 'Please enter y0urName';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('goddam bro'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,children:[
             // แสดงข้อความทักทาย
            Text(
              _greetingMessage,style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold,color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),//กรอบ สี่เหลี่ยมรอบช่องพิมพ์
                labelText: 'Enter your name', // ข้อความที่แสดงในช่องพิมพ์
                hintText: 'eg. John Doe', // ข้อความแนะนำในช่องพิมพ์
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            // ปุ่มกดส่งข้อมูล
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('say hello'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: (){
                //เมื่อกดปุ่ม ให้ดึงข้อความจาก controller แล้วสั่ง setState
                setState((){
                  if (_nameController.text.isNotEmpty){
                    _greetingMessage = 'nice to meet you na ${_nameController.text}!';
                  } else{
                    _greetingMessage = 'plase enter your name na';
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}