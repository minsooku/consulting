import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Signature for a builder that creates the sheet content from serialised
/// [arguments] forwarded by the native presenter.
typedef CNSheetRouteBuilder = Widget Function(Map<String, dynamic> arguments);

/// A minimal Flutter application designed to run inside a **secondary**
/// `FlutterEngine` spawned by the native sheet presenter.
///
/// Place a `@pragma('vm:entry-point')` function in your app (typically
/// `main.dart`) that calls `runApp(CNSheetApp(...))` with a map of named
/// routes.  The native side will tell this app which route + arguments to
/// render once the engine is ready.
///
/// ```dart
/// @pragma('vm:entry-point')
/// void sheetMain() {
///   runApp(CNSheetApp(
///     routes: {
///       'history': (args) => HistorySheetContent(args: args),
///     },
///   ));
/// }
/// ```
class CNSheetApp extends StatefulWidget {
  const CNSheetApp({
    super.key,
    required this.routes,
    this.theme,
    this.darkTheme,
  });

  /// Named route → builder map.
  final Map<String, CNSheetRouteBuilder> routes;

  /// Optional light theme forwarded to [MaterialApp].
  final ThemeData? theme;

  /// Optional dark theme forwarded to [MaterialApp].
  final ThemeData? darkTheme;

  @override
  State<CNSheetApp> createState() => _CNSheetAppState();
}

class _CNSheetAppState extends State<CNSheetApp> {
  static const _channel = MethodChannel('cupertino_native_sheet_content');

  String? _route;
  Map<String, dynamic> _arguments = {};

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleMethod);
    // Signal to the native side that we're ready to receive the route.
    _channel.invokeMethod('ready');
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'setRoute':
        final raw = call.arguments as Map<Object?, Object?>;
        setState(() {
          _route = raw['route'] as String?;
          final rawArgs = raw['arguments'];
          _arguments = rawArgs is Map ? Map<String, dynamic>.from(rawArgs) : {};
        });
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final builder = _route != null ? widget.routes[_route] : null;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: widget.theme,
      darkTheme: widget.darkTheme,
      themeMode: widget.darkTheme != null ? ThemeMode.system : ThemeMode.light,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: builder != null ? builder(_arguments) : const SizedBox.shrink(),
      ),
    );
  }
}
