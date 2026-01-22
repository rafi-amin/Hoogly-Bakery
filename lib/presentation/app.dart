import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'features/pos/pages/pos_page.dart';

class HoogliApp extends ConsumerWidget {
  const HoogliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Hoogli Bakery POS',
      theme: AppTheme.light(),
      home: const PosPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
