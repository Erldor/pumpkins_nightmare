import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:pumpkin_nightmare/game/game.dart';
import 'package:pumpkin_nightmare/l10n/app_localizations.dart';
import "package:shared_preferences/shared_preferences.dart";

class HalfScreen extends RectangleComponent with HasGameReference<MainGame>, TapCallbacks
{
  HalfScreen();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.size.x/2, game.size.y);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.hideManual();
  }
}

class ManualKit extends RectangleComponent with HasGameReference<MainGame>, TapCallbacks
{
  TextComponent recText(String inputText)
  {
    final TextStyle textStyle = TextStyle(
      fontSize: 24,           
      color: const Color.fromARGB(255, 0, 0, 0),
      fontFamily: 'Roboto-Bold',    
      fontWeight: FontWeight.w700,
    );

    final textPaint = TextPaint(style: textStyle,);

    return TextComponent(text: inputText,  position: Vector2(25, game.size.y/2 - 120), textRenderer: textPaint);
  }

  HalfScreen leftRec = HalfScreen();
  HalfScreen rightRec = HalfScreen();


  ManualKit();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    leftRec.size = Vector2(game.size.x/2, game.size.y);
    leftRec.paint =  Paint()..color = const Color.fromARGB(95, 255, 52, 38);
    leftRec.add(recText(AppLocalizations.of(game.buildContext!)!.left_text));

    rightRec.position = Vector2(game.size.x/2, 0);
    rightRec.paint =  Paint()..color = const Color.fromARGB(95, 19, 141, 242);
    rightRec.add(recText(AppLocalizations.of(game.buildContext!)!.right_text));

    add(rightRec);
    add(leftRec);
  }

}

abstract class ButtonUI extends  SpriteButtonComponent with HasGameReference<MainGame>
{
  final String buttonAsset;
  final double scaleFactor;

  ButtonUI({required this.buttonAsset, this.scaleFactor = 3});

  @override
  Future<void> onLoad() async{
    Sprite buttonSprite = Sprite(await game.images.load(buttonAsset));
    anchor = Anchor.center;
    button = buttonSprite; 
    buttonDown = buttonSprite;
    size = Vector2(24, 23);
    scale = Vector2.all(scaleFactor);
  }

}

class StartButton extends ButtonUI{
  StartButton() : super(buttonAsset: "start_button.png");

  @override
  Future<void> onLoad() {
    position = Vector2(game.size.x/2, (game.size.y/2)); 
    onPressed = (){game.startGame();};
    return super.onLoad();
  }

    @override
  void update(double dt) {
    super.update(dt);

    if(game.isStart)
    {
      removeFromParent();
    }
  }
}

class MenuButton extends ButtonUI{
  MenuButton() : super(buttonAsset: "menu_button.png");

    @override
  Future<void> onLoad() {
    position = Vector2(game.size.x/2, (game.size.y/2) + 80); 
    onPressed = (){game.firstLaunch();};
    return super.onLoad();
  }

    @override
  void update(double dt) {
    super.update(dt);

    if(game.isStart || game.isFirstLaunch)
    {
      removeFromParent();
    }
  }
}

class RestartButton extends ButtonUI{
  RestartButton() : super(buttonAsset: "restart_button.png");

    @override
  Future<void> onLoad() {
    position = Vector2(game.size.x/2, (game.size.y/2)); 
    onPressed = (){game.startGame();};
    return super.onLoad();
  }

    @override
  void update(double dt) {
    super.update(dt);

    if(game.isStart)
    {
      removeFromParent();
    }
  }
}

class PauseButton extends ButtonUI{
  PauseButton() : super(buttonAsset: "pause_button.png", scaleFactor: 2);

  @override
  Future<void> onLoad() {
    position = Vector2(game.size.x/2, 30); 
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    onPressed = (){
      if(!game.isPaused)
      {
        game.pauseGame();
      }
      else
      {
        game.resumeGame();
      }

    };
  }
}

class Score extends TextComponent with HasGameReference<MainGame>
{
  double _score = 0;
  double _max_score = 0;

  double getScore()
  {
    return _score;
  }

  Future<void> setMaxScore(double input) async
  {
    final storage = await SharedPreferences.getInstance();
    storage.setDouble("max_score", input);
    _max_score = input;
  }

  Future<double> getMaxScore() async
  {
    final storage = await SharedPreferences.getInstance();
    return storage.getDouble("max_score") ?? 0;
  }

  void setScore(double value)
  {
    _score = value;
  }

  Score() : super(position: Vector2(40, 10));

  final TextStyle textStyle = TextStyle(
    fontSize: 24,           
    color: const Color.fromARGB(255, 156, 64, 7),
    fontFamily: 'Roboto-Bold',    
    fontWeight: FontWeight.w700,
  );

  final textPaint = TextPaint();

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    textRenderer = TextPaint(style: textStyle);
    _max_score = await getMaxScore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if(game.isStart)
    {
      _score += 10 * (game.groundSpeed/250) * dt;
      text = "${AppLocalizations.of(game.buildContext!)!.score}${_score.toStringAsFixed(0)}"; 
    }
    else if(!game.isStart && game.isFirstLaunch)
    {
      text = "${AppLocalizations.of(game.buildContext!)!.max_score}${_max_score.toStringAsFixed(0)}";
    }

  }
}

class HealthIndicator extends PositionComponent with HasGameReference<MainGame>
{
  int heartsCount = 3;
  int currentHearts = 3;

  final double heartSize = 16;
  final List<SpriteComponent> heartComponent = List.generate(3, (_) => SpriteComponent());
  final List<SpriteComponent> greyHeartComponent = List.generate(3, (_) => SpriteComponent());

  HealthIndicator();

  void increaseHealth()
  {
    if(currentHearts < 3)
    {
      heartComponent[currentHearts].opacity = 1;
      currentHearts++;
    }
  }

  void decreaseHealth()
  {
    if(currentHearts > 0)
    {
      heartComponent[currentHearts - 1].opacity = 0;
      currentHearts--;
      if(currentHearts == 0)
      {
        game.endGame();
      }
    }
  }

  void updateHealth()
  {
    currentHearts = 3;
    for(int i = 0; i < currentHearts; i++)
    {
      heartComponent[i].opacity = 1;
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    for(int i = 0; i < heartsCount; i++)
    {
      heartComponent[i].sprite = await game.loadSprite("heart.png");
      heartComponent[i].size = Vector2.all(heartSize);
      heartComponent[i].position = Vector2(game.size.x - ((i * heartSize) + 64), 0);
      heartComponent[i].scale = Vector2.all(3);

      greyHeartComponent[i].sprite = await game.loadSprite("heart_grey.png");
      greyHeartComponent[i].size = Vector2.all(heartSize);
      greyHeartComponent[i].position = Vector2(game.size.x -((i * heartSize) + 64), 0);
      greyHeartComponent[i].scale = Vector2.all(3);

      add(greyHeartComponent[i]);
      add(heartComponent[i]);
    }
  }
}