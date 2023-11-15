// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Uncomment the following lines when enabling Firebase Crashlytics
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/foundation.dart';
// import 'firebase_options.dart';

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:terrapoint/src/game_internals/board_setting.dart';
import 'package:terrapoint/src/game_internals/board_state.dart';
import 'package:terrapoint/src/game_internals/board_tile_model.dart';

import 'src/ads/ads_controller.dart';
import 'src/app_lifecycle/app_lifecycle.dart';
import 'src/audio/audio_controller.dart';
import 'src/games_services/games_services.dart';
import 'src/games_services/score.dart';
import 'src/in_app_purchase/in_app_purchase.dart';
import 'src/level_selection/level_selection_screen.dart';
import 'src/level_selection/levels.dart';
import 'src/main_menu/main_menu_screen.dart';
import 'src/play_session/play_session_screen.dart';
import 'src/player_progress/persistence/local_storage_player_progress_persistence.dart';
import 'src/player_progress/persistence/player_progress_persistence.dart';
import 'src/player_progress/player_progress.dart';
import 'src/settings/persistence/local_storage_settings_persistence.dart';
import 'src/settings/persistence/settings_persistence.dart';
import 'src/settings/settings.dart';
import 'src/settings/settings_screen.dart';
import 'src/style/my_transition.dart';
import 'src/style/palette.dart';
import 'src/style/snack_bar.dart';
import 'src/win_game/win_game_screen.dart';

Future<void> main() async {
  // Subscribe to log messages.
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    dev.inspect(record.message);
    dev.log(
      record.message,
      time: record.time,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });

  WidgetsFlutterBinding.ensureInitialized();

  // TODO: To enable Firebase Crashlytics, uncomment the following line.
  // See the 'Crashlytics' section of the main README.md file for details.

  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   try {
  //     await Firebase.initializeApp(
  //       options: DefaultFirebaseOptions.currentPlatform,
  //     );
  //
  //     FlutterError.onError = (errorDetails) {
  //       FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  //     };
  //
  //     // Pass all uncaught asynchronous errors
  //     // that aren't handled by the Flutter framework to Crashlytics.
  //     PlatformDispatcher.instance.onError = (error, stack) {
  //       FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //       return true;
  //     };
  //   } catch (e) {
  //     debugPrint("Firebase couldn't be initialized: $e");
  //   }
  // }

  _log.info('Going full screen');
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // TODO: When ready, uncomment the following lines to enable integrations.
  //       Read the README for more info on each integration.

  AdsController? adsController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   /// Prepare the google_mobile_ads plugin so that the first ad loads
  //   /// faster. This can be done later or with a delay if startup
  //   /// experience suffers.
  //   adsController = AdsController(MobileAds.instance);
  //   adsController.initialize();
  // }

  GamesServicesController? gamesServicesController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   gamesServicesController = GamesServicesController()
  //     // Attempt to log the player in.
  //     ..initialize();
  // }

  InAppPurchaseController? inAppPurchaseController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   inAppPurchaseController = InAppPurchaseController(InAppPurchase.instance)
  //     // Subscribing to [InAppPurchase.instance.purchaseStream] as soon
  //     // as possible in order not to miss any updates.
  //     ..subscribe();
  //   // Ask the store what the player has bought already.
  //   inAppPurchaseController.restorePurchases();
  // }

  runApp(
    MyApp(
      settingsPersistence: LocalStorageSettingsPersistence(),
      playerProgressPersistence: LocalStoragePlayerProgressPersistence(),
      inAppPurchaseController: inAppPurchaseController,
      adsController: adsController,
      gamesServicesController: gamesServicesController,
    ),
  );
}

Logger _log = Logger('main.dart');

class MyApp extends StatelessWidget {
  final PlayerProgressPersistence playerProgressPersistence;

  final SettingsPersistence settingsPersistence;

  final GamesServicesController? gamesServicesController;

  final InAppPurchaseController? inAppPurchaseController;

  final AdsController? adsController;

  final BoardSetting setting;

  const MyApp({
    this.setting = const BoardSetting(10, 10),
    required this.playerProgressPersistence,
    required this.settingsPersistence,
    required this.inAppPurchaseController,
    required this.adsController,
    required this.gamesServicesController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const MainMenuScreen(key: Key('main menu')),
          routes: [
            GoRoute(
              path: 'play',
              pageBuilder: (context, state) {
                return buildMyTransition<void>(
                  key: ValueKey('play'),
                  child: PlaySessionScreen(
                    setting, // Используйте setting из конструктора
                    key: Key('play session'),
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: 'session/:level',
                  pageBuilder: (context, state) {
                    return buildMyTransition<void>(
                      key: ValueKey('level'),
                      child: PlaySessionScreen(
                        setting, // Используйте setting из конструктора
                        key: const Key('play session'),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'won',
                  redirect: (context, state) {
                    if (state.extra == null) {
                      return '/';
                    }
                    return null;
                  },
                  pageBuilder: (context, state) {
                    final map = state.extra! as Map<String, dynamic>;
                    final score = map['score'] as Score;

                    return buildMyTransition<void>(
                      key: ValueKey('won'),
                      child: WinGameScreen(
                        score: score,
                        key: const Key('win game'),
                      ),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) =>
                  const SettingsScreen(key: Key('settings')),
            ),
          ],
        ),
        // Добавьте другие маршруты по мере необходимости
      ],
    );
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<BoardState>(
            create: (context) {
              return BoardState.clean(setting);
            },
          ),
          ChangeNotifierProvider(
            create: (context) {
              var progress = PlayerProgress(playerProgressPersistence);
              progress.getLatestFromStore();
              return progress;
            },
          ),
          Provider<GamesServicesController?>.value(
              value: gamesServicesController),
          Provider<AdsController?>.value(value: adsController),
          ChangeNotifierProvider<InAppPurchaseController?>.value(
              value: inAppPurchaseController),
          Provider<SettingsController>(
            lazy: false,
            create: (context) => SettingsController(
              persistence: settingsPersistence,
            )..loadStateFromPersistence(),
          ),
          ProxyProvider2<SettingsController, ValueNotifier<AppLifecycleState>,
              AudioController>(
            // Ensures that the AudioController is created on startup,
            // and not "only when it's needed", as is default behavior.
            // This way, music starts immediately.
            lazy: false,
            create: (context) => AudioController()..initialize(),
            update: (context, settings, lifecycleNotifier, audio) {
              if (audio == null) throw ArgumentError.notNull();
              audio.attachSettings(settings);
              audio.attachLifecycleNotifier(lifecycleNotifier);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
          ),
          Provider(
            create: (context) => Palette(),
          ),
        ],
        child: Builder(builder: (context) {
          return MaterialApp.router(
            title: 'Terrapppoint',
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)
                  .copyWith(surface: Colors.pink),
            ),
            routeInformationProvider: _router.routeInformationProvider,
            routeInformationParser: _router.routeInformationParser,
            routerDelegate: _router.routerDelegate,
            scaffoldMessengerKey: scaffoldMessengerKey,
          );
        }),
      ),
    );
  }
}
