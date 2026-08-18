import 'package:ecommerce_app/providers/product_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final filterNotifier = ref.read(filterProvider.notifier);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: filterNotifier.setSearchQuery,
          ),
        ),
        SizedBox(
          height: 40,
          child: categoriesAsync.when(
            data: (categories) => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _CategoryChip(
                  label: 'Toutes',
                  selected: filter.category == null,
                  onTap: () => filterNotifier.setCategory(null),
                ),
                const SizedBox(width: 6),
                ...categories.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _CategoryChip(
                        label: c,
                        selected: filter.category == c,
                        onTap: () => filterNotifier.setCategory(c),
                      ),
                    )),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: DropdownButton<SortOption>(
              value: filter.sortOption,
              underline: const SizedBox.shrink(),
              items: SortOption.values
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option.label, style: const TextStyle(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (option) {
                if (option != null) filterNotifier.setSortOption(option);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}