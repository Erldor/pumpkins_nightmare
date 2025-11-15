import 'dart:async';
import 'package:flame/components.dart';
import 'package:pumpkin_nightmare/game/game.dart';

class Background extends SpriteComponent with HasGameReference<MainGame>
{
  final int z_index;
  final int backgroundCount = 6;
  late final int backgroundId;
  late final double speed;

  Background({required this.z_index}) : super(priority: z_index)
  {
    backgroundId = (backgroundCount + 1) + z_index;
    if(backgroundId == 4)
    {
      speed = 20;
    }
    else if(backgroundId == 3)
    {
      speed = 10;
    }
    else
    {
      speed = 2.0 * backgroundId;
    }
  }
  

  @override
  FutureOr<void> onLoad() async{
    sprite = await game.loadSprite("bckg_$backgroundId" + ".png");
    size = backgroundId == 1 ? Vector2(game.size.x, game.size.y) : Vector2(game.size.x*2, game.size.y);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if(game.isStart && backgroundId != 1)
    {
      position += Vector2(-1,0) * speed * dt;
      if(position.x <= -game.size.x)
      {
        position.x = 0;
      }
    }
    else
    {
      if(backgroundId == 3 || backgroundId == 4)
      {
        position += Vector2(-1,0) * speed * dt;
        if(position.x <= -game.size.x)
        {
          position.x = 0;
        }
      }
    }
  }
}

class Rain extends SpriteAnimationComponent with HasGameReference<MainGame>{

  Rain() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final data = SpriteAnimationData.sequenced(
      textureSize: Vector2(576, 324),
      amount: 5,                  
      stepTime: 0.07,
      loop: true                
    );

    animation = await SpriteAnimation.load("rain.png", data, images: game.images);
    opacity = 0.3;

    position = game.size/2;
    size = game.size;
  }


}