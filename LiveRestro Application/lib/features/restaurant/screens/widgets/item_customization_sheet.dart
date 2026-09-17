import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../models/menu_item_model.dart';
import '../../models/restaurant_model.dart';
import '../../../cart/models/cart_item_model.dart';
import '../../../cart/providers/cart_provider.dart';

class ItemCustomizationSheet extends ConsumerStatefulWidget {
  final MenuItemModel item;
  final RestaurantModel restaurant;

  const ItemCustomizationSheet({
    super.key,
    required this.item,
    required this.restaurant,
  });

  @override
  ConsumerState<ItemCustomizationSheet> createState() => _ItemCustomizationSheetState();
}

class _ItemCustomizationSheetState extends ConsumerState<ItemCustomizationSheet> {
  final Map<String, CustomizationOption> _selectedSingleOptions = {};
  final List<CustomizationOption> _selectedMultiOptions = [];
  final _instructionsController = TextEditingController();

  bool _isSingleChoiceGroup(MenuItemCustomization custom) {
    final title = custom.title.toLowerCase();
    return custom.isRequired ||
        title.contains('choose') ||
        title.contains('size') ||
        title.contains('crust') ||
        title.contains('patty') ||
        title.contains('type');
  }

  @override
  void initState() {
    super.initState();
    for (final custom in widget.item.customizations) {
      if (_isSingleChoiceGroup(custom) && custom.options.isNotEmpty) {
        _selectedSingleOptions[custom.title] = custom.options.first;
      }
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double total = widget.item.price;
    for (final opt in _selectedSingleOptions.values) {
      total += opt.extraPrice;
    }
    for (final opt in _selectedMultiOptions) {
      total += opt.extraPrice;
    }
    return total;
  }

  void _onAddToCart() {
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartState = ref.read(cartProvider);

    if (cartState.restaurantId != null && cartState.restaurantId != widget.restaurant.id) {
      cartNotifier.clearCart();
    }

    final selectedOptionsSummary = [
      ..._selectedSingleOptions.values.map((o) => o.name),
      ..._selectedMultiOptions.map((o) => o.name),
    ];

    cartNotifier.addItem(
      CartItemModel(
        menuItem: widget.item,
        restaurantId: widget.restaurant.id,
        restaurantName: widget.restaurant.name,
        selectedOption: selectedOptionsSummary.isNotEmpty ? selectedOptionsSummary.join(', ') : null,
        extraPrice: _totalPrice - widget.item.price,
        specialInstructions: _instructionsController.text.trim().isNotEmpty ? _instructionsController.text.trim() : null,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.flame100,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Dish Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.flame50,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.item.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.item.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Center(
                                child: HugeIcon(
                                  icon: AppIcons.food,
                                  color: AppColors.flameMedium,
                                  size: 26,
                                ),
                              ),
                            )
                          : const Center(
                              child: HugeIcon(
                                icon: AppIcons.food,
                                color: AppColors.flameMedium,
                                size: 26,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: AppTypography.headlineSmall.copyWith(
                              color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '₹${widget.item.price.toInt()}',
                            style: AppTypography.priceTagSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.flame100, height: 1),

              // Options Scroll Area
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final custom in widget.item.customizations) ...[
                        Row(
                          children: [
                            Text(
                              custom.title,
                              style: AppTypography.labelLarge.copyWith(
                                color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _isSingleChoiceGroup(custom) ? AppColors.flame : AppColors.mango,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _isSingleChoiceGroup(custom) ? 'Required' : 'Optional',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_isSingleChoiceGroup(custom))
                          ...custom.options.map((opt) {
                            final isSelected = _selectedSingleOptions[custom.title]?.name == opt.name;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedSingleOptions[custom.title] = opt;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: opt.name,
                                      groupValue: _selectedSingleOptions[custom.title]?.name,
                                      activeColor: AppColors.flame,
                                      onChanged: (_) {
                                        setState(() {
                                          _selectedSingleOptions[custom.title] = opt;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        opt.name,
                                        style: AppTypography.labelMedium.copyWith(
                                          color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (opt.extraPrice > 0)
                                      Text(
                                        '+₹${opt.extraPrice.toInt()}',
                                        style: AppTypography.priceTagSmall,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          })
                        else
                          ...custom.options.map((opt) {
                            final isSelected = _selectedMultiOptions.any((o) => o.name == opt.name);
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedMultiOptions.removeWhere((o) => o.name == opt.name);
                                  } else {
                                    _selectedMultiOptions.add(opt);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      activeColor: AppColors.flame,
                                      onChanged: (_) {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedMultiOptions.removeWhere((o) => o.name == opt.name);
                                          } else {
                                            _selectedMultiOptions.add(opt);
                                          }
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        opt.name,
                                        style: AppTypography.labelMedium.copyWith(
                                          color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (opt.extraPrice > 0)
                                      Text(
                                        '+₹${opt.extraPrice.toInt()}',
                                        style: AppTypography.priceTagSmall,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        const SizedBox(height: 14),
                      ],

                      // Special Instructions
                      Text(
                        'Special instructions',
                        style: AppTypography.labelLarge.copyWith(
                          color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _instructionsController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'e.g. Less spicy, extra sauce on the side...',
                          hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.txtMuted),
                          filled: true,
                          fillColor: isDark ? AppColors.darkBg : AppColors.flame50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.darkBorder : AppColors.flame100,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.darkBorder : AppColors.flame100,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.flame, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Bottom CTA
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.flame100,
                      width: 1,
                    ),
                  ),
                ),
                child: GradientButton(
                  label: 'Add Item  ·  ₹${_totalPrice.toInt()}',
                  onTap: _onAddToCart,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
