import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:pumpkin_nightmare/game/components/npc/animals.dart';
import 'package:pumpkin_nightmare/audio_manager/audio_manager.dart';
import 'package:pumpkin_nightmare/environment/background.dart';
import 'package:pumpkin_nightmare/game/components/npc/enemy.dart';
import 'package:pumpkin_nightmare/environment/ground.dart';
import 'package:pumpkin_nightmare/main.dart';
import 'package:pumpkin_nightmare/game/components/player.dart';
import 'package:pumpkin_nightmare/ui/ui.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MainGame extends FlameGame with TapCallbacks, PanDetector, HasCollisionDetection
{
  AudioManager audioManager = AudioManager();
  
  bool isPaused = false;

  bool isFirstLaunch = true;
  bool isStart = false;
  bool isPlayerReady = false;
  Player player = Player();
  HealthIndicator healthIndicator = HealthIndicator();
  ManualKit manualKit = ManualKit();

  Score score = Score();
  StartButton startButton = StartButton();
  PauseButton pauseButton = PauseButton();
  RestartButton restartButton = RestartButton();
  MenuButton menuButton = MenuButton();
  double groundSpeed = 300;
  int lastIntScore = 0;
  bool isInitLaunch = true;

  PositionComponent flyEnemy()
  {
    return  groundSpeed < 500 ? BatEnemy() : (Random().nextBool() ? BatEnemy() : Skull());
  }

  late SpawnComponent enemySpawn;
  SpawnComponent ratSpawn = SpawnComponent.periodRange(minPeriod: 0.1, maxPeriod: 10, factory: (amount) {
      return Rat();
    },
    selfPositioning: true,
    autoStart: true,
  );

  SpawnComponent ravenSpawn = SpawnComponent.periodRange(minPeriod: 1, maxPeriod: 2, factory: (amount) {
      return Raven();
    },
    selfPositioning: true,
    autoStart: true,
  );

  void loadManual()
  {
    if(isInitLaunch)
    {
      camera.viewport.add(manualKit);
    }
    else
    {
      audioManager.backgroundFadeInLoad();
    }
  }

  void hideManual() async
  {
    if(isInitLaunch)
    {
      isInitLaunch = false;
      final storage = await SharedPreferences.getInstance();
      storage.setBool("initLaunch", isInitLaunch);
      manualKit.removeFromParent();
      startGame();
    }
  }

  void firstLaunch()
  {
    isGameStart.value = false;
    isFirstLaunch = true;
    player.removeFromParent();
    player = Player();
    add(player);
    camera.viewport.add(startButton);
    healthIndicator.updateHealth();
    score.setScore(0);
  }

  void startGame()
  {
    isGameStart.value = true;
    loadManual();
    if (!isStart && !isInitLaunch) {
      isStart = true;
      add(enemySpawn);
      camera.viewport.add(pauseButton);
      camera.viewport.add(healthIndicator);

      if(isFirstLaunch)
      {
        isFirstLaunch = false;
      }
      else
      {
        player.removeFromParent();
        player = Player();
        add(player);
        score.setScore(0);
        healthIndicator.updateHealth();
        groundSpeed = 300;
      }
    }
  }

  void endGame() async
  {
    groundSpeed = 300;
    audioManager.backgroundFadeOut();
    audioManager.dieSoundPlay();
    double maxScore = await score.getMaxScore();
    if(score.getScore() > maxScore)
    {
      score.setMaxScore(score.getScore());
    }
    isStart = false;
    enemySpawn.removeFromParent();
    startButton.removeFromParent();
    pauseButton.removeFromParent();
    healthIndicator.removeFromParent();
    camera.viewport.add(restartButton);
    camera.viewport.add(menuButton);
  }

  void pauseGame()
  {
    isPaused = true;
    audioManager.stopAudio();
    pauseEngine();
  }

  void resumeGame()
  {
    isPaused = false;
    audioManager.resumeAudio();
    resumeEngine();
  }

  @override
  Future<void> onLoad() async {
    await audioManager.init();

    final storage = await SharedPreferences.getInstance();
    isInitLaunch = storage.getBool("initLaunch") ?? true;
    languageCode.value = storage.getString("language_code") ?? "ru";

    enemySpawn = SpawnComponent.periodRange(minPeriod: 1, maxPeriod: 2, factory: (amount) {
        return Random().nextBool() ? flyEnemy() : Ghost();
      },
      selfPositioning: true,
      autoStart: true,
    );


    for(int i = 6; i > 0; i--)
    {
      add(Background(z_index: -i));
    }
    add(Rain());
    add(player);
    add(Ground(Vector2(0, size.y - 32), Vector2(size.x * 2, 32)));
    add(ratSpawn);
    add(ravenSpawn);
    
    camera.viewport.add(startButton);
    camera.viewport.add(score);
  }

  @override
  void onTapDown(TapDownEvent event) {

    if(isStart && !isPaused)
    {
      if(event.devicePosition.x >= size.x/2)
      {
        player.jump();
      }
      else
      {
        player.isSquat = true;
        player.squat();
      }
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if(event.devicePosition.x < size.x/2 && isStart)
    {
      player.isSquat = false;
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    if(info.eventPosition.global.x < size.x/2 && isStart)
    {
      player.isSquat = true;
      player.squat();
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if(isStart){
      player.isSquat = false;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    int integerScore = score.getScore().floor();
    if(groundSpeed == 300)
    {
      if(integerScore != lastIntScore && integerScore % 100 == 0 && score.getScore() != 0 && groundSpeed < 800)
      {
        lastIntScore = integerScore;
        groundSpeed += 100;
        player.animations![CharacterState.runing]!.stepTime = (0.09 * 300) / groundSpeed;
        player.animations![CharacterState.squat]!.stepTime = (0.08 * 300) / groundSpeed;
      }
    }
    else
    {
      if(integerScore != lastIntScore && integerScore % 700 == 0 && score.getScore() != 0 && groundSpeed < 800)
      {
        lastIntScore = integerScore;
        groundSpeed += 100;
        player.animations![CharacterState.runing]!.stepTime = (0.09 * 300) / groundSpeed;
        player.animations![CharacterState.squat]!.stepTime = (0.08 * 300) / groundSpeed;
      }
    }
  }

}