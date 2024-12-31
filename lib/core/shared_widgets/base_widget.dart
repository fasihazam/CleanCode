import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maple_harvest_app/core/core.dart';

abstract class BaseStatefulWidget extends StatefulWidget {
  const BaseStatefulWidget({super.key});
}

abstract class BaseState<T extends BaseStatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await sl<AnalyticsService>().logScreenEvent(context);
    });
  }
}

abstract class BaseStatelessWidget extends StatelessWidget {
  const BaseStatelessWidget({super.key});

  void logScreenView(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await sl<AnalyticsService>().logScreenEvent(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    logScreenView(context);
    return buildWidget(context);
  }

  Widget buildWidget(BuildContext context);
}

abstract class BaseHookWidget extends HookWidget {
  const BaseHookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await sl<AnalyticsService>().logScreenEvent(context);
      });
      return null;
    }, []);

    return buildWidget(context);
  }

  Widget buildWidget(BuildContext context);
}
