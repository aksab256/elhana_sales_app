import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool isFirebaseReady = false;
  try {
    // محاولة بدء تشغيل الفايربيس للتحقق من الملفات
    await Firebase.initializeApp();
    isFirebaseReady = true;
  } catch (e) {
    debugPrint("Firebase Init Error: $e");
  }

  runApp(MyApp(isFirebaseReady: isFirebaseReady));
}

class MyApp extends StatelessWidget {
  final bool isFirebaseReady;
  const MyApp({super.key, required this.isFirebaseReady});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elhana Sales App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('فحص اتصال الفايربيس'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFirebaseReady ? Icons.check_circle : Icons.error,
                color: isFirebaseReady ? Colors.green : Colors.red,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                isFirebaseReady 
                    ? "تم الاتصال بـ Firebase بنجاح! 🚀" 
                    : "فشل الاتصال.. تأكد من الإعدادات ❌",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Package: com.elhana_sales",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}