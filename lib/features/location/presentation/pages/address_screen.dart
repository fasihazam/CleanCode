import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

class AddressScreen extends HookWidget {
  final bool isFromHome;

  const AddressScreen({
    super.key,
    this.isFromHome = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocationSearchCubit(
        sl<LocationRepository>(),
        sl(),
        GetCurrentLocationUseCase(
          sl(),
          sl(),
        ),
      ),
      child: _AddressScreenContent(isFromHome: isFromHome),
    );
  }
}

class _AddressScreenContent extends HookWidget {
  final bool isFromHome;

  const _AddressScreenContent({
    required this.isFromHome,
  });

  @override
  Widget build(BuildContext context) {
    final textEditingController = useTextEditingController();
    final toastUtils = sl<ToastUtils>();

    useEffect(() {
      context.read<LocationSearchCubit>().getRecentSearchResults();
      return null; // Cleanup is not needed here
    }, []);

    return Scaffold(
      appBar: AppBarWidget(
        title: BlocBuilder<BottomNavCubit, BottomNavState>(
          builder: (context, state) {
            return TextWidget(
              'title'.tr(),
            );
          },
        ),
        context: context,
      ),
      body: BlocConsumer<LocationSearchCubit, LocationSearchState>(
        listener: (context, state) {
          if (state is CurrentLocationSuccess) {
            final currentLocationDetails = state.currentLocationDetails;
            if (currentLocationDetails?.isEmpty ?? true) {
              toastUtils.showErrorToast('invalidLocation'.tr());
              return;
            }
            context.goToHome({'location': currentLocationDetails});
          } else if (state is NavigateToHomeSuccess) {
            final locationDetails = state.locationDetails;
            if (locationDetails.isEmpty) {
              toastUtils.showErrorToast('invalidLocation'.tr());
              return;
            }
            context.goToHome({'location': locationDetails});
          } else if (state is LocationSearchException) {
            toastUtils.showErrorToast(state.message);
          } else if (state is CurrentLocationException) {
            toastUtils.showErrorToast(state.message);
          }
        },
        builder: (context, googleState) {
          List<LocationModel> suggestions = [];
          if (googleState is LocationSearchSuggestionsLoaded) {
            suggestions = googleState.suggestions;
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 28),
            children: [
              _buildSearchField(context, textEditingController, suggestions),
              SizedBox(height: 20.h),
              _buildCurrentLocationButton(googleState, context),
              SizedBox(height: 10.h),
              _buildSearchResults(context, textEditingController, suggestions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField(
      BuildContext context,
      TextEditingController textEditingController,
      List<LocationModel> suggestions) {
    final cubit = context.read<LocationSearchCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: textEditingController,
          onChanged: (value) {
            if (value.length >= 3) {
              cubit.searchLocation(value);
            }
          },
          decoration: InputDecoration(
            hintText: 'fullAddressHint'.tr(),
            hintStyle: context.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w400, color: Colors.grey),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12.0),
              child: AssetImageWidget(
                path: Assets.imagesLocationIcon,
                height: 20,
                width: 20,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentLocationButton(
      LocationSearchState state, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: state is LocationSearchLoading
          ? Center(
              child: LoadingWidget.loaderChild(
                context,
                size: 40.adaptSize,
                color: context.colorScheme.primary,
              ),
            )
          : Row(
              children: [
                Icon(Icons.my_location_outlined,
                    size: 20.w, color: AppColors.primaryText),
                SpacerWidget(width: 4.w),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.read<LocationSearchCubit>().getCurrentLocation();
                    },
                    child: TextWidget(
                      'useCurrentLocation'.tr(),
                      style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    TextEditingController textEditingController,
    List<LocationModel> suggestions,
  ) {
    final locationCubit = context.read<LocationSearchCubit>();
    final locations = locationCubit.state.locations;

    if (suggestions.isEmpty &&
        locations.isEmpty &&
        textEditingController.text.isEmpty) {
      return _buildPlaceholder(context, 'pleaseEnterAddress'.tr(),
          isCentered: true);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (locations.isNotEmpty)
          _buildRecentSearchesHeader(context, locationCubit),
        if (locations.isNotEmpty || suggestions.isNotEmpty)
          _buildLocationList(context, locationCubit, textEditingController,
              suggestions, isFromHome),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context, String message,
      {bool isCentered = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        height: 200.h,
        child: Center(
          child: TextWidget(
            textAlign: TextAlign.center,
            message,
            style: context.textTheme.labelLarge,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchesHeader(
      BuildContext context, LocationSearchCubit locationCubit) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildTextWithCustomUnderline(
            text: 'recentSearches'.tr(),
            context: context,
            color: Colors.black,
          ),
          InkWell(
            onTap: locationCubit.clearRecentSearchResults,
            child: TextWidget(
              'clearAll'.tr(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationList(
      BuildContext context,
      LocationSearchCubit locationCubit,
      TextEditingController textEditingController,
      List<LocationModel> suggestions,
      bool isFromHome) {
    final locations = isFromHome && textEditingController.text.isEmpty
        ? locationCubit.state.locations
        : suggestions;

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return InkWell(
          onTap: () => locationCubit.navigateToHome(location),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    Assets.imagesBlackIconLoc,
                    height: 18.h,
                    width: 18.w,
                  ),
                ),
                SpacerWidget(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.mainText ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingSubHeading,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        location.secondaryText ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: AppColors.disabled,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
