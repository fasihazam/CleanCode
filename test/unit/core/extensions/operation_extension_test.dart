import 'package:flutter_test/flutter_test.dart';
import 'package:gql/language.dart' as gql_lang;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  group('OperationExtension Tests', () {
    group('realOPName tests', () {
      test('should return operationName when provided', () {
        final operation = Operation(
          operationName: 'TestQuery',
          document: gql_lang.parseString('query { test }'),
        );

        expect(operation.realOPName, equals('TestQuery'));
      });

      test('should return name from document definition when operationName is null', () {
        final operation = Operation(
          document: gql_lang.parseString('''
            query GetUserData {
              user {
                id
                name
              }
            }
          '''),
        );

        expect(operation.realOPName, equals('GetUserData'));
      });

      test('should return "Unnamed" when no name is available', () {
        final operation = Operation(
          document: gql_lang.parseString('''
            query {
              user {
                id
                name
              }
            }
          '''),
        );

        expect(operation.realOPName, equals('Unnamed'));
      });
    });

    group('opType tests', () {
      test('should return "query" for Operation', () {
        final operation = Operation(
          document: gql_lang.parseString('query { test }'),
        );

        expect(operation.opType, equals('query'));
      });

      test('should return "mutation" for MutationOptions', () {
        final operation = Operation(
          document: gql_lang.parseString('mutation { updateTest }'),
        );

        expect(operation.opType, equals('mutation'));
      });

      test('should return "Unknown" for invalid operation type', () {
        // Creating a mock operation with no valid operation type
        final operation = Operation(
          document: gql_lang.parseString('''
            fragment UserFragment on User {
              id
              name
            }
          '''),
        );

        expect(operation.opType, equals('Unknown'));
      });

      test('should handle multiple operations in document', () {
        final operation = Operation(
          document: gql_lang.parseString('''
            query GetUser {
              user {
                id
              }
            }
            
            mutation UpdateUser {
              updateUser {
                id
              }
            }
          '''),
        );

        expect(operation.opType, equals('query'));
      });
    });

    group('Complex scenarios', () {
      test('should handle empty document', () {
        final operation = Operation(
          document: gql_lang.parseString(''),
        );

        expect(operation.realOPName, equals('Unnamed'));
        expect(operation.opType, equals('Unknown'));
      });

      test('should handle document with only fragments', () {
        final operation = Operation(
          document: gql_lang.parseString('''
            fragment UserParts on User {
              id
              name
            }
            
            fragment ProfileParts on Profile {
              bio
              avatar
            }
          '''),
        );

        expect(operation.realOPName, equals('Unnamed'));
        expect(operation.opType, equals('Unknown'));
      });

      test('should handle named operation with fragments', () {
        final operation = Operation(
          document: gql_lang.parseString('''
            query GetUserWithProfile {
              user {
                ...UserParts
                profile {
                  ...ProfileParts
                }
              }
            }
            
            fragment UserParts on User {
              id
              name
            }
            
            fragment ProfileParts on Profile {
              bio
              avatar
            }
          '''),
        );

        expect(operation.realOPName, equals('GetUserWithProfile'));
        expect(operation.opType, equals('query'));
      });
    });
  });
}