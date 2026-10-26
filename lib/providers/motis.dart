import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:public_transport/public_transport.dart';

final motisProvider = Provider((_) => MotisBackend('https://api.transitous.org/api'));