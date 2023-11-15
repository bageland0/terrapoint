// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';
import 'package:terrapoint/src/game_internals/board_setting.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../games_services/games_services.dart';
import '../style/delayed_appear.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../style/confetti.dart';
import '../style/palette.dart';
import 'game_board.dart';

class PlaySessionScreen extends StatefulWidget {
  const PlaySessionScreen(this.setting, {super.key});
  final BoardSetting setting;

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;

  @override
  Widget build(BuildContext context) {
    //final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {}),
      ],
      child: IgnorePointer(
        ignoring: _duringCelebration,
        child: Scaffold(
          //backgroundColor: palette.backgroundPlaySession,
          body: Stack(
            children: [
              _ResponsivePlaySessionScreen(
                mainBoardArea: Center(
                  child: DelayedAppear(
                    ms: ScreenDelays.fourth,
                    delayStateCreation: true,
                    onDelayFinished: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.swishSwish);
                    },
                    child: Board(
                      setting: widget.setting,
                      key: const Key('main board'),
                    ),
                  ),
                ),
                //restartButtonArea: _RestartButton(
                //  _resetHint.stream,
                //  onTap: () {
                //    final audioController = context.read<AudioController>();
                //    audioController.playSfx(SfxType.buttonTap);

                //    context.read<BoardState>().clearBoard();
                //    _startOfPlay = DateTime.now();

                //    Future.delayed(const Duration(milliseconds: 200)).then((_) {
                //      if (!mounted) return;
                //      context.read<BoardState>().initialize();
                //    });

                //    Future.delayed(const Duration(milliseconds: 1000))
                //        .then((_) {
                //      if (!mounted) return;
                //      showHintSnackbar(context);
                //    });
                //  },
                //),
                backButtonArea: DelayedAppear(
                  ms: ScreenDelays.first,
                  child: InkResponse(
                    onTap: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.buttonTap);

                      GoRouter.of(context).pop();
                    },
                    child: Tooltip(
                      message: 'Back',
                      child: Image.asset('assets/images/back.png'),
                    ),
                  ),
                ),
                settingsButtonArea: DelayedAppear(
                  ms: ScreenDelays.third,
                  child: InkResponse(
                    onTap: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.buttonTap);

                      GoRouter.of(context).push('/settings');
                    },
                    child: Tooltip(
                      message: 'Settings',
                      child: Image.asset('assets/images/settings.png'),
                    ),
                  ),
                ),
              ),
              Center(
                // This is the entirety of the "game".
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkResponse(
                        onTap: () => GoRouter.of(context).push('/settings'),
                        child: Image.asset(
                          'assets/images/settings.png',
                          semanticLabel: 'Settings',
                        ),
                      ),
                    ),
                    const Spacer(),
                    //Text('Drag the slider to ${widget.level.difficulty}%'
                    //    ' or above!'),
                    //Consumer<LevelState>(
                    //  builder: (context, levelState, child) => Slider(
                    //    label: 'Level Progress',
                    //    autofocus: true,
                    //    value: levelState.progress / 100,
                    //    onChanged: (value) =>
                    //        levelState.setProgress((value * 100).round()),
                    //    onChangeEnd: (value) => levelState.evaluate(),
                    //  ),
                    //),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => GoRouter.of(context).go('/'),
                          child: const Text('Back'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox.expand(
                child: Visibility(
                  visible: _duringCelebration,
                  child: IgnorePointer(
                    child: Confetti(
                      isStopped: !_duringCelebration,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();

    // Preload ad for the win screen.
    final adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      final adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }
  }
}

class _ResponsivePlaySessionScreen extends StatelessWidget {
  /// This is the "hero" of the screen. It's more or less square, and will
  /// be placed in the visual "center" of the screen.
  final Widget mainBoardArea;

  final Widget backButtonArea;

  final Widget settingsButtonArea;

  //final Widget restartButtonArea;

  /// How much bigger should the [mainBoardArea] be compared to the other
  /// elements.
  final double mainAreaProminence;

  const _ResponsivePlaySessionScreen({
    required this.mainBoardArea,
    required this.backButtonArea,
    required this.settingsButtonArea,
    //required this.restartButtonArea,
    // ignore: unused_element
    this.mainAreaProminence = 0.8,
    Key? key,
  }) : super(key: key);

  Widget _buildVersusText(BuildContext context, TextAlign textAlign) {
    String versusText;
    switch (textAlign) {
      case TextAlign.start:
      case TextAlign.left:
      case TextAlign.right:
      case TextAlign.end:
        versusText = '\nversus\n';
        break;
      case TextAlign.center:
      case TextAlign.justify:
        versusText = ' versus ';
        break;
    }

    return DelayedAppear(
      ms: ScreenDelays.second,
      child: RichText(
          textAlign: textAlign,
          text: TextSpan(
            children: [
              TextSpan(
                text: versusText,
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(fontFamily: 'Permanent Marker', fontSize: 18),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // This widget wants to fill the whole screen.
        final size = constraints.biggest;
        final padding = EdgeInsets.all(size.shortestSide / 30);

        if (size.height >= size.width) {
          // "Portrait" / "mobile" mode.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: padding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 45,
                        child: backButtonArea,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 5,
                          ),
                          child: _buildVersusText(context, TextAlign.center),
                        ),
                      ),
                      SizedBox(
                        width: 45,
                        child: settingsButtonArea,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: (mainAreaProminence * 100).round(),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  minimum: padding,
                  child: mainBoardArea,
                ),
              ),
              SafeArea(
                top: false,
                maintainBottomViewPadding: true,
                child: Padding(
                  padding: padding,
                  //child: restartButtonArea,
                ),
              ),
            ],
          );
        } else {
          // "Landscape" / "tablet" mode.
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: SafeArea(
                  right: false,
                  maintainBottomViewPadding: true,
                  child: Padding(
                    padding: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        backButtonArea,
                        Expanded(
                          child: _buildVersusText(context, TextAlign.start),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: SafeArea(
                  left: false,
                  right: false,
                  maintainBottomViewPadding: true,
                  minimum: padding,
                  child: mainBoardArea,
                ),
              ),
              Expanded(
                flex: 3,
                child: SafeArea(
                  left: false,
                  maintainBottomViewPadding: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: padding,
                        child: settingsButtonArea,
                      ),
                      const Spacer(),
                      Padding(
                        padding: padding,
                        //child: restartButtonArea,
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
