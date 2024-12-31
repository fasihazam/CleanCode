import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('StringExtension', () {
    group('sanitizeName', () {
      test('should keep valid alphanumeric name unchanged', () {
        const validName = 'JohnDoe123';

        final result = validName.sanitizeName;

        expect(result, equals('JohnDoe123'));
      });

      test('should remove all special characters except underscores', () {
        const nameWithSpecialChars = 'John@#\$%^&*()Doe!123';

        final result = nameWithSpecialChars.sanitizeName;

        expect(result, equals('JohnDoe123'));
      });

      test('should preserve underscores in valid positions', () {
        const nameWithUnderscores = 'John_Doe_123';

        final result = nameWithUnderscores.sanitizeName;

        expect(result, equals('John_Doe_123'));
      });

      test('should trim leading and trailing whitespace', () {
        const nameWithWhitespace = '  JohnDoe  ';

        final result = nameWithWhitespace.sanitizeName;

        expect(result, equals('JohnDoe'));
      });

      test('should remove spaces between characters', () {
        const nameWithSpaces = 'John Doe 123';

        final result = nameWithSpaces.sanitizeName;

        expect(result, equals('JohnDoe123'));
      });

      group('should throw GeneralException when', () {
        test('name is empty', () {
          expect(
            () => ''.sanitizeName,
            throwsA(isA<GeneralException>()),
          );
        });

        test('name is only whitespace', () {
          expect(
            () => '   '.sanitizeName,
            throwsA(isA<GeneralException>()),
          );
        });

        test('name starts with a number', () {
          expect(
            () => '1JohnDoe'.sanitizeName,
            throwsA(isA<GeneralException>()),
          );
        });

        test('name starts with an underscore', () {
          expect(
            () => '_JohnDoe'.sanitizeName,
            throwsA(isA<GeneralException>()),
          );
        });

        test('name is too short after sanitization (< 3 characters)', () {
          expect(
            () => 'A@#'.sanitizeName,
            throwsA(isA<GeneralException>()),
          );
        });

        test('name is too long (> 80 characters)', () {
          final longName = 'A' * 81;

          expect(
            () => longName.sanitizeName,
            throwsA(isA<GeneralException>()),
          );
        });

        test('name contains only special characters', () {
          expect(
            () => '@#\$%^&*()'.sanitizeName,
            throwsA(isA<GeneralException>()),
          );
        });

        test('sanitized name would be empty', () {
          expect(
            () => '@#\$'.sanitizeName,
            throwsA(isA<GeneralException>()),
          );
        });
      });

      group('unicode handling', () {
        test('should remove non-ASCII characters', () {
          const nameWithUnicode = 'JöhnDöé123';

          final result = nameWithUnicode.sanitizeName;

          expect(result, equals('JhnD123'));
        });

        test('should handle mixed ASCII and special characters', () {
          const mixedName = 'Jöhn@Döé#123';

          final result = mixedName.sanitizeName;

          expect(result, equals('JhnD123'));
        });

        test('should handle zero-width characters', () {
          const nameWithZeroWidth = 'admin\u200B\u200Ctest';
          final result = nameWithZeroWidth.sanitizeName;
          expect(result, equals('admintest'));
        });
      });

      test('should sanitize SQL injection patterns', () {
        const maliciousInput = "DROP TABLE users;--";
        final result = maliciousInput.sanitizeName;
        expect(result, equals('DROPTABLEusers'));
      });
    });

    group('isValidOPName', () {
      group('should return true when', () {
        test('name contains only letters', () {
          const validName = 'QueryOperation';
          expect(validName.isValidOPName, isTrue);
        });

        test('name contains letters and numbers', () {
          const validName = 'QueryOperation123';

          expect(validName.isValidOPName, isTrue);
        });

        test('name contains letters, numbers and underscores', () {
          const validName = 'Query_Operation_123';

          expect(validName.isValidOPName, isTrue);
        });
      });

      group('should return false when', () {
        test('name is empty', () {
          expect(''.isValidOPName, isFalse);
        });

        test('name starts with number', () {
          expect('1QueryOperation'.isValidOPName, isFalse);
        });

        test('name starts with underscore', () {
          expect('_QueryOperation'.isValidOPName, isFalse);
        });

        test('name contains spaces', () {
          expect('Query Operation'.isValidOPName, isFalse);
        });

        test('name contains special characters', () {
          expect('Query@Operation'.isValidOPName, isFalse);
        });

        test('name contains unicode characters', () {
          expect('QueryOperätión'.isValidOPName, isFalse);
        });
      });

      test('should handle maximum reasonable length', () {
        final longName = 'a' * 255;

        expect(longName.isValidOPName, isTrue);
      });
    });
  });
}
