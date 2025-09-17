import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanjeevika/view/screens/chat/ai_chat_screen.dart';
import 'package:sanjeevika/view/screens/onboarding/getstarted_screen.dart';
import 'package:sanjeevika/view/screens/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'viewmodels/data_controller.dart';
import 'utils/functions_uses.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  Get.put(Datacontroller());
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: Builder(builder: (context) {
        double measuretxt = MediaQuery.of(context).size.width * 0.95;
        Get.find<Datacontroller>().Setsize(measuretxt);

        return SplashScreen();
      }),
    );
  }
}
