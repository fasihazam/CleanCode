import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

class LocateMeScreen extends BaseHookWidget {
  const LocateMeScreen({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    final toastUtils = useMemoized(() => sl<ToastUtils>(), []);

    return BlocProvider(
      create: (_) => LocationSearchCubit(
        sl<LocationRepository>(),
        sl<PrefsUtils>(),
        GetCurrentLocationUseCase(
          sl<PermissionUseCases>(),
          sl<LocationRepository>(),
        ),
      ),
      child: Scaffold(
        body: SafeAreaColumnWidget(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AssetImageWidget(
                    path: Assets.imagesLocateMe,
                    width: context.width,
                    height: context.height * 0.50,
                    fit: BoxFit.contain,
                  ),
                  AssetImageWidget(
                    path: Assets.imagesLocateme,
                    width: context.width,
                    height: context.height * 0.50,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: TextWidget(
                'locationAccess'.tr(),
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: TextWidget(
                'findRestaurants'.tr(),
                textAlign: TextAlign.center,
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.onboardingSubHeading,
                ),
              ),
            ),
            const Spacer(),
            _buildEnterLocationManually(context),
            _buildLocationButton(context, toastUtils),
          ],
        ),
      ),
    );
  }

  Widget _buildEnterLocationManually(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          context.goToLocationScreen(false);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: AssetImageWidget(
                path: Assets.imagesLocationIcon,
                height: 18.h,
                width: 18.w,
              ),
            ),
            TextWidget(
              'enterLocationManually'.tr(),
              style: context.textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton(BuildContext context, ToastUtils toastUtils) {
    return BlocConsumer<LocationSearchCubit, LocationSearchState>(
      listener: (context, state) {
        if (state is CurrentLocationSuccess) {
          if (state.currentLocationDetails?.isEmpty ?? true) {
            toastUtils.showErrorToast('invalidLocation'.tr());
            return;
          }
          context.goToHome({'location': state.currentLocationDetails});
        } else if (state is CurrentLocationException) {
          toastUtils.showErrorToast('locationFetchFailed'.tr());
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: SizedBox(
            width: context.width * 1.w,
            child: state is LocationSearchLoading
                ? Center(
                    child: LoadingWidget.loaderChild(
                      context,
                      size: 40.adaptSize,
                      color: context.colorScheme.primary,
                    ),
                  )
                : ElevatedButtonWidget(
                    title: 'currentLocation'.tr(),
                    onPressed: () => context
                        .read<LocationSearchCubit>()
                        .getCurrentLocation(),
                  ),
          ),
        );
      },
    );
  }
}
