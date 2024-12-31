import 'package:maple_harvest_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds simple query without variables or fields', () {
    const builder = GraphQLQueryBuilder(
      operationName: 'GetUser',
    );

    expect(builder.build(), equals('query GetUser {\n}'));
  });

  test('builds mutation operation type correctly', () {
    const builder = GraphQLQueryBuilder(
      operationName: 'UpdateUser',
      operationType: OperationType.mutation,
    );

    expect(builder.build(), equals('mutation UpdateUser {\n}'));
  });

  test('builds query with single variable correctly', () {
    const builder = GraphQLQueryBuilder(
      operationName: 'GetUser',
      variables: {'id': 'ID!'},
    );

    expect(builder.build(), equals('query GetUser(\$id: ID!) {\n}'));
  });

  test('builds query with multiple variables correctly', () {
    const builder = GraphQLQueryBuilder(
      operationName: 'GetUser',
      variables: {
        'id': 'ID!',
        'includeDetails': 'Boolean',
      },
    );

    expect(
      builder.build(),
      equals('query GetUser(\$id: ID!, \$includeDetails: Boolean) {\n}'),
    );
  });

  test('builds query with single simple field correctly', () {
    final builder = GraphQLQueryBuilder(
      operationName: 'GetUser',
      fields: {
        'id': FieldNodeModel(name: 'id'),
      },
    );

    expect(
      builder.build(),
      equals('query GetUser {\n  id\n}'),
    );
  });

  test('builds query with multiple simple fields correctly', () {
    final builder = GraphQLQueryBuilder(
      operationName: 'GetUser',
      fields: {
        'id': FieldNodeModel(name: 'id'),
        'name': FieldNodeModel(name: 'name'),
      },
    );

    expect(
      builder.build(),
      equals('query GetUser {\n  id\n  name\n}'),
    );
  });

  test('builds query with nested fields correctly', () {
    final builder = GraphQLQueryBuilder(
      operationName: 'GetUser',
      fields: {
        'user': FieldNodeModel(
          name: 'user',
          children: {
            'id': FieldNodeModel(name: 'id'),
            'profile': FieldNodeModel(
              name: 'profile',
              children: {
                'email': FieldNodeModel(name: 'email'),
              },
            ),
          },
        ),
      },
    );

    expect(
      builder.build(),
      equals('''query GetUser {
  user {
    id
    profile {
      email
    }
  }
}'''),
    );
  });

  test('builds mutation with variables and fields correctly', () {
    final builder = GraphQLQueryBuilder(
      operationName: 'UpdateUser',
      operationType: OperationType.mutation,
      variables: {
        'id': 'ID!',
        'input': 'UpdateUserInput!',
      },
      fields: {
        'updateUser': FieldNodeModel(
          name: 'updateUser',
          children: {
            'id': FieldNodeModel(name: 'id'),
            'success': FieldNodeModel(name: 'success'),
          },
        ),
      },
    );

    expect(
      builder.build(),
      equals('''mutation UpdateUser(\$id: ID!, \$input: UpdateUserInput!) {
  updateUser {
    id
    success
  }
}'''),
    );
  });

  test('builds query with field arguments correctly', () {
    final builder = GraphQLQueryBuilder(
      operationName: 'GetUser',
      fields: {
        'user': FieldNodeModel(
          name: 'user',
          arguments: {'id': '\$id'},
          children: {
            'id': FieldNodeModel(name: 'id'),
            'name': FieldNodeModel(name: 'name'),
          },
        ),
      },
      variables: {'id': 'ID!'},
    );

    expect(
      builder.build(),
      equals('''query GetUser(\$id: ID!) {
  user(id: "\$id") {
    id
    name
  }
}'''),
    );
  });

  test('handles empty field map correctly', () {
    const builder = GraphQLQueryBuilder(
      operationName: 'EmptyQuery',
      fields: {},
    );

    expect(builder.build(), equals('query EmptyQuery {\n}'));
  });

  test('handles null values in variables correctly', () {
    const builder = GraphQLQueryBuilder(
      operationName: 'QueryWithNulls',
      variables: {'nullableField': 'String'},
    );

    expect(
      builder.build(),
      equals('query QueryWithNulls(\$nullableField: String) {\n}'),
    );
  });

  test('generates correct indentation for deeply nested fields', () {
    final builder = GraphQLQueryBuilder(
      operationName: 'DeepQuery',
      fields: {
        'level1': FieldNodeModel(
          name: 'level1',
          children: {
            'level2': FieldNodeModel(
              name: 'level2',
              children: {
                'level3': FieldNodeModel(
                  name: 'level3',
                  children: {
                    'id': FieldNodeModel(name: 'id'),
                  },
                ),
              },
            ),
          },
        ),
      },
    );

    expect(
      builder.build(),
      equals('''query DeepQuery {
  level1 {
    level2 {
      level3 {
        id
      }
    }
  }
}'''),
    );
  });

  test('builds query with multiple argument types correctly', () {
    final builder = GraphQLQueryBuilder(
      operationName: 'GetUser',
      fields: {
        'user': FieldNodeModel(
          name: 'user',
          arguments: {
            'id': '\$id',
            'active': '\$isActive',
            'limit': '5',
            'name': '"John"',
          },
          children: {
            'id': FieldNodeModel(name: 'id'),
            'name': FieldNodeModel(name: 'name'),
          },
        ),
      },
      variables: {
        'id': 'ID!',
        'isActive': 'Boolean',
      },
    );

    expect(
      builder.build(),
      equals('''query GetUser(\$id: ID!, \$isActive: Boolean) {
  user(id: "\$id", active: "\$isActive", limit: "5", name: "\\"John\\"") {
    id
    name
  }
}'''),
    );
  });

  test('handles different argument value types correctly', () {
    final builder = GraphQLQueryBuilder(operationName: 'ComplexQuery', fields: {
      'items': FieldNodeModel(
        name: 'items',
        arguments: {
          'stringArg': '"text"',
          'numberArg': '42',
          'booleanArg': 'true',
          'variableRef': '\$var',
          'nullArg': 'null',
          'objectArg': '\u007Bkey: "value"\u007D',
          'arrayArg': '[1, 2, 3]',
        },
        children: {
          'id': FieldNodeModel(name: 'id'),
        },
      ),
    });

    expect(
      builder.build(),
      equals('''query ComplexQuery {
  items(stringArg: "\\"text\\"", numberArg: "42", booleanArg: "true", variableRef: "\$var", nullArg: "null", objectArg: "\\u007Bkey: \\"value\\"\\u007D", arrayArg: "[1, 2, 3]") {
    id
  }
}'''),
    );
  });

  test('handles escaped characters in arguments correctly', () {
    final builder = GraphQLQueryBuilder(
      operationName: 'EscapedQuery',
      fields: {
        'search': FieldNodeModel(
          name: 'search',
          arguments: {
            'query': '"Hello\nWorld"',
            'path': '"C:\\\\folder\\\\file"',
          },
          children: {
            'id': FieldNodeModel(name: 'id'),
          },
        ),
      },
    );

    expect(
      builder.build(),
      equals('''query EscapedQuery {
  search(query: "\\"Hello\\nWorld\\"", path: "\\"C:\\\\\\\\folder\\\\\\\\file\\"") {
    id
  }
}'''),
    );
  });
}
