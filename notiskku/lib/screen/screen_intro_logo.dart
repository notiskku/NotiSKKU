import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenLogoIntro extends StatefulWidget {
  const ScreenLogoIntro({super.key});

  @override
  State<ScreenLogoIntro> createState() => _ScreenLogoIntroState();
}

class _ScreenLogoIntroState extends State<ScreenLogoIntro> {
  @override
  void initState() {
    super.initState();
    // 일정 시간 후에 IntroductionScreen으로 이동
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ScreenIntroOne()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0b5b42),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 195.w,
              child: Image.asset(
                'assets/images/whitelogo_fix.png',
                width: 110.w, // 반응형 너비
                height: 130.h, // 반응형 높이
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              width: 195.w,
              child: Text(
                'NotiSKKU',
                style: TextStyle(
                  fontSize: 44.sp, // 반응형 폰트 크기
                  // height: 1.0, // 줄 간격 최소화 (간격 완전 제거)
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
