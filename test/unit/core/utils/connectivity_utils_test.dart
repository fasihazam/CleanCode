import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:maple_harvest_app/core/utils/connectivity_utils.dart';

import 'connectivity_utils_test.mocks.dart';

@GenerateMocks([Connectivity])
void main() {
  group('ConnectivityUtils', () {
    late MockConnectivity mockConnectivity;
    late ConnectivityUtils connectivityUtils;

    setUp(() {
      mockConnectivity = MockConnectivity();
      connectivityUtils = ConnectivityUtils(mockConnectivity);
    });

    test('should return true when there is internet connection', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Act
      final result = await connectivityUtils.hasInternet;

      // Assert
      expect(result, isTrue);
    });

    test('should return false when there is no internet connection', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.none]);

      // Act
      final result = await connectivityUtils.hasInternet;

      // Assert
      expect(result, isFalse);
    });
  });
}
