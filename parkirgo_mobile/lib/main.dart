import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/local_database.dart';
import 'core/network/auth_interceptor.dart';
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localDatabase = LocalDatabase.instance;
  await localDatabase.init();

  final authInterceptor = AuthInterceptor(localDatabase);
  final dio = DioClient.create(authInterceptor);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: localDatabase),
        Provider.value(value: dio),
      ],
      child: const ParkirGoApp(),
    ),
  );
}

class ParkirGoApp extends StatelessWidget {
  const ParkirGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ParkirGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.create(),
    );
  }
}
