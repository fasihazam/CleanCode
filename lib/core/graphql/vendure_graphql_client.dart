import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:maple_harvest_app/core/core.dart';

class VendureGraphQLClient {
  late final GraphQLClient client;

  final HeaderManager _headerManager;

  final PrefsUtils _prefsUtils;

  final LoggerUtils _logger;

  VendureGraphQLClient({
    required PrefsUtils prefsUtils,
    required LoggerUtils logger,
    required HeaderManager headerManager,
  })  : _prefsUtils = prefsUtils,
        _logger = logger,
        _headerManager = headerManager;

  Future<void> init() async {
    try {
      await loadCachedToken();

      final Link mainChain = _authLink
          .concat(_headerLink)
          .concat(_httpLink)
          .concat(_headerCleanupLink);

      client = GraphQLClient(
        link: mainChain,
        cache: GraphQLCache(),
        defaultPolicies: DefaultPolicies(
          query: Policies(fetch: FetchPolicy.networkOnly),
          mutate: Policies(fetch: FetchPolicy.networkOnly),
        ),
      ).withLogging();

      _logger.log('VendureGraphQLClient', 'Successfully initialized');
    } catch (e, stack) {
      _logger.logError(
          'VendureGraphQLClient', 'Failed to initialize: $e\n$stack');
    }
  }

  AuthLink get _authLink => AuthLink(
        getToken: () async => 'Bearer ${await _prefsUtils.authToken}',
        headerKey: HeaderManager.authHeaderKey,
      );

  HttpLink get _httpLink => HttpLink(
        NetworkConstants.graphqlEndpoint,
        defaultHeaders: HeaderManager.defaultHeaders,
      );

  HeaderLink get _headerLink =>
      HeaderLink(_headerManager, _logger, _prefsUtils, GraphQLLogger());

  HeaderCleanupLink get _headerCleanupLink => HeaderCleanupLink(_headerManager);

  Future<void> loadCachedToken() async {
    try {
      final cachedToken = await _prefsUtils.authToken;
      if (cachedToken.isNotEmpty) {
        _logger.log('VendureGraphQLClient', 'Loaded cached token');
      }
    } catch (e) {
      _logger.logError(
          'VendureGraphQLClient', 'Error loading cached token: $e');
    }
  }

  Future<void> updateHeaders(Map<String, String> headers) async {
    try {
      _headerManager.updateHeaders(headers);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> clearToken() async {
    try {
      _logger.log('VendureGraphQLClient', 'Clearing token');
      await _prefsUtils.setAuthToken(null);
      _headerManager.resetHeaders();
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
