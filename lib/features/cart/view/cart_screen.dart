import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/util/money.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../model/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: BlocConsumer<CartCubit, CartState>(
        listenWhen: (previous, current) => current.justPlacedOrder,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.orderPlaced)));
          Navigator.of(context).maybePop();
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: l10n.cart,
                  onDark: true,
                  trailing: state.isEmpty
                      ? null
                      : TextButton(
                          onPressed: context.read<CartCubit>().clear,
                          child: Text(l10n.clearCart),
                        ),
                ),
                Expanded(
                  child: state.isEmpty
                      ? const _EmptyCart()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                          itemCount: state.items.length,
                          itemBuilder: (context, index) =>
                              _CartLine(line: state.items[index]),
                        ),
                ),
                if (state.isNotEmpty) _Checkout(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 56,
              color: Colors.white24,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.cartEmpty,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cartEmptyHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.hint, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  final CartItem line;

  const _CartLine({required this.line});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cart = context.read<CartCubit>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 100,
              width: 100,
              child: AppNetworkImage(
                url: line.item.imageUrl,
                fallbackIconSize: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        line.item.itemName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.removeItem,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.cancel,
                        color: AppColors.error,
                        size: 22,
                      ),
                      onPressed: () => cart.remove(line.item.itemID),
                    ),
                  ],
                ),
                Text(
                  formatPrice(context, line.lineTotal),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: QuantityStepper(
                    quantity: line.quantity,
                    onDark: true,
                    // 0, not 1: stepping below one removes the line, which is
                    // what the red cross does too.
                    minimum: 0,
                    onIncrement: () => cart.increment(line.item.itemID),
                    onDecrement: () => cart.decrement(line.item.itemID),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Checkout extends StatelessWidget {
  final CartState state;

  const _Checkout({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.deliveryAddress,
            style: const TextStyle(
              color: AppColors.hint,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          // Shown but not editable: there is no address endpoint, so offering
          // an edit control would imply a feature that does not exist.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              l10n.setDeliveryAddress,
              style: const TextStyle(color: AppColors.hint, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '${l10n.totalLabel}:',
                style: const TextStyle(
                  color: AppColors.hint,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formatPrice(context, state.total),
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
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            ErrorBanner(message: state.errorMessage!),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isPlacing
                  ? null
                  : context.read<CartCubit>().placeOrder,
              child: state.isPlacing
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(l10n.placeOrder),
            ),
          ),
        ],
      ),
    );
  }
}
