import 'package:maple_harvest_app/core/core.dart';

class CustomerRequest extends GraphQLModel {
  static const idKey = 'id';
  static const emailKey = 'emailAddress';
  static const phoneKey = 'phoneNumber';
  static const titleKey = 'title';
  static const firstNameKey = 'firstName';
  static const lastNameKey = 'lastName';
  static const createdAtKey = 'createdAt';
  static const updatedAtKey = 'updatedAt';
  static const customFieldsKey = 'customFields';
  static const addressesKey = 'addresses';
  static const tokenKey = 'token';

  static const inputKey = 'input';

  final String id;
  final String email;
  final String phone;
  final String title;
  final String firstName;
  final String lastName;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> customFields;
  final List<AddressModel> addresses;
  final String token;

  CustomerRequest({
    this.id = '',
    this.email = '',
    this.phone = '',
    this.title = '',
    this.firstName = '',
    this.lastName = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.customFields = const {},
    this.addresses = const [],
    this.token = '',
  });

  @override
  Map<String, FieldNodeModel> get selectedFields {
    final fields = <String, FieldNodeModel>{};

    final stringFields = toJson().removeEmptyOrNull;

    fields.addAll(
      Map.fromEntries(
        stringFields.entries.map((entry) => MapEntry(
              entry.key,
              FieldNodeModel(name: entry.key),
            )),
      ),
    );

    if (customFields.isNotEmpty) {
      fields[customFieldsKey] = FieldNodeModel(name: customFieldsKey);
    }

    if (addresses.isNotEmpty) {
      fields[addressesKey] = FieldNodeModel(
        name: addressesKey,
        children: AddressModel.defaultFields,
      );
    }

    return fields;
  }

  static Map<String, FieldNodeModel> get defaultFields =>
      GraphQLModel.generateFields([
        idKey,
        emailKey,
        phoneKey,
        titleKey,
        firstNameKey,
        lastNameKey,
        createdAtKey,
        updatedAtKey,
      ]);

  factory CustomerRequest.withToken(String token) =>
      CustomerRequest(token: token);

  Map<String, dynamic> toJson() => {
        idKey: id,
        emailKey: email,
        phoneKey: phone,
        titleKey: title,
        firstNameKey: firstName,
        lastNameKey: lastName,
        createdAtKey: createdAt,
        updatedAtKey: updatedAt,
        customFieldsKey: customFields,
        tokenKey: token,
        addressesKey: [],
      };

  Map<String, dynamic> toVariables() => {
        inputKey: toJson().removeEmptyOrNull,
      };
}

class AddressModel extends GraphQLModel {
  static const idKey = 'id';
  static const createdAtKey = 'createdAt';
  static const updatedAtKey = 'updatedAt';
  static const fullNameKey = 'fullName';
  static const companyKey = 'company';
  static const streetLine1Key = 'streetLine1';
  static const streetLine2Key = 'streetLine2';
  static const cityKey = 'city';
  static const provinceKey = 'province';
  static const postalCodeKey = 'postalCode';
  static const phoneNumberKey = 'phoneNumber';
  static const defaultShippingAddressKey = 'defaultShippingAddress';
  static const defaultBillingAddressKey = 'defaultBillingAddress';
  static const countryKey = 'country';
  static const customFieldsKey = 'customFields';

  final String id;
  final String createdAt;
  final String updatedAt;
  final String fullName;
  final String company;
  final String streetLine1;
  final String streetLine2;
  final String city;
  final String province;
  final String postalCode;
  final String phoneNumber;
  final bool defaultShippingAddress;
  final bool defaultBillingAddress;
  final CountryModel? country;
  final AddressCustomFieldsModel? customFields;

  AddressModel({
    this.id = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.fullName = '',
    this.company = '',
    this.streetLine1 = '',
    this.streetLine2 = '',
    this.city = '',
    this.province = '',
    this.postalCode = '',
    this.phoneNumber = '',
    this.defaultShippingAddress = false,
    this.defaultBillingAddress = false,
    this.country,
    this.customFields,
  });

  @override
  Map<String, FieldNodeModel> get selectedFields {
    final fields = <String, FieldNodeModel>{};

    final simpleFields = {
      idKey: id,
      createdAtKey: createdAt,
      updatedAtKey: updatedAt,
      fullNameKey: fullName,
      companyKey: company,
      streetLine1Key: streetLine1,
      streetLine2Key: streetLine2,
      cityKey: city,
      provinceKey: province,
      postalCodeKey: postalCode,
      phoneNumberKey: phoneNumber,
      defaultShippingAddressKey: defaultShippingAddress,
      defaultBillingAddressKey: defaultBillingAddress,
    };

    fields.addAll(
      Map.fromEntries(
        simpleFields.entries
            .where((entry) =>
                entry.value is! String || (entry.value as String).isNotEmpty)
            .map((entry) => MapEntry(
                  entry.key,
                  FieldNodeModel(name: entry.key),
                )),
      ),
    );

    if (country != null) {
      fields[countryKey] = FieldNodeModel(
        name: countryKey,
        children: CountryModel.defaultFields,
      );
    }

    if (customFields != null) {
      fields[customFieldsKey] = FieldNodeModel(
        name: customFieldsKey,
        children: AddressCustomFieldsModel.defaultFields,
      );
    }

    return fields;
  }

