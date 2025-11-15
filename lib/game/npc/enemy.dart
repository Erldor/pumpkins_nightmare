import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pumpkin_nightmare/game/game.dart';


import 'package:pumpkin_nightmare/game/components/player.dart';

enum EnemyState {
  run,
  die
}

abstract class Enemy extends SpriteAnimationGroupComponent<EnemyState> with CollisionCallbacks, HasGameReference<MainGame>{

  double speed;
  final double assetSize;
  final String runAsset;
  final String destroyAsset;
  final int runAnimationCount;
  ShapeHitbox? _enemyHitbox;

  Enemy({this.assetSize = 64, this.runAnimationCount = 2, this.speed = 300, required this.runAsset, required this.destroyAsset}) : super(size: Vector2.all(assetSize));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.bottomCenter;
    priority = 2;
    final animation_run = SpriteAnimationData.sequenced(
      textureSize: Vector2(assetSize, assetSize),
      amount: runAnimationCount,                  
      stepTime: 0.09,                
    );
    
    final animation_die = SpriteAnimationData.sequenced(
      textureSize: Vector2(assetSize, assetSize),
      amount: 4,                  
      stepTime: 0.05,     
      loop: false        
    );


    animations = {
        EnemyState.run: await  SpriteAnimation.load(runAsset, animation_run, images: game.images),
        EnemyState.die: await  SpriteAnimation.load(destroyAsset, animation_die, images: game.images),
    };

    current = EnemyState.run;
    
    animationTickers?[EnemyState.die]?.onComplete = () {
      removeFromParent();
    };
  }

    @override
  void update(double dt) {
    super.update(dt);

    position += Vector2(-1, 0) * speed * dt;

    if(position.x < 0 - size.x)
    {
      removeFromParent();
    }else if(!game.isStart)
    {
      current = EnemyState.die;

      if(_enemyHitbox != null)
      {
        _enemyHitbox!.collisionType = CollisionType.inactive;
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if(other is Player)
    {
      if(game.isStart)
      {
        current = EnemyState.die;
      }
  
      if(_enemyHitbox != null)
      {
        _enemyHitbox!.collisionType = CollisionType.inactive;
      }
    }
  }

}

class Skull extends Enemy
{
  CircleHitbox skullHitbox = CircleHitbox(radius: 14);

  Skull() : super(runAsset: "skull.png", destroyAsset: "skull_destroy.png", assetSize: 32);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    super.speed = super.game.groundSpeed + 50;
    super._enemyHitbox = skullHitbox;

    position = Vector2(game.size.x, game.size.y - (size.y*3.4));
    scale  = Vector2.all(2);
    skullHitbox.position = Vector2.all(2);
    add(skullHitbox);
  }

}

class BatEnemy extends Enemy
{
  RectangleHitbox batHitBox = RectangleHitbox(size: Vector2(25, 20));

  BatEnemy() : super(runAsset: "bat.png", destroyAsset: "bat_destroy.png", assetSize: 48, runAnimationCount: 4);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    super.speed = super.game.groundSpeed + 100;
    super._enemyHitbox = batHitBox;

    position = Vector2(game.size.x + 48, game.size.y - (size.y*2));
    scale  = Vector2(-2.2, 2.2);
    batHitBox.anchor = Anchor.center;
    batHitBox.position = Vector2(25, 20);
    add(batHitBox);
  }

}


class Ghost extends Enemy
{
  RectangleHitbox ghostHitbox = RectangleHitbox(size: Vector2(30, 40), position: Vector2(19, 13));

  Ghost() : super(runAsset: "ghost.png", destroyAsset: "ghost_destroy.png", assetSize: 64);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    super.speed = super.game.groundSpeed + 100;
    super._enemyHitbox = ghostHitbox;

    position = Vector2(game.size.x, game.size.y - size.y/2);
    scale  = Vector2.all(2);
    add(ghostHitbox);
  }

}