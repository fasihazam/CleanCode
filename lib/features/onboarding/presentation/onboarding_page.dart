import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

class OnboardingPage extends BaseHookWidget {
  const OnboardingPage({super.key});

  static const _tag = 'OnboardingPage';

  @override
  Widget buildWidget(BuildContext context) {
    final currentPageIndex = useState(0);
    final pageController = usePageController();
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: Dimens.defaultAnimDurationMillis),
    );

    final onboardings = useMemoized(() => [
          OnboardingModel(
            heading: 'onboarding1Heading'.tr(),
            subHeading: 'onboarding1SubHeading'.tr(),
            imagePath: Assets.imagesOnboarding1,
          ),
          OnboardingModel(
            heading: 'onboarding2Heading'.tr(),
            subHeading: 'onboarding2SubHeading'.tr(),
            imagePath: Assets.imagesOnboarding2,
          ),
        ]);

    useEffect(() {
      void handlePageChange() {
        if (pageController.hasClients) {
          final newIndex = pageController.page!.round();
          if (newIndex != currentPageIndex.value) {
            currentPageIndex.value = newIndex;
            if (newIndex == 1) {
              animationController.forward();
            } else {
              animationController.reverse();
            }
          }
        }
      }

      pageController.addListener(handlePageChange);

      return () {
        pageController.removeListener(handlePageChange);
      };
    }, []);

    return Scaffold(
      body: SafeAreaColumnWidget(
        padding: EdgeInsets.symmetric(
          vertical: 10.h,
        ),
        children: [
          _buildProgressIndicators(
            context,
            onboardings.length,
            currentPageIndex.value,
          ),
          SpacerWidget(height: 10.h),
          _buildPageView(
            context,
            onboardings,
            pageController,
            animationController,
          ),
          _buildActionButton(context, currentPageIndex.value, pageController),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(
      BuildContext context, int length, int currentPage) {
    return Row(
      children: List.generate(
        length,
        (index) => Expanded(
          child: DividerWidget(
            margin: EdgeInsets.only(
              left: index == 0 ? 30.w : 5.w,
              right: index == length - 1 ? 30.w : 5.w,
            ),
            color: context.colorScheme.primary
                .withOpacity(index == currentPage || index == 0 ? 1 : 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
          BuildContext context, int value, PageController pageController) =>
      ElevatedButtonWidget(
        title: value == 1 ? 'getStarted'.tr() : 'next'.tr(),
        onPressed: () async {
          if (value == 1) {
            try {
              await sl<PrefsUtils>().setVisitedOnboarding();
              await sl<AnalyticsService>()
                  .logEvent(AnalyticsEventType.onboardingComplete);
            } catch (e) {
              sl<LoggerUtils>()
                  .logError(_tag, 'Error setting onboarding visited');
              await sl<CrashlyticsService>().recordError(
                e,
                StackTrace.current,
                fatal: false,
                reason: 'Failed to set onboarding visited',
              );
            }
            if (!context.mounted) return;
            context.goToLocateMeScreen();
          } else {
            await sl<AnalyticsService>()
                .logEvent(AnalyticsEventType.onboardingStart);
            pageController.nextPage(
              duration: const Duration(
                  milliseconds: Dimens.defaultAnimDurationMillis),
              curve: Curves.easeInOut,
            );
          }
        },
      );

  Widget _buildPageView(
    BuildContext context,
    List<OnboardingModel> onboardings,
    PageController pageController,
    AnimationController animationController,
  ) =>
      Expanded(
        child: PageView.builder(
          controller: pageController,
          itemCount: onboardings.length,
          itemBuilder: (context, index) => OnboardingContentWidget(
            header: OnboardingHeaderWidget(
              text: onboardings[index].heading,
              animationController: animationController,
            ),
            onboarding: onboardings[index],
          ),
        ),
      );
}
