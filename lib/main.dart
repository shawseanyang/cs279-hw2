import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_todo_app/constants/theme.dart';
import 'package:flutter_todo_app/controllers/theme_controller.dart';
import 'package:flutter_todo_app/providers/database_provider.dart';
import 'package:flutter_todo_app/views/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/*
Flutter apps are defined by the lib/ folder and generated into platform-specific apps that can actually run by the Flutter framework located in android/, ios/, linux/, macos/, and web/. This allows the developer to create one app but deploy natively to a variety of platforms.
*/

// This file is the starting point for the Flutter app

// This is the starting function
void main() async {
  // Initialize some Flutter components
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseProvider.initDb();
  await GetStorage.init();
  await ScreenUtil.ensureScreenSize();

  // Run the app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MyApp(),
  );
}

// MyApp extends StatelessWidget because it does not need to be redrawn (thus, stateless)
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // Get the theming
  final ThemeController _themeController = Get.put(ThemeController());

  // Override the build method
  @override
  Widget build(BuildContext context) {
    // specify a variety of parameters for the app's UI
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter TODO App',
          theme: Themes.lightTheme,
          themeMode: _themeController.theme,
          darkTheme: Themes.darkTheme,
          home: child,
        );
      },
      // This tells Flutter to display the home screen first
      child: HomeScreen(),
    );
  }
}
