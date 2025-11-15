import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:pumpkin_nightmare/game/game.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pumpkin_nightmare/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<String> languageCode = ValueNotifier("ru");
ValueNotifier<bool> isGameStart = ValueNotifier(false);

class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  double logoOpacity = 1.0;
  @override
  void initState() {
    super.initState();
    GameScaffold gameScaffold = GameScaffold();
    Future.delayed(Duration(seconds: 2), 
    (){
      logoOpacity = 0.0;
      setState(() {
        
      });

    }
    );
    Future.delayed(Duration(seconds: 3), 
    (){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => gameScaffold));
    }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: Center(child: AnimatedOpacity(duration: Duration(seconds: 1), opacity: logoOpacity, child: Image.asset("assets/images/splash_logo.png", width: 100,))));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(
  SystemUiMode.immersiveSticky,
  overlays: [], // полностью убираем панели
);

  runApp(ValueListenableBuilder(
    valueListenable: languageCode,
    builder: (context, lang, child) {
      return MaterialApp(
      
        locale: Locale(lang),
      
        supportedLocales: AppLocalizations.supportedLocales,
      
        localizationsDelegates: const
        [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      
        debugShowCheckedModeBanner: false,
        
        home: SplashWidget() 
      );
    }
  )
    
  );
}

class GameScaffold extends StatelessWidget {

  const GameScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        SafeArea(
          top: false,
          bottom: false,
          left: false,
          right: false,
          child: GameWidget(game: MainGame())
        ),
        ValueListenableBuilder(
          valueListenable: isGameStart,
          builder: (context, gameStart, child) {
            return Positioned(top: 0, right: 20, child: Opacity(
              opacity: gameStart ? 0 : 1,
              child: ValueListenableBuilder(
                valueListenable: languageCode,
                builder: (context, lang, child) {
                  return TextButton(onPressed: gameStart ? (){} : () async {
                    final storage = await SharedPreferences.getInstance();
                    if(lang == "ru")
                    {
                      languageCode.value = "en";
                      storage.setString("language_code", "en");
                    }
                    else
                    {
                      languageCode.value = "ru";
                      storage.setString("language_code", "ru");
                    }
                  }, child: lang == "ru" ? Text("EN", style: TextStyle(color: const Color.fromARGB(255, 156, 64, 7), fontFamily: "Roboto-bold", fontWeight: FontWeight.bold, fontSize: 20)) : Text("RU", style: TextStyle(color: const Color.fromARGB(255, 156, 64, 7), fontFamily: "Roboto-bold", fontWeight: FontWeight.bold, fontSize: 20)));
                }
              ),
            ),);
          }
        )
            
      ]),
    );
  }
}

