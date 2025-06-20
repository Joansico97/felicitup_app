import 'package:envied/envied.dart';

import '../constants/constants.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: EnvConstants.avatar1, obfuscate: true)
  static final String avatar1 = _Env.avatar1;
  @EnviedField(varName: EnvConstants.avatar2, obfuscate: true)
  static final String avatar2 = _Env.avatar2;
  @EnviedField(varName: EnvConstants.avatar3, obfuscate: true)
  static final String avatar3 = _Env.avatar3;
  @EnviedField(varName: EnvConstants.avatar4, obfuscate: true)
  static final String avatar4 = _Env.avatar4;
}
