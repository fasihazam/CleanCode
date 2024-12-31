import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/core.dart';

class FavoriteWidget extends BaseStatelessWidget {
  const FavoriteWidget({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Center(
      child: TextWidget('favorite'.tr()),
    );
  }
}
