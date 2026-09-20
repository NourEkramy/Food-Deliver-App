import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/util/money.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/cubit/cart_state.dart';
import '../cubit/payment_cubit.dart';
import '../model/payment_method.dart';

/// Choose how to pay, then place the order.
///
/// The payment itself is theatre — there is no payment endpoint — but the
/// button behind it is not: PAY & CONFIRM calls `makeorder`, which places a
/// real order. So a failure here is a real failure and is reported as one.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<CartCubit, CartState>(
      listenWhen: (previous, current) => current.justPlacedOrder,
      listener: (context, state) => AppRoutes.openPaymentSuccess(context),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(title: l10n.payment),
              Expanded(
                child: BlocBuilder<PaymentCubit, PaymentState>(
                  builder: (context, payment) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      children: [
                        for (final method in payment.all)
                          _MethodTile(
                            method: method,
                            selected: payment.selectedId == method.id,
                            onTap: () =>
                                context.read<PaymentCubit>().select(method.id),
                            onDelete: method.kind == PaymentKind.cash
                                ? null
                                : () => context.read<PaymentCubit>().removeCard(
                                    method.id,
                                  ),
                          ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => AppRoutes.openAddCard(context),
                          icon: const Icon(Icons.add, size: 20),
                          label: Text(l10n.addNewCard),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.divider),
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const _PayBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCash = method.kind == PaymentKind.cash;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  isCash ? Icons.payments_outlined : Icons.credit_card,
                  size: 22,
                  color: selected ? AppColors.primary : AppColors.hint,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isCash ? l10n.paymentCash : method.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (!isCash) ...[
                        const SizedBox(height: 2),
                        Text(
                          '•••• •••• •••• ${method.last4}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: AppColors.primary,
                  ),
                if (onDelete != null)
                  IconButton(
                    tooltip: l10n.removeItem,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.hint,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PayBar extends StatelessWidget {
  const _PayBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cart.errorMessage != null) ...[
                ErrorBanner(message: cart.errorMessage!),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Text(
                    l10n.totalLabel,
                    style: const TextStyle(
                      color: AppColors.hint,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatPrice(context, cart.total),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cart.isPlacing || cart.isEmpty
                      ? null
                      : context.read<CartCubit>().placeOrder,
                  child: cart.isPlacing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(l10n.payAndConfirm),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
