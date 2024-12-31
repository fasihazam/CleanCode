import 'package:maple_harvest_app/core/core.dart';

abstract class MutationResponse {
  final String typeName;

  const MutationResponse({required this.typeName});

  Map<String, FieldNodeModel> get selectedFields;

  GraphQLErrorType? get errorType => null;
}