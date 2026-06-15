import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          content: Text('خطأ: الفايربيس غير متصل حالياً، يرجى التحقق من الملفات والاتصال أولاً.'),
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

      // 1. البحث الصريح عن طريق كود المستند (Document ID)
      final docRef = FirebaseFirestore.instance.collection('employees').doc(userInput);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        empDoc = docSnap;
      } else {
        // 2. البحث عبر البريد الإلكتروني (email) كبديل مرن
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
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF2563EB), size: 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'تسجيل دخول المندوب',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'أدخل كود الحساب الصريح للوصول إلى المحفظة والمبيعات',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center, // تم تعديلها هنا وإصلاح الخطأ تماماً
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  const Text(
                    'كود الحساب أو البريد الإلكتروني',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _identifierController,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: 'مثال: Chow6JbswIsSNRAol8T3',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.account_box_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال كود الحساب أو البريد الإلكتروني المعتمد.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'كلمة المرور الشخصية',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور الخاصة بك.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'تسجيل الدخول وعرض حساب المحفظة',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isFirebaseReady ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                        color: widget.isFirebaseReady ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.isFirebaseReady ? "اتصال الفايربيس نشط ومستقر" : "الفايربيس غير متصل",
                        style: TextStyle(fontSize: 11, color: widget.isFirebaseReady ? Colors.green[700] : Colors.red[700]),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DriverDashboardPage extends StatelessWidget {
  final String employeeId;
  final Map<String, dynamic> employeeData;

  const DriverDashboardPage({
    super.key,
    required this.employeeId,
    required this.employeeData,
  });

  @override
  Widget build(BuildContext context) {
    final String employeeName = employeeData['name'] ?? 'موظف مبيعات';
    final String employeeCode = employeeData['employeeCode'] ?? 'غير متوفر';
    final String role = employeeData['role'] ?? 'salesAgent';
    
    final double baseSalary = (employeeData['baseSalary'] ?? employeeData['base_salary'] ?? 0).toDouble();
    final double dailyWage = (employeeData['dailyWage'] ?? 0).toDouble();
    final double commissionPercentage = (employeeData['commissionPercentage'] ?? 0).toDouble();
    final double monthlyTarget = (employeeData['monthlyTarget'] ?? employeeData['monthly_target'] ?? 0).toDouble();
    final double totalSalesThisMonth = (employeeData['totalSalesThisMonth'] ?? employeeData['total_sales_this_month'] ?? 0).toDouble();
    final double advancesDrawn = (employeeData['advancesDrawn'] ?? employeeData['advances_drawn'] ?? 0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة والحسابات المالية المباشرة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const LoginPage(isFirebaseReady: true))
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employeeName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'كود الموظف: $employeeCode',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                        Text(
                          'Document ID: $employeeId',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        role == 'salesAgent' ? 'مندوب مبيعات' : 'مدير تشغيل',
                        style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'كافة تفاصيل حقول السجل المالي الصريح لقاعدة البيانات:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width < 800 ? 1 : 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 12,
                childAspectRatio: 4.5,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFinancialRowItem('إجمالي مبيعات الشهر (totalSalesThisMonth)', '$totalSalesThisMonth ج.م', Icons.trending_up_rounded, const Color(0xFF10B981)),
                  _buildFinancialRowItem('السلفيات والمبالغ المسحوبة (advancesDrawn)', '$advancesDrawn ج.م', Icons.money_off_rounded, const Color(0xFFEF4444)),
                  _buildFinancialRowItem('المرتب الأساسي الثابت (baseSalary)', '$baseSalary ج.م', Icons.account_balance_wallet_rounded, const Color(0xFF2563EB)),
                  _buildFinancialRowItem('الأجر اليومي المعتمد (dailyWage)', '$dailyWage ج.م', Icons.calendar_view_day_rounded, const Color(0xFF475569)),
                  _buildFinancialRowItem('نسبة عمولة المبيعات (commissionPercentage)', '$commissionPercentage %', Icons.percent_rounded, const Color(0xFFF59E0B)),
                  _buildFinancialRowItem('المستهدف المالي المطلوب (monthlyTarget)', '$monthlyTarget ج.م', Icons.track_changes_rounded, const Color(0xFF8B5CF6)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialRowItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}