  static Map<String, FieldNodeModel> get defaultFields => {
        ...GraphQLModel.generateFields([
          idKey,
          createdAtKey,
          updatedAtKey,
          fullNameKey,
          companyKey,
          streetLine1Key,
          streetLine2Key,
          cityKey,
          provinceKey,
          postalCodeKey,
          phoneNumberKey,
          defaultShippingAddressKey,
          defaultBillingAddressKey,
        ]),
        countryKey: FieldNodeModel(
          name: countryKey,
          children: CountryModel.defaultFields,
        ),
        customFieldsKey: FieldNodeModel(
          name: customFieldsKey,
          children: AddressCustomFieldsModel.defaultFields,
        ),
      };
}

class CountryModel extends GraphQLModel {
  static const idKey = 'id';
  static const createdAtKey = 'createdAt';
  static const updatedAtKey = 'updatedAt';
  static const languageCodeKey = 'languageCode';
  static const codeKey = 'code';
  static const typeKey = 'type';
  static const nameKey = 'name';
  static const enabledKey = 'enabled';
  static const parentIdKey = 'parentId';
  static const customFieldsKey = 'customFields';
  static const parentKey = 'parent';
  static const translationsKey = 'translations';

  final String id;
  final String createdAt;
  final String updatedAt;
  final String languageCode;
  final String code;
  final String type;
  final String name;
  final bool enabled;
  final String parentId;
  final Map<String, dynamic> customFields;
  final CountryModel? parent;
  final List<CountryTranslationModel> translations;

  CountryModel({
    this.id = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.languageCode = '',
    this.code = '',
    this.type = '',
    this.name = '',
    this.enabled = false,
    this.parentId = '',
    this.customFields = const {},
    this.parent,
    this.translations = const [],
  });

  @override
  Map<String, FieldNodeModel> get selectedFields => defaultFields;

  static Map<String, FieldNodeModel> get defaultFields => {
        ...GraphQLModel.generateFields([
          idKey,
          createdAtKey,
          updatedAtKey,
          languageCodeKey,
          codeKey,
          typeKey,
          nameKey,
          enabledKey,
          parentIdKey,
          customFieldsKey,
        ]),
        parentKey: FieldNodeModel(
          name: parentKey,
          children: GraphQLModel.generateFields([
            idKey,
            createdAtKey,
            updatedAtKey,
            languageCodeKey,
            codeKey,
            typeKey,
            nameKey,
            enabledKey,
            parentIdKey,
          ]),
        ),
        translationsKey: FieldNodeModel(
          name: translationsKey,
          children: CountryTranslationModel.defaultFields,
        ),
      };
}

class CountryTranslationModel extends GraphQLModel {
  static const idKey = 'id';
  static const createdAtKey = 'createdAt';
  static const updatedAtKey = 'updatedAt';
  static const languageCodeKey = 'languageCode';
  static const nameKey = 'name';

  final String id;
  final String createdAt;
  final String updatedAt;
  final String languageCode;
  final String name;

  CountryTranslationModel({
    this.id = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.languageCode = '',
    this.name = '',
  });

  @override
  Map<String, FieldNodeModel> get selectedFields => defaultFields;

  static Map<String, FieldNodeModel> get defaultFields =>
      GraphQLModel.generateFields([
        idKey,
        createdAtKey,
        updatedAtKey,
        languageCodeKey,
        nameKey,
      ]);
}

class AddressCustomFieldsModel extends GraphQLModel {
  static const latKey = 'lat';
  static const lngKey = 'lng';
  static const placeIdKey = 'placeId';
  static const typeKey = 'type';

  final double lat;
  final double lng;
  final String placeId;
  final String type;

  AddressCustomFieldsModel({
    this.lat = 0.0,
    this.lng = 0.0,
    this.placeId = '',
    this.type = '',
  });

  @override
  Map<String, FieldNodeModel> get selectedFields => defaultFields;

  static Map<String, FieldNodeModel> get defaultFields =>
      GraphQLModel.generateFields([
        latKey,
        lngKey,
        placeIdKey,
        typeKey,
      ]);
}
