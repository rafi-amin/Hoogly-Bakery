import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../data/datasources/local_pos_datasource.dart';
import '../../data/repositories/pos_repository_impl.dart';
import '../../domain/repositories/pos_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final localDataSourceProvider = Provider<LocalPosDataSource>(
  (ref) => LocalPosDataSource(ref.read(databaseProvider)),
);

final posRepositoryProvider = Provider<PosRepository>(
  (ref) => PosRepositoryImpl(ref.read(localDataSourceProvider)),
);
