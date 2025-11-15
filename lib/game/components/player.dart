import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:pumpkin_nightmare/game/components/npc/enemy.dart';
import 'package:pumpkin_nightmare/game/game.dart';
import 'package:pumpkin_nightmare/environment/ground.dart';


enum CharacterState {
  idle,
  runing,
  squat,
  jump,
  fall,
  die
}


class Player extends SpriteAnimationGroupComponent<CharacterState> with CollisionCallbacks, HasGameReference<MainGame>
{
  Vector2 velocity = Vector2.zero();
  late Vector2 lastPosition;

  double mass = 50;
  double gravity = 40;
  double speed = 1000;
  bool grounded = false;
  bool isSquat = false;
  bool isJump = false;
  bool isDie = false;

  RectangleHitbox playerHitbox = RectangleHitbox(size: Vector2(44, 55));

  Player() : super(size: Vector2.all(64), position: Vector2(-110, 10));

  void damage()
  {
    game.audioManager.hurtSoundPlay();
    add(ColorEffect(
    const Color.fromARGB(221, 255, 17, 0),        // цвет
      EffectController(duration: 0.2,     // длительность эффекта (0.2 сек)
      reverseDuration: 0.2,             // вернуться обратно
      repeatCount: 1,
      ),
    ));
  }

  void jump()
  {
    if(grounded && !isSquat && game.isPlayerReady && game.isStart)
    {
      game.audioManager.jumpSoundPlay();
      velocity.y = -800;
      current = CharacterState.jump;
      grounded = false;
      isJump = true;
    }
  }

  void squat()
  {
    if(game.isPlayerReady && game.isStart)
    {
      current = CharacterState.squat;
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    priority = 2;

    final animation_run = SpriteAnimationData.sequenced(
      textureSize: Vector2(64, 64),
      amount: 4,                  
      stepTime: 0.09,                
    );
    
    final animation_idle = SpriteAnimationData.sequenced(
      textureSize: Vector2(64, 64),
      amount: 4,                  
      stepTime: 0.2,                
    );

    final animation_squat = SpriteAnimationData.sequenced(
      textureSize: Vector2(64, 64),
      amount: 2,                  
      stepTime: 0.08,                
    );

    final animation_jump = SpriteAnimationData.sequenced(
      textureSize: Vector2(64, 64),
      amount: 2,                  
      stepTime: 0.13,  
      loop: false              
    );

    final animation_fall = SpriteAnimationData.sequenced(
      textureSize: Vector2(64, 64),
      amount: 3,                  
      stepTime: 0.13, 
      loop: false               
    );

    final animation_die = SpriteAnimationData.sequenced(
      textureSize: Vector2(64, 64),
      amount: 3,                  
      stepTime: 0.13, 
      loop: false               
    );

    animations = {
        CharacterState.idle: await  SpriteAnimation.load("player.png", animation_idle, images: game.images),
        CharacterState.runing: await SpriteAnimation.load("player_run.png", animation_run, images: game.images),
        CharacterState.squat: await SpriteAnimation.load("player_squat.png", animation_squat, images: game.images),
        CharacterState.jump: await SpriteAnimation.load("player_jump.png", animation_jump, images: game.images),
        CharacterState.fall: await SpriteAnimation.load("player_fall.png", animation_fall, images: game.images),
        CharacterState.die: await SpriteAnimation.load("player_destroy.png", animation_die, images: game.images),
    };

    scale = Vector2.all(2);
    current = CharacterState.idle;

    add(playerHitbox);

    animationTickers?[CharacterState.die]?.onStart = () {
      isDie = true;
    };
  }

  @override
  void update(double dt)
  {
    super.update(dt);

    lastPosition = position.clone();

    velocity.y += gravity * mass * dt;
    position += velocity * dt;

    if(grounded)
    {
      isJump = false;
      game.audioManager.fallSoundPlay();
    }

    if(game.isPlayerReady && !game.isStart && !game.isFirstLaunch)
    {
      current = CharacterState.die;
    }
    

    if(!isSquat && grounded){
      if(game.isStart)
      {
        current = CharacterState.runing;
      }
    }
    else if(velocity.y > 0 && !grounded && !isSquat && game.isStart)
    {
      current = CharacterState.fall;
    }
    

    if(position.x <= game.size.x/8 && grounded && game.isStart)
    {
      velocity.x = 170;
    }
    else if(position.x > game.size.x/8)
    {
      velocity.x = 0;
      game.isPlayerReady = true;
    }

    if(position.x <= 30 && grounded && !game.isStart)
    {
      velocity.x = 170;
      current = CharacterState.runing;
    }
    else if(!game.isStart && game.isFirstLaunch)
    {
      velocity.x = 0;
      current = CharacterState.idle;
    }


    if(isSquat)
    {
      playerHitbox.size.x = 38;
      playerHitbox.size.y = size.y - 20;
      playerHitbox.position.y = 15;
    }
    else if(isJump)
    {
      playerHitbox.size.x = 25;
      playerHitbox.position.x = 20;
    }


    if(!isSquat && !isJump && !isDie)
    {
      playerHitbox.size.x = 38;
      playerHitbox.size.y = 56;
      playerHitbox.position = Vector2(20, 4);
    }
    else if(!isSquat && !isJump && isDie)
    {
      playerHitbox.position = Vector2(20, 0);
    }

  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if(other is Ground)
    {
      position.y = lastPosition.y;
      
      if(velocity.y > 0)
      {
        grounded = true;
        velocity.y = 0;
      }
    }

    if(other is Enemy)
    {
      if(!isDie && game.isStart)
      {
        game.healthIndicator.decreaseHealth();
        damage();
      }
    }
  }
}
