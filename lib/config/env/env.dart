import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAP_BOX_ACCESS_TOKEN', obfuscate: true)
  static final mapBoxApiKey = _Env.mapBoxApiKey;

  @EnviedField(varName: 'URL_MAP_BOX_API')
  static const urlMapBoxApi = _Env.urlMapBoxApi;

  @EnviedField(varName: 'SEARCH_MAP_BOX_API')
  static const searchMapBoxApi = _Env.searchMapBoxApi;
}
