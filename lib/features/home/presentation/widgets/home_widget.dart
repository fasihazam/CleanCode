import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

class HomeWidget extends BaseHookWidget {
  const HomeWidget({
    super.key,
  });

  @override
  Widget buildWidget(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();
    final currentLocation = useState<String?>(null);

    useEffect(() {
      final subscription = homeCubit.stream.listen((state) {
        if (state is HomeLocationLoaded) {
          currentLocation.value = state.location;
        }
      });
      return subscription.cancel;
    }, [homeCubit]);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        children: [
          // Logo
          Container(
            height: 55.h,
            width: 55.w,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: AppColors.alertMsg,
                  offset: Offset(0, 0),
                  blurRadius: 10,
                  spreadRadius: .1,
                )
              ],
              color: AppColors.onPrimary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Center(
              child: AssetImageWidget(
                path: Assets.imagesLogo,
              ),
            ),
          ),
          SpacerWidget(width: 10.w),
          // Location Selector
          Expanded(
            child: InkWell(
              onTap: () {
                context.goToLocationScreen(true);
              },
              child: SizedBox(
                height: 55.h,
                child: Column(
                  children: [
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextWidget(
                              'Current Location'.tr(),
                              style: context.textTheme.labelSmall,
                            ),
                          ),
                          SpacerWidget(width: 7.w),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: AssetImageWidget(
                              path: Assets.imagesDropDownIcon,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: TextWidget(
                          currentLocation.value?.isNotEmpty ?? false
                              ? currentLocation.value!
                              : 'noLocationsFound'.tr(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
