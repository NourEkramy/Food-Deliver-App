import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/util/money.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../model/order.dart';

/// The user's placed orders.
///
/// The design splits these into Ongoing and History tabs. `/Order` returns no
/// status field, so there is nothing to split on — one list is the honest
/// rendering. "Track Order" is left out for the same reason; "Cancel" stays,
/// because `DELETE /Order/master/{id}` genuinely works.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.myOrders),
            Expanded(
              child: BlocBuilder<OrdersCubit, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading || state is OrdersInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is OrdersError) {
                    return _Error(
                      message: state.message,
                      onRetry: context.read<OrdersCubit>().load,
                    );
                  }

                  if (state is! OrdersLoaded) return const SizedBox();

                  if (state.orders.isEmpty) {
                    return _Empty(message: l10n.ordersEmpty);
                  }

                  return RefreshIndicator(
                    onRefresh: context.read<OrdersCubit>().load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: state.orders.length,
                      itemBuilder: (context, index) {
                        final order = state.orders[index];
                        return _OrderCard(
                          order: order,
                          isCancelling: state.cancellingId == order.id,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final bool isCancelling;

  const _OrderCard({required this.order, required this.isCancelling});

  Future<void> _confirmCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OrdersCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cancelOrder),
        content: Text(l10n.orderNumber(order.id)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.keepCart),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) await cubit.cancel(order.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  // With no restaurant name the order number becomes the
                  // title, rather than labelling every order "My Orders".
                  order.restaurantName ?? l10n.orderNumber(order.id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (order.restaurantName != null)
                Text(
                  l10n.orderNumber(order.id),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (order.total != null) ...[
                Text(
                  formatPrice(context, order.total!),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('|', style: TextStyle(color: AppColors.divider)),
                const SizedBox(width: 10),
              ],
              // Hidden at zero: "0 items" states something false when the
              // payload simply did not include the lines.
              if (order.itemCount > 0)
                Text(
                  l10n.itemCount(order.itemCount),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              if (order.placedAt != null) ...[
                const Spacer(),
                Text(
                  DateFormat.yMMMd(
                    Localizations.localeOf(context).toString(),
                  ).format(order.placedAt!),
                  style: const TextStyle(color: AppColors.hint, fontSize: 12),
                ),
              ],
            ],
          ),
          if (order.lines.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              order.lines
                  .map((line) => '${line.quantity}× ${line.itemName}')
                  .join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isCancelling ? null : () => _confirmCancel(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isCancelling
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.cancelOrder),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;

  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 52,
              color: AppColors.hint,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _Error({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 44, color: AppColors.hint),
          const SizedBox(height: 16),
          Text(
            l10n.somethingWentWrong,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
