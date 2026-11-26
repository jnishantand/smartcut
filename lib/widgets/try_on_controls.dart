import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/try_on_style.dart';

class TryOnControls extends StatefulWidget {
  final TryOnStyle? selectedHairStyle;
  final TryOnStyle? selectedBeardStyle;
  final ValueChanged<TryOnStyle?> onSelectHairStyle;
  final ValueChanged<TryOnStyle?> onSelectBeardStyle;
  final VoidCallback onReset;
  final double scale;
  final double offsetY;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onOffsetYChanged;

  const TryOnControls({
    super.key,
    required this.selectedHairStyle,
    required this.selectedBeardStyle,
    required this.onSelectHairStyle,
    required this.onSelectBeardStyle,
    required this.onReset,
    required this.scale,
    required this.offsetY,
    required this.onScaleChanged,
    required this.onOffsetYChanged,
  });

  @override
  State<TryOnControls> createState() => _TryOnControlsState();
}

class _TryOnControlsState extends State<TryOnControls> {
  StyleCategory _activeCategory = StyleCategory.hair;
  bool _showAdjustments = false;

  @override
  Widget build(BuildContext context) {
    final styles = _activeCategory == StyleCategory.hair
        ? TryOnStyle.hairstyles
        : TryOnStyle.beardStyles;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Category Selector Tabs + Adjust Toggle + Reset Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildCategoryTab('Hair', StyleCategory.hair),
                const SizedBox(width: 8),
                _buildCategoryTab('Beard', StyleCategory.beard),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _showAdjustments ? Icons.tune : Icons.tune_outlined,
                    color: _showAdjustments ? AppColors.primary : AppColors.textSecondary,
                  ),
                  tooltip: 'Fine-Tune Alignment',
                  onPressed: () {
                    setState(() => _showAdjustments = !_showAdjustments);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                  tooltip: 'Reset Preview',
                  onPressed: widget.onReset,
                ),
              ],
            ),
          ),
          const Divider(height: 16),

          // Manual Adjustment Sliders (if toggled)
          if (_showAdjustments) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Scale: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: widget.scale,
                          min: 0.7,
                          max: 1.5,
                          activeColor: AppColors.primary,
                          onChanged: widget.onScaleChanged,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Position: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: widget.offsetY,
                          min: -0.2,
                          max: 0.2,
                          activeColor: AppColors.primary,
                          onChanged: widget.onOffsetYChanged,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Style Thumbnails Carousel
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: styles.length,
              itemBuilder: (context, index) {
                final style = styles[index];
                final isSelected = _activeCategory == StyleCategory.hair
                    ? widget.selectedHairStyle?.id == style.id
                    : widget.selectedBeardStyle?.id == style.id;

                return GestureDetector(
                  onTap: () {
                    if (_activeCategory == StyleCategory.hair) {
                      widget.onSelectHairStyle(isSelected ? null : style);
                    } else {
                      widget.onSelectBeardStyle(isSelected ? null : style);
                    }
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: style.primaryColor == Colors.transparent
                                ? AppColors.border
                                : style.primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _activeCategory == StyleCategory.hair
                                ? Icons.face_retouching_natural
                                : Icons.face,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            style.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title, StyleCategory category) {
    final isSelected = _activeCategory == category;
    return ChoiceChip(
      label: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      onSelected: (selected) {
        if (selected) {
          setState(() => _activeCategory = category);
        }
      },
    );
  }
}
