import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:maple_harvest_app/core/core.dart';

class HeaderCleanupLink extends Link {
  final HeaderManager _headerManager;

  HeaderCleanupLink(this._headerManager);

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    try {
      if (forward == null) {
        throw GeneralException(message: 'forwardLinkIsNullMsg'.tr());
      }

      debugPrint('DEBUG: HeaderCleanupLink - Before request');
      await for (final response in forward(request)) {
        yield response;
      }
    } finally {
      debugPrint('DEBUG: HeaderCleanupLink - Cleaning up headers');
      _headerManager.resetHeaders();
    }
  }
}
