import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:maple_harvest_app/core/core.dart';

extension GraphQLClientExtension on GraphQLClient {
  GraphQLClient withLogging() {
    // Store link reference to avoid multiple access
    final currentLink = link;

    if (!kDebugMode || currentLink is LoggedLink) {
      return this;
    }

    final logger = GraphQLLogger();
    return GraphQLClient(
      cache: cache,
      defaultPolicies: defaultPolicies,
      link: LoggedLink(logger, currentLink),
    );
  }
}
