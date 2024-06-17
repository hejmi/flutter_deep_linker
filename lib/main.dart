import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'url_protocol/api.dart';

const kWindowsScheme = 'sample';

void main() {
  // Register our protocol only on Windows platform
  registerProtocolHandler(kWindowsScheme);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    _navigatorKey.currentState?.pushNamed(uri.fragment);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        Widget routeWidget = defaultScreen();

        // Mimic web routing
        final routeName = settings.name;
        if (routeName != null) {
          if (routeName.startsWith('/booking/')) {
            String bookingId = routeName.replaceAll('/booking/', '');
            routeWidget = customScreen(
              bookingId,
            );
          } else if (routeName == '/booking') {
            // Navigated to /book without other parameters
            routeWidget = customScreen("None");
          }
        }

        return MaterialPageRoute(
          builder: (context) => routeWidget,
          settings: settings,
          fullscreenDialog: true,
        );
      },
    );
  }

  Widget defaultScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Default Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SelectableText(
              '''
            Scan QR to open booking site
            /usr/bin/xcrun simctl openurl booted "granpro://#/booking/room-1"
            ''',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            buildWindowsUnregisterBtn(),
          ],
        ),
      ),
    );
  }

  Widget customScreen(String bookId) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Screen')),
      body: Center(child: Text('Open Booking for: $bookId')),
    );
  }

  Widget buildWindowsUnregisterBtn() {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return TextButton(onPressed: () => unregisterProtocolHandler(kWindowsScheme), child: const Text('Remove Windows protocol registration'));
    }

    return const SizedBox.shrink();
  }
}
