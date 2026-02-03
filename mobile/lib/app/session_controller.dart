import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api.dart';

class SessionController extends ChangeNotifier {
  final SharedPreferences _prefs;
  final TokenStore tokenStore;
  final ApiClient apiClient;
  final AuthApi authApi;
  final PatientApi patientApi;

  ApiUser? _user;
  bool _restoring = true;

  SessionController._({
    required SharedPreferences prefs,
    required this.tokenStore,
    required this.apiClient,
    required this.authApi,
    required this.patientApi,
  }) : _prefs = prefs;

  static const _userJsonKey = 'auth_user_json';

  static Future<SessionController> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenStore = SharedPreferencesTokenStore(prefs);
    final apiClient = ApiClient(
      baseUrl: ApiConfig.defaultBaseUrl,
      tokenStore: tokenStore,
    );

    final controller = SessionController._(
      prefs: prefs,
      tokenStore: tokenStore,
      apiClient: apiClient,
      authApi: AuthApi(apiClient),
      patientApi: PatientApi(apiClient),
    );

    await controller.restore();
    return controller;
  }

  bool get isRestoring => _restoring;
  ApiUser? get user => _user;
  int? get userId => _user?.id;
  int? get patientId => _user?.patientId ?? _user?.id;
  bool get isLoggedIn => _user != null;

  Future<void> restore() async {
    _restoring = true;
    notifyListeners();

    // 1) Quick restore from prefs (for immediate UI), if present.
    final cachedUser = _prefs.getString(_userJsonKey);
    if (cachedUser != null && cachedUser.isNotEmpty) {
      try {
        final decoded = jsonDecode(cachedUser);
        if (decoded is Map) {
          _user = ApiUser.fromJson(decoded.cast<String, dynamic>());
        }
      } catch (_) {
        // ignore cache parsing errors
      }
    }

    // 2) Validate token by calling /auth/me if we have an access token.
    try {
      final tokens = await tokenStore.read();
      if (tokens?.accessToken != null && tokens!.accessToken.isNotEmpty) {
        final me = await authApi.me();
        _user = me;
        await _prefs.setString(_userJsonKey, jsonEncode({
          'id': me.id,
          if (me.patientId != null) 'patientId': me.patientId,
          'nome': me.nome,
          'email': me.email,
          'tipo': me.tipo,
        }));
      } else {
        _user = null;
      }
    } catch (_) {
      // Token inválido/expirado ou backend offline.
      await tokenStore.clear();
      _user = null;
    } finally {
      _restoring = false;
      notifyListeners();
    }
  }

  Future<LoginResult> loginPaciente({required String email, required String senha}) async {
    final result = await authApi.loginPaciente(email: email, senha: senha);
    _user = result.user;
    await _prefs.setString(_userJsonKey, jsonEncode({
      'id': result.user.id,
      if (result.user.patientId != null) 'patientId': result.user.patientId,
      'nome': result.user.nome,
      'email': result.user.email,
      'tipo': result.user.tipo,
    }));
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    try {
      await authApi.logout();
    } catch (_) {
      // ignore network errors on logout
      await tokenStore.clear();
    }
    _user = null;
    await _prefs.remove(_userJsonKey);
    notifyListeners();
  }
}
