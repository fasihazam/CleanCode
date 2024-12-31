import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/core.dart';

class NotFoundPage extends BaseStatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InfoAlertWidget(
          title: 'oops'.tr(),
          message: 'pageNotFoundMsg'.tr(),
          alertType: AlertType.error,
          buttonTitle: 'goToHome'.tr(),
          onDismiss: () => context.goToHome(),
        ),
      ),
    );
  }
}
