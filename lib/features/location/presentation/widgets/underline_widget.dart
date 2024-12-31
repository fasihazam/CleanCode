import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/core.dart';

Widget buildTextWithCustomUnderline({
  required String text,
  required BuildContext context,
  required Color color,
}) {
  return Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: TextWidget(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: color,
          ),
        ),
      ),
      Positioned(
        bottom: -1.0,
        child: Container(
          width: text.length * 8.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.h),
          ),
        ),
      ),
    ],
  );
}
