import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/product.dart';
import '../../../providers/cart_notifier.dart';
import '../../../providers/dependencies.dart';
import '../../../providers/pos_providers.dart';

class PosPage extends ConsumerWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoogli Bakery POS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Recent orders',
            onPressed: () => _showOrdersSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Export CSV',
            onPressed: () => ref.read(posRepositoryProvider).exportOrdersCsv(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Padding(
            padding: const EdgeInsets.all(12),
            child: isWide
                ? Row(
                    children: [
                      const SizedBox(
                        width: 220,
                        child: _CategoriesPane(),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: _ProductsPane()),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 320,
                        child: CartPane(cart: cart),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const SizedBox(height: 80, child: _CategoriesPane()),
                      const SizedBox(height: 12),
                      const Expanded(child: _ProductsPane()),
                      const SizedBox(height: 12),
                      CartPane(cart: cart),
                    ],
                  ),
          );
        },
      ),
    );
  }

  void _showOrdersSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _RecentOrdersSheet(),
    );
  }
}

class _CategoriesPane extends ConsumerWidget {
  const _CategoriesPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedId = ref.watch(selectedCategoryIdProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: categories.when(
          data: (items) => ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: selectedId == null,
                onSelected: (_) =>
                    ref.read(selectedCategoryIdProvider.notifier).state = null,
              ),
              const SizedBox(width: 8),
              ...items.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c.name),
                    selected: selectedId == c.id,
                    onSelected: (_) => ref
                        .read(selectedCategoryIdProvider.notifier)
                        .state = c.id,
                  ),
                ),
              ),
            ],
          ),
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Center(child: Text('Error loading categories: $e')),
        ),
      ),
    );
  }
}

class _ProductsPane extends ConsumerWidget {
  const _ProductsPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final crossAxisCount = MediaQuery.sizeOf(context).width > 1000 ? 3 : 2;
    return products.when(
      data: (items) => GridView.builder(
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (context, index) {
          final product = items[index];
          return _ProductTile(product: product);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: product.isAvailable
            ? () => ref.read(cartProvider.notifier).add(product)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    formatCurrency(product.price),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartPane extends ConsumerWidget {
  const CartPane({required this.cart});

  final CartState cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Ticket',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: cart.isEmpty
                  ? const Center(child: Text('Add items to begin'))
                  : ListView.separated(
                      itemCount: cart.lines.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final line = cart.lines.values.elementAt(index);
                        return _CartLineTile(line: line);
                      },
                    ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _TotalsRow(label: 'Subtotal', value: cart.subtotal),
            _TotalsRow(label: 'Tax', value: cart.tax),
            _TotalsRow(label: 'Total', value: cart.total, isEmphasis: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.point_of_sale),
                    label: const Text('Checkout (Cash)'),
                    onPressed: cart.isEmpty
                        ? null
                        : () async {
                            try {
                              final order = await ref
                                  .read(cartProvider.notifier)
                                  .checkout();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Order ${order.id ?? ''} saved. Total ${formatCurrency(order.total)}',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Checkout failed: $e')),
                                );
                              }
                            }
                          },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear ticket',
                  onPressed:
                      cart.isEmpty ? null : () => ref.read(cartProvider.notifier).clear(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(line.product.name),
      subtitle: Text(formatCurrency(line.product.price)),
      trailing: SizedBox(
        width: 140,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => ref.read(cartProvider.notifier).removeOne(line.product),
            ),
            Text('${line.quantity}'),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => ref.read(cartProvider.notifier).add(line.product),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.label,
    required this.value,
    this.isEmphasis = false,
  });

  final String label;
  final double value;
  final bool isEmphasis;

  @override
  Widget build(BuildContext context) {
    final style = isEmphasis
        ? Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.titleMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(formatCurrency(value), style: style),
        ],
      ),
    );
  }
}

class _RecentOrdersSheet extends ConsumerWidget {
  const _RecentOrdersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(recentOrdersProvider);
    final format = DateFormat('MMM d, h:mm a');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Orders',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            orders.when(
              data: (items) => items.isEmpty
                  ? const Text('No orders yet')
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final order = items[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            'Order #${order.id ?? ''} • ${format.format(order.createdAt)}',
                          ),
                          subtitle: Text(
                            '${order.items.length} items • ${order.paymentMethod.toUpperCase()}',
                          ),
                          trailing: Text(formatCurrency(order.total)),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading orders: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
