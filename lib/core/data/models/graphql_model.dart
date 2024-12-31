import 'package:maple_harvest_app/core/core.dart';

abstract class GraphQLModel {
  /// It will generate only those fields that have values
  /// All the other fields will be ignored
  Map<String, FieldNodeModel> get selectedFields;

  static Map<String, FieldNodeModel> generateFields(List<String> fields) =>
      Map.unmodifiable(Map.fromEntries(
          fields.map((field) => MapEntry(field, FieldNodeModel(name: field)))));


}
