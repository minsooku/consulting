import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'package:consulting_fe/api/auth_service.dart';
import 'package:consulting_fe/api/engine_flags.dart';
import 'package:consulting_fe/api/models/location_model.dart';
import 'package:consulting_fe/api/navigator_key.dart';
import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/components/sheet_app.dart';
import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/components/sheet_content.dart';
import 'package:consulting_fe/components/others/lock_screen_preview.dart';
import 'package:consulting_fe/components/platform/platform_sheet.dart';
import 'package:consulting_fe/const/app_theme.dart';
import 'package:consulting_fe/pages/homepage.dart';
import 'package:consulting_fe/pages/sheets/address_picker_content.dart';
import 'package:consulting_fe/pages/sheets/address_search_content.dart';
import 'package:consulting_fe/pages/sheets/alarm_sound_content.dart';
import 'package:consulting_fe/pages/sheets/background_picker_content.dart';
import 'package:consulting_fe/pages/sheets/barcode_mission_content.dart';
import 'package:consulting_fe/pages/sheets/clock_position_content.dart';
import 'package:consulting_fe/pages/sheets/clock_style_content.dart';
import 'package:consulting_fe/pages/sheets/history_sheet_content.dart';
import 'package:consulting_fe/pages/sheets/math_mission_content.dart';
import 'package:consulting_fe/pages/sheets/mission_picker_content.dart';
import 'package:consulting_fe/pages/sheets/photo_mission_content.dart';
import 'package:consulting_fe/pages/sheets/shake_mission_content.dart';
import 'package:consulting_fe/pages/sheets/transport_mode_content.dart';
import 'package:consulting_fe/pages/sheets/value_input_content.dart';
import 'package:consulting_fe/provider/auth_provider.dart';
import 'package:consulting_fe/provider/fitness_provider.dart';
import 'package:consulting_fe/provider/profile_provider.dart';

@pragma('vm:entry-point')
void sheetMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.loadFromStorage();
  runApp(
    CNSheetApp(
      theme: AppTheme.light,
      routes: {
        'history': (args) => const HistorySheetContent(),
        'alarmSound': (args) => AlarmSoundSheetContent(
          current: args['current'] as String? ?? 'Radar',
          onResult: (sound) => CNSheetContent.close(sound),
        ),
        'clockPosition': (args) => ClockPositionContent(
          current: ClockPosition.values.firstWhere(
            (p) => p.name == (args['current'] as String? ?? 'center'),
            orElse: () => ClockPosition.center,
          ),
          onResult: (pos) => CNSheetContent.close(pos?.name),
        ),
        'addressSearch': (args) => AddressSearchSheetContent(
          initialQuery: args['initialQuery'] as String?,
          showLabelStep: args['showLabelStep'] as bool? ?? false,
          onResult: (suggestion) => CNSheetContent.close(suggestion?.toJson()),
        ),
        'transportMode': (args) => TransportModeContent(
          current: args['current'] as String? ?? 'car',
          onResult: (mode) => CNSheetContent.close(mode),
        ),
        'addressPicker': (args) {
          final rawLocations = args['savedLocations'] as List?;
          final locations =
              rawLocations
                  ?.map(
                    (e) => LocationModel.fromJson(
                      Map<String, dynamic>.from(e as Map),
                    ),
                  )
                  .toList() ??
              [];
          return AddressPickerContent(
            savedLocations: locations,
            currentLabel: args['currentLabel'] as String? ?? '',
            showLabelStep: args['showLabelStep'] as bool? ?? true,
            onResult: (suggestion) => CNSheetContent.close(suggestion?.toJson()),
          );
        },
        'mathMission': (args) =>
            MathMissionContent(onResult: (_) => CNSheetContent.close(null)),
        'shakeMission': (args) =>
            ShakeMissionContent(onResult: (_) => CNSheetContent.close(null)),
        'barcodeMission': (args) =>
            BarcodeMissionContent(onResult: (_) => CNSheetContent.close(null)),
        'photoMission': (args) =>
            PhotoMissionContent(onResult: (_) => CNSheetContent.close(null)),
        'missionPicker': (args) => const MissionPickerContent(),
        'backgroundPicker': (args) => BackgroundPickerContent(
          currentPresetId: args['currentPresetId'] as int?,
        ),
        'clockStyle': (args) => ClockStyleContent(
          current: ClockStyle.values.firstWhere(
            (s) => s.name == (args['current'] as String? ?? 'thin'),
            orElse: () => ClockStyle.thin,
          ),
        ),
        'valueInput': (args) => ValueInputContent(
          initialValue: args['initialValue'] as String? ?? '',
          label: args['label'] as String?,
          hint: args['hint'] as String?,
          isReady: args['isReady'] as bool? ?? false,
          isPlainText: args['isPlainText'] as bool? ?? false,
          onResult: (v) => CNSheetContent.close(v),
        ),
      },
    ),
  );
}

void main() async {
  isMainFlutterEngine = true;
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => FitnessProvider()),
      ],
      child: MaterialApp(
        navigatorKey: globalNavigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AppInit(),
      ),
    );
  }
}

class _AppInit extends StatefulWidget {
  const _AppInit();

  @override
  State<_AppInit> createState() => _AppInitState();
}

class _AppInitState extends State<_AppInit> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    PlatformSheet.warmUp();
    await context.read<AuthProvider>().initWithDevice();
    if (!mounted) return;
    // Load cached plan; fall back to mock data if nothing is saved.
    final fp = context.read<FitnessProvider>();
    await fp.loadFromCache();
    if (!fp.hasPlan) fp.loadMock();
    FlutterNativeSplash.remove();
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold(body: SizedBox.shrink());
    return const HomePage();
  }
}
