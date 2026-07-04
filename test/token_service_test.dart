import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senior_project/services/token_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('clearSessionData keeps active request for the same user id', () async {
    await TokenService.saveID('user-1');
    await TokenService.saveToken('token-1');
    await TokenService.saveRefreshToken('refresh-1');
    await TokenService.saveRole('customer');
    await TokenService.saveActiveRequest(
      jsonEncode({'id': 10, 'user_id': 'user-1'}),
    );

    await TokenService.clearSessionData();

    expect(await TokenService.getToken(), isNull);
    expect(await TokenService.getID(), isNull);
    expect(await TokenService.getRefreshToken(), isNull);
    expect(await TokenService.getRole(), isNull);
    expect(
      await TokenService.getActiveRequestForUser('user-1'),
      contains('"id":10'),
    );
  });
}
