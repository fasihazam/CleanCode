import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

class HomePage extends BaseHookWidget {
  const HomePage({
    super.key,
    required this.location,
  });

  final String location;

  @override
  Widget buildWidget(BuildContext context) {
    final children = BottomNavItem.values.map((e) => e.child).toList();

    useEffect(() {
      final cubit = context.read<HomeCubit>();
      cubit.initializeLocation(location);
      return null;
    }, []);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return BaseScaffoldWidget(
          appBar: AppBarWidget(
            context: context,
            title: BlocBuilder<BottomNavCubit, BottomNavState>(
              builder: (context, state) {
                return TextWidget(state.currentItem.label);
              },
            ),
            actions: [
              BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  if (state.isAnonymous) return const SizedBox.shrink();

                  return GestureDetector(
                    child: const Icon(Icons.logout),
                    onTap: () async => await context.read<UserCubit>().logout(),
                  );
                },
              ),
              IconButton(
                onPressed: () => context.goToNotifications(),
                icon: const AssetImageWidget(
                  path: Assets.imagesAlertDot,
                ),
              ),
            ],
          ),
          body: BlocBuilder<BottomNavCubit, BottomNavState>(
            builder: (context, state) {
              return LazyIndexedWidget(
                index: state.currentItem.index,
                children: children,
              );
            },
          ),
        );
      },
    );
  }
}
