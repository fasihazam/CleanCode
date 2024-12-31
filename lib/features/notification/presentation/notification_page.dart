import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maple_harvest_app/core/core.dart';

class NotificationPage extends BaseHookWidget {
  const NotificationPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) async => await sl<PermissionUseCases>().requestNotificationPermission());
      return null;
    }, []);

    return Scaffold(
      appBar: AppBarWidget(
        context: context,
        title: TextWidget('notifications'.tr()),
      ),
      body: Center(
        child: TextWidget('notifications'.tr()),
      ),
    );
  }
}
