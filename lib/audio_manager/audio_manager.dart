import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioManager with WidgetsBindingObserver{
  bool isBackgroundPlaying = false;

  final sfx_jump = AudioPlayer();
  final sfx_fall = AudioPlayer();
  final sfx_hurt = AudioPlayer();
  final sfx_die = AudioPlayer();
  final background_player = AudioPlayer();
  final rain_player = AudioPlayer();
  bool isFallToggle = true;

 Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);

    await background_player.setAsset('assets/audio/run_background.ogg');
    await background_player.setLoopMode(LoopMode.one);
    rain_player.seek(Duration.zero);
    background_player.setVolume(0);

    await rain_player.setAsset('assets/audio/rain.ogg');;
    await rain_player.setLoopMode(LoopMode.one);
    rain_player.seek(Duration.zero);
    rain_player.setVolume(0.2);
    rain_player.play();

    await  sfx_jump.setAsset('assets/audio/jump.ogg');
    sfx_jump.setVolume(0.3);
    await sfx_fall.setAsset('assets/audio/fall.ogg');
    await  sfx_hurt.setAsset('assets/audio/hurt.ogg');
    await sfx_die.setAsset('assets/audio/die.ogg');

    sfx_die.setVolume(0.7);

  }

  void backgroundFadeInLoad() async {
    isBackgroundPlaying = true;
    background_player.seek(Duration.zero);
    background_player.play();
    for(double i = 0; i <= 1; i += 0.05)
    {
      background_player.setVolume(i);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  void backgroundFadeOut() async {
    isBackgroundPlaying = false;
    for(double i = 1; i > 0; i -= 0.05)
    {
      background_player.setVolume(i);
      await Future.delayed(Duration(milliseconds: 100));
    }

    background_player.stop();
  }

  void jumpSoundPlay()
  {
    isFallToggle = false;
    sfx_jump.seek(Duration.zero);
    sfx_jump.play();
  }

  void fallSoundPlay()
  {
    if(!isFallToggle)
    {
      sfx_fall.seek(Duration.zero);
      sfx_fall.play();
      isFallToggle = true;
    }
    
  }

  void hurtSoundPlay()
  {
    sfx_hurt.seek(Duration(milliseconds: 30));
    sfx_hurt.play();
  }

  void dieSoundPlay()
  {
    sfx_die.seek(Duration.zero);
    sfx_die.play();
  }

  void stopAudio()
  {
    background_player.stop();
    rain_player.stop();
    sfx_die.stop();
    sfx_hurt.stop();
    sfx_jump.stop();
    sfx_fall.stop();
  }

  void resumeAudio()
  {
    if(isBackgroundPlaying)
    {
      background_player.play();
    }

    rain_player.play();
  }

    @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Отслеживаем состояние приложения
    switch (state) {
      case AppLifecycleState.paused:
          stopAudio();
        break;
      case AppLifecycleState.resumed:
        log("pipiska");
        resumeAudio();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        background_player.stop();
        rain_player.stop();
        break;
      default:
        break;
    }
  }
}
