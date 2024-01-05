import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'home.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  final String termsText = '''
   الشروط والاحكام 

لا تقم بتحويل اي مبالغ مالية لاي جهة مجهولة 
لا تستقبل اي مبالغ مالية مجهولة المصدر 
هذا الموقع / التطبيق يعمل وفق قوانين المملكة العربية السعودية
ممنوع دخول المسوقين او المكاتب غير المرخصة وغير النضامية 
ادارة التطبيق / الموقع غير مسؤل عن سوء الاستخدام
ممنوع ادراج اي روابط او علامات او اشارات احتيالية 
في حال مخالفة الشروط يحق لادارة التطبيق /الموقع حظر المستخدم وحذف حساباته ومتابعة مع الجهات القانونية 
ممنوع ادراج اي محتوى غير قانوني او غير اخلاقي 
يحق لادارة التطبيق / الموقع الجوء لقوانين المملكة العربية السعودية لمقاضات المخالفين لقوانين الموقع 

اخي المستخدم 

البرنامج موجه للمواطنين . ممنوع المكاتب المسوقين 
في حال وجدت احدهم اخبرنا على 
واتساب /0557346096
    ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
        leading:  IconButton(onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
            icon: Icon(MdiIcons.arrowLeft)
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Text(

              termsText,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black87,
                letterSpacing: 0.5,
                height: 1.5,

              ),
            ),
          ),
        ),
      ),
    );
  }
}