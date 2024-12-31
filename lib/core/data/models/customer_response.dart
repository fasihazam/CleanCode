import 'package:easy_localization/easy_localization.dart';
import 'package:maple_harvest_app/core/core.dart';

class CustomerResponse extends MutationResponse {
  static const _typeName = 'UpdateCustomer';

  static const idKey = 'id';
  static const emailAddressKey = 'emailAddress';
  static const phoneKey = 'phoneNumber';
  static const titleKey = 'title';
  static const firstNameKey = 'firstName';
  static const lastNameKey = 'lastName';

  final String id;

  final String emailAddress;

  final String phone;

  final String title;

  final String firstName;

  final String lastName;

  final bool isAnonymous;

  const CustomerResponse({
    this.id = '',
    this.emailAddress = '',
    this.phone = '',
    this.title = '',
    this.firstName = '',
    this.lastName = '',
    this.isAnonymous = false,
  }) : super(typeName: _typeName);

  factory CustomerResponse.fromMap(Map<String, dynamic> map) =>
      CustomerResponse(
        id: map.getString(idKey),
        emailAddress: map.getString(emailAddressKey),
        phone: map.getString(phoneKey),
        title: map.getString(titleKey),
        firstName: map.getString(firstNameKey),
        lastName: map.getString(lastNameKey),
      );

  factory CustomerResponse.fromActiveCustomerData(Map<String, dynamic>? data) {
    const key = 'activeCustomer';
    if ((data?.isEmpty ?? true) || (!data!.isValidKey(key))) {
      throw UserNotFoundException(message: 'userNotFoundMsg'.tr());
    }

    return CustomerResponse.fromMap(data[key]);
  }

  CustomerResponse copyWith({
    String? id,
    String? emailAddress,
    String? phone,
    String? title,
    String? firstName,
    String? lastName,
    bool? isAnonymous,
  }) {
    return CustomerResponse(
      id: id ?? this.id,
      emailAddress: emailAddress ?? this.emailAddress,
      phone: phone ?? this.phone,
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  Map<String, FieldNodeModel> get selectedFields =>
      GraphQLModel.generateFields([
        idKey,
        emailAddressKey,
        phoneKey,
        titleKey,
        firstNameKey,
        lastNameKey,
      ]);
}
