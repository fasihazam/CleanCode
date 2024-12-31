import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  group('RequestStatusExtension Tests', () {
    test('isLoading should return true when status is loading', () {
      const status = RequestStatus.loading;
      expect(status.isLoading, true);
      expect(RequestStatus.error.isLoading, false);
      expect(RequestStatus.success.isLoading, false);
    });

    test('isSuccess should return true when status is success', () {
      const status = RequestStatus.success;
      expect(status.isSuccess, true);
      expect(RequestStatus.loading.isSuccess, false);
      expect(RequestStatus.error.isSuccess, false);
    });

    test('hasError should return true when status is error', () {
      const status = RequestStatus.error;
      expect(status.hasError, true);
      expect(RequestStatus.loading.hasError, false);
      expect(RequestStatus.success.hasError, false);
    });

    test('should return correct boolean for all possible states', () {
      // Testing loading state
      const loadingStatus = RequestStatus.loading;
      expect(loadingStatus.isLoading, true);
      expect(loadingStatus.isSuccess, false);
      expect(loadingStatus.hasError, false);

      // Testing success state
      const successStatus = RequestStatus.success;
      expect(successStatus.isLoading, false);
      expect(successStatus.isSuccess, true);
      expect(successStatus.hasError, false);

      // Testing error state
      const errorStatus = RequestStatus.error;
      expect(errorStatus.isLoading, false);
      expect(errorStatus.isSuccess, false);
      expect(errorStatus.hasError, true);
    });
  });
}