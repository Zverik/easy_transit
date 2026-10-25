import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = FutureProvider<SharedPreferencesWithCache>(
  (_) async => SharedPreferencesWithCache.create(cacheOptions: SharedPreferencesWithCacheOptions()),
);
