import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/login.dart'; // استدعاء شاشة الدخول المستقلة الجديدة مباشرة من مجلد الـ auth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool isFirebaseReady = false;
  try {
    // محاولة بدء تشغيل الفايربيس المباشر للتحقق من الاتصال وقواعد البيانات
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
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        primaryColor: const Color(0xFF2563EB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      ),
      // توجيه التطبيق لعرض صفحة الدخول المباشرة فوراً مع تمرير حالة الاتصال
      home: LoginPage(isFirebaseReady: isFirebaseReady),
    );
  }
}