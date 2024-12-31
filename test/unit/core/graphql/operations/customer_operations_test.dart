import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  group('CustomerOperations', () {
    test(
        'getActiveCustomer should generate default query when selection is null',
        () {
      final query = CustomerOperations.getActiveCustomer();
      expect(
        query,
        '''query ActiveCustomer {
  activeCustomer {
    id
    emailAddress
    phoneNumber
    title
    firstName
    lastName
    createdAt
    updatedAt
  }
}''',
      );
    });

    test('getActiveCustomer should include custom selected fields', () {
      final selection = CustomerRequest(
          id: '123', firstName: 'John', email: 'testing@testing.com');

      final query = CustomerOperations.getActiveCustomer(selection: selection);

      expect(
        query,
        '''query ActiveCustomer {
  activeCustomer {
    id
    emailAddress
    firstName
  }
}''',
      );
    });
  });
}
