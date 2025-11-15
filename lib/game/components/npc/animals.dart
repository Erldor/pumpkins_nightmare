
import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:pumpkin_nightmare/game/game.dart';

abstract class Animal extends SpriteAnimationComponent with HasGameReference<MainGame> {
  final String animalAsset;
  final double animalSize;
  int z_index;
  double? yPosition;
  double speed = 0;
  
  Animal({required this.animalAsset, this.yPosition, this.z_index = -1, this.animalSize = 32}) : super(anchor: Anchor.bottomCenter, size: Vector2.all(animalSize), priority: z_index);


  double mod(double value)
  {
    return value >= 0 ? value : -value;
  }

  @override
  Future<void> onLoad() async {
    if(z_index == -1)
    {
      speed = -(game.groundSpeed + Random().nextInt(100) + 50);
    }
    else
    {
      speed = -game.groundSpeed - 100;
    }

    yPosition ??= game.size.y - animalSize;

    final animation_run = SpriteAnimationData.sequenced(
      textureSize: Vector2.all(animalSize),
      amount: 3,                  
      stepTime: 0.1,
      loop: true                
    );

    position = Vector2(game.size.x, yPosition!);
    animation = await SpriteAnimation.load(animalAsset, animation_run, images: game.images);

    if(z_index < -1)
    {
      scale = Vector2(-2, 2) * ((1/mod(z_index.toDouble())) + 0.25);
    }
    else
    {
      scale = Vector2(-2, 2);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if(z_index < -1)
    {
      position.x += ((speed/mod(z_index.toDouble())) -20) * dt;
    }
    else
    {
      position.x += speed * dt;
    }
    
  }
}

class Rat extends Animal
{
  Rat() : super(animalAsset: "rat_walk.png");
}

class Raven extends Animal
{
  Raven() : super(animalAsset: "raven_fly.png", z_index: -(Random().nextInt(3) + 3));

  @override
  Future<void> onLoad() async {
    yPosition = Random().nextInt(250) + 50;
    return super.onLoad();
  }
}

class Bat extends Animal
{
  Bat() : super(animalAsset: "bat.png", z_index: -(Random().nextInt(3) + 3), animalSize: 48);

  @override
  Future<void> onLoad() async {
    yPosition = Random().nextInt((game.size.y - 50).floor() - 70) + 70;
    return super.onLoad();
  }
}