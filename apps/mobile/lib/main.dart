import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mquiz/app/app.dart';
import 'package:mquiz/core/ads/ad_service.dart';
import 'package:mquiz/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize AdMob SDK before any ads are requested.
  await MobileAds.instance.initialize();
  AdService.instance.initialize();

  runApp(const MquizApp());
}
