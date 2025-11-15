import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pumpkin_nightmare/game/game.dart';

class Ground extends SpriteComponent with CollisionCallbacks, HasGameReference<MainGame>{
  Ground(Vector2 position, Vector2 size) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite("grass.png");
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if(game.isStart)
    {
      position += Vector2(-1,0) * game.groundSpeed * dt;
    }
    
    if(position.x <= -game.size.x)
    {
      position.x = 0;
    }
  }
}