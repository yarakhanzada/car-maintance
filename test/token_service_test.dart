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

  test('stores active requests separately per user id', () async {
    await TokenService.saveActiveRequest(
      jsonEncode({'id': 10, 'driver_id': 'driver-1'}),
      userId: 'driver-1',
    );
    await TokenService.saveActiveRequest(
      jsonEncode({'id': 20, 'driver_id': 'driver-2'}),
      userId: 'driver-2',
    );

    expect(
      await TokenService.getActiveRequestForUser('driver-1'),
      contains('"id":10'),
    );
    expect(
      await TokenService.getActiveRequestForUser('driver-2'),
      contains('"id":20'),
    );

    await TokenService.clearActiveRequestForUser('driver-1');

    expect(await TokenService.getActiveRequestForUser('driver-1'), isNull);
    expect(
      await TokenService.getActiveRequestForUser('driver-2'),
      contains('"id":20'),
    );
  });
}
