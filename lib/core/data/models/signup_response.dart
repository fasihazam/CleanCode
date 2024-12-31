import 'package:easy_localization/easy_localization.dart';
import 'package:maple_harvest_app/core/core.dart';

class SignupResponse extends MutationResponse {
  static const _typeName = 'Success';

  static const successKey = 'success';

  final bool success;

  SignupResponse({
    this.success = false,
  }) : super(typeName: _typeName);

  factory SignupResponse.fromMap(Map<String, dynamic> map) =>
      SignupResponse(success: map.getBool(successKey));

  factory SignupResponse.fromData(Map<String, dynamic>? map) {
    const key = 'registerCustomerAccount';
    if ((map?.isEmpty ?? true) || (!map!.isValidKey(key))) {
      throw GeneralException(message: 'operationFailedMsg'.tr());
    }

    return SignupResponse.fromMap(map[key]);
  }

  @override
  Map<String, FieldNodeModel> get selectedFields => {
        successKey: FieldNodeModel(name: successKey),
      };
}
