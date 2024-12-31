import 'package:easy_localization/easy_localization.dart';
import 'package:maple_harvest_app/core/core.dart';

class LoginResponse extends MutationResponse {
  static const _typeName = 'CurrentUser';

  static const idKey = 'id';
  static const identifierKey = 'identifier';
  static const channelsKey = 'channels';

  final String id;

  final String identifier;

  final List<ChannelModel>? channels;

  LoginResponse({
    this.id = '',
    this.identifier = '',
    this.channels,
  }) : super(typeName: _typeName);

  factory LoginResponse.fromMap(Map<String, dynamic> map) => LoginResponse(
        id: map.getString(idKey),
        identifier: map.getString(identifierKey),
        channels: map.getListOrNull<ChannelModel>(
          channelsKey,
          (item) => ChannelModel.fromMap(item),
        ),
      );

  factory LoginResponse.fromData(Map<String, dynamic>? map) {
    const key = 'login';
    if ((map?.isEmpty ?? true) || (!map!.isValidKey(key))) {
      throw GeneralException(message: 'userNotFoundMsg'.tr());
    }

    return LoginResponse.fromMap(map[key]);
  }

  @override
  Map<String, FieldNodeModel> get selectedFields => {
        idKey: FieldNodeModel(name: idKey),
        identifierKey: FieldNodeModel(name: identifierKey),
        channelsKey: FieldNodeModel(
          name: channelsKey,
          children: ChannelModel.defaultFields,
        ),
      };
}
