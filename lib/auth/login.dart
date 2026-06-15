import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/dashboard.dart'; // تم تعديل المسار الاحترافي هنا صراحة ليقرأ من مجلد screens

class LoginPage extends StatefulWidget {
  final bool isFirebaseReady;
  const LoginPage({super.key, required this.isFirebaseReady});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleLogin() async {
    if (!widget.isFirebaseReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ: الفايربيس غير متصل حالياً، يرجى التحقق من الاتصال.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final String userInput = _identifierController.text.trim();
    
    try {
      DocumentSnapshot? empDoc;

      final docRef = FirebaseFirestore.instance.collection('employees').doc(userInput);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        empDoc = docSnap;
      } else {
        final querySnap = await FirebaseFirestore.instance
            .collection('employees')
            .where('email', isEqualTo: userInput)
            .limit(1)
            .get();

        if (querySnap.docs.isNotEmpty) {
          empDoc = querySnap.docs.first;
        }
      }

      if (empDoc == null || !empDoc.exists) {
        throw 'عذراً، لم يتم العثور على موظف مسجل بهذه البيانات.';
      }

      final empData = empDoc.data() as Map<String, dynamic>;

      final bool isActive = empData['isActive'] ?? empData['is_active'] ?? false;
      if (!isActive) {
        throw 'هذا الحساب موقوف حالياً، يرجى مراجعة الإدارة.';
      }

      final String role = empData['role'] ?? '';
      
      if (role == 'salesAgent' || role == 'factoryManager') {
        final String employeeName = empData['name'] ?? 'موظف مبيعات';
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('مرحباً بك يا $employeeName. تم تسجيل الدخول بنجاح.'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DriverDashboardPage(
                employeeId: empDoc!.id,
                employeeData: empData,
              ),
            ),
          );
        }
      } else {
        throw 'عذراً، هذا التطبيق مخصص فقط لمندوبي المبيعات وإدارة التشغيل الفني.';
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.insights_rounded, color: Color(0xFF3B82F6), size: 44),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'بوابة المندوب البيعية',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'نظام التتبع المالي والميداني المباشر',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'كود حساب المندوب أو البريد الإلكتروني',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _identifierController,
                    style: const TextStyle(color: Colors.white),
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: 'مثال: Chow6JbswIsSNRAol8T3',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFF64748B), size: 20),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF334155))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال معرف الحساب الصريح الخاص بك.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'كلمة المرور الشخصية',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF64748B), size: 20),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF334155))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور المعتمدة.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'تسجيل الدخول ومزامنة البيانات الميدانية',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}