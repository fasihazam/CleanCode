import 'dart:convert';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:maple_harvest_app/core/core.dart';

class SignupRequest extends Equatable {
  static const String emailAddressKey = 'emailAddress';
  static const String titleKey = 'title';
  static const String firstNameKey = 'firstName';
  static const String lastNameKey = 'lastName';
  static const String phoneNumberKey = 'phoneNumber';
  static const String passwordKey = 'password';
  static const String inputKey = 'input';

  // for anonymous email generation
  static const String _domain = "lieferking.info";

  final String emailAddress;

  final String title;

  final String firstName;

  final String lastName;

  final String phoneNumber;

  final String password;

  SignupRequest({
    required this.emailAddress,
    this.title = '',
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    required this.password,
  })  : assert(emailAddress.isNotEmpty, 'emptyEmailMsg'.tr()),
        assert(password.isNotEmpty, 'emptyPassMsg'.tr());

  factory SignupRequest.createAnonymous() => SignupRequest(
        emailAddress: _generateEmail(),
        password: _generatePassword(),
      );

  static String _generateEmail() {
    try {
      final random = Random.secure();
      final values = List<int>.generate(30, (i) => random.nextInt(256));
      final encoded = base64Url.encode(values);
      final emailPrefix = encoded.substring(0, 40);
      return "$emailPrefix.anonym@$_domain";
    } catch (e) {
      rethrow;
    }
  }

  static String _generatePassword({int length = 20}) {
    const chars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()_+-=[]{}|;:,.<>?`~";
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Map<String, dynamic> toVariables() => {
        inputKey: {
          emailAddressKey: emailAddress,
          if (title.isNotEmpty) titleKey: title,
          if (firstName.isNotEmpty) firstNameKey: firstName,
          if (lastName.isNotEmpty) lastNameKey: lastName,
          if (phoneNumber.isNotEmpty) phoneNumberKey: phoneNumber,
          passwordKey: password,
        }
      };

  @override
  List<Object> get props => [
        emailAddress,
        title,
        firstName,
        lastName,
        phoneNumber,
        password,
      ];

  @override
  String toString() {
    return 'SignupRequest{emailAddress: $emailAddress, title: $title, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, password: ${password.protect()}';
  }
}
