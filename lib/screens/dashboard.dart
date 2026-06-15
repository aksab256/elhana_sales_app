import 'package:flutter/material.dart';
import '../auth/login.dart'; // للعودة لصفحة الدخول عند تسجيل الخروج التام

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
    final String employeeName = employeeData['name'] ?? 'موظف مبيعات ميداني';
    final String employeeCode = employeeData['employeeCode'] ?? 'غير متوفر';
    final String role = employeeData['role'] ?? 'salesAgent';
    
    // قراءة الحقول المالية والعمولات والمستهدفات البيعية المباشرة بدون أي اختصارات
    final double baseSalary = (employeeData['baseSalary'] ?? employeeData['base_salary'] ?? 0).toDouble();
    final double dailyWage = (employeeData['dailyWage'] ?? 0).toDouble();
    final double commissionPercentage = (employeeData['commissionPercentage'] ?? 0).toDouble();
    final double monthlyTarget = (employeeData['monthlyTarget'] ?? employeeData['monthly_target'] ?? 0).toDouble();
    final double totalSalesThisMonth = (employeeData['totalSalesThisMonth'] ?? employeeData['total_sales_this_month'] ?? 0).toDouble();
    final double advancesDrawn = (employeeData['advancesDrawn'] ?? employeeData['advances_drawn'] ?? 0).toDouble();

    // حساب معدل تحقيق المستهدف البيعي والمالي (Target Achievement)
    final double achievementProgress = monthlyTarget > 0 ? (totalSalesThisMonth / monthlyTarget) : 0.0;
    final String achievementPercentageStr = (achievementProgress * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // مظهر داكن احترافي للأنظمة البيعية
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            Text('كود المندوب الحركي: $employeeCode', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                CircleAvatar(backgroundColor: Color(0xFF10B981), radius: 4),
                SizedBox(width: 6),
                Text('متصل مباشر', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: Color(0xFFEF4444)),
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const LoginPage(isFirebaseReady: true))
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // شريط قياس ومؤشر تحقيق المستهدف البيعي والمالي (Target Achievement)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
                gradient: LinearGradient(
                  colors: [const Color(0xFF1E293B), const Color(0xFF0F172A).withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'مؤشر تحقيق المستهدف البيعي والمالي للشهر الجاري',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$achievementPercentageStr %',
                        style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: achievementProgress > 1.0 ? 1.0 : achievementProgress,
                      backgroundColor: const Color(0xFF334155),
                      color: const Color(0xFF3B82F6),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniTargetDetail('المبيعات الحالية', '$totalSalesThisMonth ج.م', const Color(0xFF10B981)),
                      _buildMiniTargetDetail('المستهدف البيعي', '$monthlyTarget ج.م', const Color(0xFFF59E0B)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'الخزينة والحسابات المالية الفورية للشاشات الميدانية',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            
            // شبكة الكروت المالية للتدفقات النقدية والمحفظة وعمولات المبيعات لقاعدة البيانات
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width < 700 ? 1 : 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 12,
              childAspectRatio: 4.2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildProfessionalFinancialCard('إجمالي محصلة المبيعات الحالية', '$totalSalesThisMonth ج.م', 'حقل: totalSalesThisMonth', Icons.monetization_on_rounded, const Color(0xFF10B981)),
                _buildProfessionalFinancialCard('السلفيات والمبالغ النقدية المسحوبة', '$advancesDrawn ج.م', 'حقل: advancesDrawn', Icons.money_off_rounded, const Color(0xFFEF4444)),
                _buildProfessionalFinancialCard('الراتب والعهد الأساسية المربوطة', '$baseSalary ج.م', 'حقل: baseSalary', Icons.account_balance_wallet_rounded, const Color(0xFF3B82F6)),
                _buildProfessionalFinancialCard('الراتب اليومي المعتمد للمندوب', '$dailyWage ج.م', 'حقل: dailyWage', Icons.calendar_view_day_rounded, const Color(0xFF64748B)),
                _buildProfessionalFinancialCard('نسبة عمولة التحصيل والبيع الفوري', '$commissionPercentage %', 'حقل: commissionPercentage', Icons.percent_rounded, const Color(0xFFF59E0B)),
                _buildProfessionalFinancialCard('معرف السجل الثابت بالـ Firestore', employeeId, 'المستند الفعلي الفريد للحساب', Icons.fingerprint_rounded, const Color(0xFF8B5CF6)),
              ],
            ),
            const SizedBox(height: 28),

            const Text(
              'العمليات الميدانية والتحصيل المباشر (Sales Buzz Quick Actions)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildActionMenuButton('إصدار فاتورة مبيعات', Icons.add_shopping_cart_rounded, const Color(0xFF3B82F6))),
                const SizedBox(width: 12),
                Expanded(child: _buildActionMenuButton('تحصيل نقدية / سداد', Icons.payments_rounded, const Color(0xFF10B981))),
                const SizedBox(width: 12),
                Expanded(child: _buildActionMenuButton('تسوية عهد ومبيعات', Icons.receipt_long_rounded, const Color(0xFFF59E0B))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTargetDetail(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProfessionalFinancialCard(String title, String value, String dbFieldName, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(dbFieldName, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenuButton(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}