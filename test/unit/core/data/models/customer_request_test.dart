import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([LoggerUtils])
void main() {
  group('CustomerRequest', () {
    test('selectedFields includes non-empty string fields', () {
      final customer = CustomerRequest(
        id: 'test-id',
        email: 'test@email.com',
        firstName: 'John',
        lastName: 'Doe',
      );

      final fields = customer.selectedFields;

      expect(fields.containsKey(CustomerRequest.idKey), isTrue);
      expect(fields.containsKey(CustomerRequest.emailKey), isTrue);
      expect(fields.containsKey(CustomerRequest.firstNameKey), isTrue);
      expect(fields.containsKey(CustomerRequest.lastNameKey), isTrue);
      expect(fields.containsKey(CustomerRequest.phoneKey), isFalse);

      // Verify field structure
      fields.forEach((key, field) {
        expect(field, isA<FieldNodeModel>());
        expect(field.name, equals(key));
        expect(field.children, isEmpty);
      });
    });

    test('selectedFields includes addresses with children when present', () {
      final customer = CustomerRequest(
        addresses: [AddressModel(id: 'addr-1')],
      );

      final fields = customer.selectedFields;
      final addressField = fields[CustomerRequest.addressesKey];

      expect(addressField, isNotNull);
      expect(addressField?.name, equals(CustomerRequest.addressesKey));
      expect(addressField?.children.keys, equals(AddressModel.defaultFields.keys));
    });

    test('defaultFields generates correct structure', () {
      final fields = CustomerRequest.defaultFields;

      // Verify field count and keys
      expect(fields.length, equals(8));
      final expectedKeys = {
        CustomerRequest.idKey,
        CustomerRequest.emailKey,
        CustomerRequest.phoneKey,
        CustomerRequest.titleKey,
        CustomerRequest.firstNameKey,
        CustomerRequest.lastNameKey,
        CustomerRequest.createdAtKey,
        CustomerRequest.updatedAtKey,
      };
      expect(fields.keys, equals(expectedKeys));

      // Verify field structure
      fields.forEach((key, field) {
        expect(field, isA<FieldNodeModel>());
        expect(field.name, equals(key));
        expect(field.children, isEmpty);
      });
    });
  });

  group('AddressModel', () {
    test('selectedFields includes non-empty string fields and boolean fields', () {
      final address = AddressModel(
        id: 'addr-1',
        streetLine1: '123 Main St',
        city: 'Test City',
        defaultShippingAddress: true,
      );

      final fields = address.selectedFields;

      // Verify required fields are present
      expect(fields.containsKey(AddressModel.idKey), isTrue);
      expect(fields.containsKey(AddressModel.streetLine1Key), isTrue);
      expect(fields.containsKey(AddressModel.cityKey), isTrue);
      expect(fields.containsKey(AddressModel.defaultShippingAddressKey), isTrue);

      // Verify empty fields are not present
      expect(fields.containsKey(AddressModel.streetLine2Key), isFalse);

      // Verify field structure
      fields.forEach((key, field) {
        expect(field, isA<FieldNodeModel>());
        expect(field.name, equals(key));
        expect(field.children, isEmpty);
      });
    });

    test('selectedFields includes country when present', () {
      final address = AddressModel(
        country: CountryModel(id: 'country-1'),
      );

      final fields = address.selectedFields;
      final countryField = fields[AddressModel.countryKey];

      expect(countryField, isNotNull);
      expect(countryField?.name, equals(AddressModel.countryKey));
      expect(countryField?.children.keys, equals(CountryModel.defaultFields.keys));
    });

    test('selectedFields includes customFields when present', () {
      final address = AddressModel(
        customFields: AddressCustomFieldsModel(
          lat: 12.34,
          lng: 56.78,
        ),
      );

      final fields = address.selectedFields;
      final customField = fields[AddressModel.customFieldsKey];

      expect(customField, isNotNull);
      expect(customField?.name, equals(AddressModel.customFieldsKey));
      expect(
        customField?.children.keys,
        equals(AddressCustomFieldsModel.defaultFields.keys),
      );
    });
  });

  group('CountryModel', () {
    test('defaultFields includes all required fields and nested structures', () {
      final fields = CountryModel.defaultFields;

      // Verify basic fields
      final expectedBasicKeys = {
        CountryModel.idKey,
        CountryModel.nameKey,
        CountryModel.codeKey,
        CountryModel.languageCodeKey,
        CountryModel.customFieldsKey,
      };
      for (final key in expectedBasicKeys) {
        expect(fields.containsKey(key), isTrue);
        expect(fields[key], isA<FieldNodeModel>());
        expect(fields[key]?.name, equals(key));
      }

      // Verify nested parent structure
      final parentField = fields[CountryModel.parentKey];
      expect(parentField, isNotNull);
      expect(parentField?.name, equals(CountryModel.parentKey));
      expect(parentField?.children, isNotNull);

      // Verify nested translations structure
      final translationsField = fields[CountryModel.translationsKey];
      expect(translationsField, isNotNull);
      expect(translationsField?.name, equals(CountryModel.translationsKey));
      expect(
        translationsField?.children.keys,
        equals(CountryTranslationModel.defaultFields.keys),
      );
    });

    test('selectedFields returns same structure as defaultFields', () {
      final country = CountryModel(
        id: 'country-1',
        name: 'Test Country',
      );

      final selectedFields = country.selectedFields;
      final defaultFields = CountryModel.defaultFields;

      expect(selectedFields.keys, equals(defaultFields.keys));

      selectedFields.forEach((key, field) {
        expect(field.name, equals(defaultFields[key]?.name));
        expect(field.children.keys, equals(defaultFields[key]?.children.keys));
      });
    });
  });

  group('AddressCustomFieldsModel', () {
    test('defaultFields includes all required fields with correct structure', () {
      final fields = AddressCustomFieldsModel.defaultFields;

      final expectedKeys = {
        AddressCustomFieldsModel.latKey,
        AddressCustomFieldsModel.lngKey,
        AddressCustomFieldsModel.placeIdKey,
        AddressCustomFieldsModel.typeKey,
      };

      expect(fields.keys, equals(expectedKeys));

      fields.forEach((key, field) {
        expect(field, isA<FieldNodeModel>());
        expect(field.name, equals(key));
        expect(field.children, isEmpty);
      });
    });

    test('selectedFields returns same structure as defaultFields', () {
      final customFields = AddressCustomFieldsModel(
        lat: 12.34,
        lng: 56.78,
        placeId: 'place-1',
        type: 'home',
      );

      final selectedFields = customFields.selectedFields;
      final defaultFields = AddressCustomFieldsModel.defaultFields;

      expect(selectedFields.keys, equals(defaultFields.keys));

      selectedFields.forEach((key, field) {
        expect(field.name, equals(defaultFields[key]?.name));
        expect(field.children, isEmpty);
      });
    });
  });

  group('CountryTranslationModel', () {
    test('defaultFields includes all required fields with correct structure', () {
      final fields = CountryTranslationModel.defaultFields;

      final expectedKeys = {
        CountryTranslationModel.idKey,
        CountryTranslationModel.createdAtKey,
        CountryTranslationModel.updatedAtKey,
        CountryTranslationModel.languageCodeKey,
        CountryTranslationModel.nameKey,
      };

      expect(fields.keys, equals(expectedKeys));

      fields.forEach((key, field) {
        expect(field, isA<FieldNodeModel>());
        expect(field.name, equals(key));
        expect(field.children, isEmpty);
      });
    });

    test('selectedFields returns same structure as defaultFields', () {
      final translation = CountryTranslationModel(
        id: 'trans-1',
        languageCode: 'en',
        name: 'Test Name',
      );

      final selectedFields = translation.selectedFields;
      final defaultFields = CountryTranslationModel.defaultFields;

      expect(selectedFields.keys, equals(defaultFields.keys));

      selectedFields.forEach((key, field) {
        expect(field.name, equals(defaultFields[key]?.name));
        expect(field.children, isEmpty);
      });
    });
  });
}