import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/network/auth_interceptor.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_database.dart';
import 'core/sync/sync_engine.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/auth_local_ds.dart';
import 'data/datasources/remote/attendance_remote_ds.dart';
import 'data/datasources/remote/auth_remote_ds.dart';
import 'data/datasources/remote/parking_remote_ds.dart';
import 'data/datasources/remote/settlement_remote_ds.dart';
import 'data/datasources/remote/sync_remote_ds.dart';
import 'data/datasources/remote/transaction_remote_ds.dart';
import 'data/datasources/remote/supervisor_remote_ds.dart';
import 'data/repositories/attendance_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/parking_repository.dart';
import 'data/repositories/settlement_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/supervisor_repository.dart';
import 'features/attendance/bloc/attendance_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/parking_active/bloc/active_sessions_bloc.dart';
import 'features/parking_entry/bloc/entry_bloc.dart';
import 'features/parking_exit/bloc/exit_bloc.dart';
import 'features/payment/bloc/payment_bloc.dart';
import 'features/history/bloc/history_bloc.dart';
import 'features/settlement/bloc/settlement_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.initialize();

  final appBox = Hive.box(LocalDatabase.appBoxName);
  final syncBox = Hive.box(LocalDatabase.syncBoxName);
  final authInterceptor = AuthInterceptor(appBox);
  final Dio dio = DioClient.create(authInterceptor);

  // Repositories
  final authRepository = AuthRepository(
    remote: AuthRemoteDatasource(dio),
    local: AuthLocalDatasource(appBox),
  );
  final parkingRepository = ParkingRepository(
    remote: ParkingRemoteDatasource(dio),
  );
  final transactionRepository = TransactionRepository(
    remote: TransactionRemoteDatasource(dio),
  );
  final attendanceRepository = AttendanceRepository(
    remote: AttendanceRemoteDatasource(dio),
  );
  final settlementRepository = SettlementRepository(
    remote: SettlementRemoteDatasource(dio),
  );
  final supervisorRepository = SupervisorRepository(
    remote: SupervisorRemoteDatasource(dio),
  );

  // Sync engine
  final syncEngine = SyncEngine(
    remote: SyncRemoteDatasource(dio),
    local: SyncLocalDatasource(syncBox),
    authRepo: authRepository,
  );

  runApp(
    ParkirGoApp(
      authRepository: authRepository,
      parkingRepository: parkingRepository,
      transactionRepository: transactionRepository,
      attendanceRepository: attendanceRepository,
      settlementRepository: settlementRepository,
      supervisorRepository: supervisorRepository,
      syncEngine: syncEngine,
      dio: dio,
    ),
  );
}

class ParkirGoApp extends StatefulWidget {
  const ParkirGoApp({
    super.key,
    required this.authRepository,
    required this.parkingRepository,
    required this.transactionRepository,
    required this.attendanceRepository,
    required this.settlementRepository,
    required this.supervisorRepository,
    required this.syncEngine,
    required this.dio,
  });

  final AuthRepository authRepository;
  final ParkingRepository parkingRepository;
  final TransactionRepository transactionRepository;
  final AttendanceRepository attendanceRepository;
  final SettlementRepository settlementRepository;
  final SupervisorRepository supervisorRepository;
  final SyncEngine syncEngine;
  final Dio dio;

  @override
  State<ParkirGoApp> createState() => _ParkirGoAppState();
}

class _ParkirGoAppState extends State<ParkirGoApp> {
  @override
  void initState() {
    super.initState();
    widget.syncEngine.start();
  }

  @override
  void dispose() {
    widget.syncEngine.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.authRepository),
        RepositoryProvider.value(value: widget.parkingRepository),
        RepositoryProvider.value(value: widget.transactionRepository),
        RepositoryProvider.value(value: widget.attendanceRepository),
        RepositoryProvider.value(value: widget.settlementRepository),
        RepositoryProvider.value(value: widget.supervisorRepository),
        RepositoryProvider.value(value: widget.dio),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc(context.read<AuthRepository>())),
          BlocProvider(create: (context) => HomeBloc(context.read<ParkingRepository>())),
          BlocProvider(create: (context) => AttendanceBloc(context.read<AttendanceRepository>())),
          BlocProvider(create: (context) => EntryBloc(context.read<ParkingRepository>())),
          BlocProvider(create: (context) => ActiveSessionsBloc(context.read<ParkingRepository>())),
          BlocProvider(create: (context) => ExitBloc(context.read<ParkingRepository>(), context.read<TransactionRepository>())),
          BlocProvider(create: (context) => PaymentBloc(context.read<TransactionRepository>())),
          BlocProvider(create: (context) => HistoryBloc(context.read<TransactionRepository>())),
          BlocProvider(create: (context) => SettlementBloc(context.read<SettlementRepository>(), context.read<TransactionRepository>())),
        ],
        child: Builder(
          builder: (context) {
            return MultiProvider(
              providers: [
                Provider(create: (_) => SupervisorRemoteDatasource(widget.dio)),
              ],
              child: MaterialApp.router(
                title: 'ParkirGo',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                routerConfig: AppRouter.create(),
              ),
            );
          }
        ),
      ),
    );
  }
}
