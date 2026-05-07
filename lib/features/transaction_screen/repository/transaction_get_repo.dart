import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/model/paginated_response.dart';
import 'package:synqer_io/features/transaction_screen/model/transaction_model.dart';

class TransactionGetRepo {
  final DioMethodsService dio;
  const TransactionGetRepo({required this.dio});

  Future<PaginatedResponse<TransactionDetailsModel>> fetchTransactions({
    required int page,
    required int limit,
    String? serviceType,
    String? transactionType,
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await dio.get(
      APIsEndPoints.getTransactions,
      requiresAuth: true,
      queryParameters: {
        "page": page,
        "limit": limit,
        "service": serviceType,
        "type": transactionType,
        "from": dateFrom,
        "to": dateTo,
      },
    );

    final transactions = parseTransactions(response['data']);
    bool hasMore =
        ((response['page'] ?? 1) * (response['limit'] ?? 0)) <
        (response['total'] ?? 0);

    return PaginatedResponse(
      success: response['success'],
      message: response['success'].toString() == 'true'
          ? 'Transactions fetch successfull.'
          : 'Failed to fetch transactions',
      page: response['page'],
      limit: response['limit'],
      totalItems: response['total'],
      totalPages: response['pages'],
      hasMore: hasMore,
      data: transactions,
    );
  }
}

List<TransactionDetailsModel> parseTransactions(dynamic json) {
  return List<TransactionDetailsModel>.from(
    json.map((x) => TransactionDetailsModel.fromJson(x)),
  );
}
