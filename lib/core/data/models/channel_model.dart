import 'package:maple_harvest_app/core/core.dart';

class ChannelModel extends GraphQLModel {
  static const idKey = 'id';
  static const tokenKey = 'token';
  static const codeKey = 'code';
  static const permissionsKey = 'permissions';

  final String id;
  final String token;
  final String code;
  final List<String> permissions;

  ChannelModel({
    this.id = '',
    this.token = '',
    this.code = '',
    this.permissions = const [],
  });

  @override
  Map<String, FieldNodeModel> get selectedFields => defaultFields;

  static Map<String, FieldNodeModel> get defaultFields => GraphQLModel.generateFields([
    idKey,
    tokenKey,
    codeKey,
    permissionsKey,
  ]);

  factory ChannelModel.fromMap(Map<String, dynamic> map) => ChannelModel(
    id: map.getString(idKey),
    token: map.getString(tokenKey),
    code: map.getString(codeKey),
    permissions: map.getList<String>(permissionsKey, (item) => item as String),
  );
}