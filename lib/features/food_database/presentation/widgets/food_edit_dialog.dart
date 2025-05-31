import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/food_database_cubit.dart';
import '../../domain/food_record_model.dart';

class FoodEditDialog extends ConsumerStatefulWidget {
  final FoodDatabaseCubit cubit;
  final VoidCallback onSaved;
  final VoidCallback onCancelled;

  const FoodEditDialog({
    super.key,
    required this.cubit,
    required this.onSaved,
    required this.onCancelled,
  });

  @override
  ConsumerState<FoodEditDialog> createState() => _FoodEditDialogState();
}

class _FoodEditDialogState extends ConsumerState<FoodEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  
  FoodCategory _selectedCategory = FoodCategory.other;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final state = widget.cubit.state;
    
    if (state.editingFood != null) {
      final food = state.editingFood!;
      _nameController.text = food.name;
      _descriptionController.text = food.description;
      _caloriesController.text = food.caloriesPer100g.toString();
      _selectedCategory = food.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.cubit.state;
    final isEditing = !state.isAddingFood;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
      ),
      title: Row(
        children: [
          Icon(
            isEditing ? MdiIcons.pencil : MdiIcons.plus,
            color: AppColors.primary,
          ),
          SizedBox(width: KSizes.margin2x),
          Text(isEditing ? 'Rediger Mad' : 'Tilføj Ny Mad'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Mad Navn',
                  hintText: 'f.eks. Grillet Kylling',
                  prefixIcon: Icon(MdiIcons.foodVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Navn er påkrævet';
                  }
                  return null;
                },
                autofocus: true,
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Beskrivelse (valgfri)',
                  hintText: 'f.eks. Grillet kyllingebryst med krydderier',
                  prefixIcon: Icon(MdiIcons.textBoxOutline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
                maxLines: 2,
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              // Calories field
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(
                  labelText: 'Kalorier per 100g',
                  hintText: 'f.eks. 165',
                  prefixIcon: Icon(MdiIcons.fire, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Kalorier er påkrævet';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Indtast et gyldigt tal';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              // Category selection
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: KSizes.margin2x),
              DropdownButtonFormField<FoodCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  prefixIcon: Icon(MdiIcons.tagOutline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
                items: FoodCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Text(category.emoji),
                        SizedBox(width: KSizes.margin2x),
                        Text(category.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              
              if (state.errorMessage.isNotEmpty) ...[
                SizedBox(height: KSizes.margin3x),
                Container(
                  padding: EdgeInsets.all(KSizes.margin3x),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        MdiIcons.alertCircle,
                        color: AppColors.error,
                        size: KSizes.iconS,
                      ),
                      SizedBox(width: KSizes.margin2x),
                      Expanded(
                        child: Text(
                          state.errorMessage,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: KSizes.fontSizeS,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : widget.onCancelled,
          child: Text('Annuller'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveFood,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(isEditing ? 'Opdater' : 'Tilføj'),
        ),
      ],
    );
  }

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final food = FoodRecordModel(
      id: widget.cubit.state.editingFood?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      caloriesPer100g: int.tryParse(_caloriesController.text) ?? 0,
      proteinPer100g: 0.0,
      carbsPer100g: 0.0,
      fatPer100g: 0.0,
      category: _selectedCategory,
      servingSizes: [
        const ServingSize(name: '1 portion', grams: 100.0, isDefault: true),
      ],
      createdAt: widget.cubit.state.editingFood?.createdAt ?? DateTime.now(),
    );

    final success = await widget.cubit.saveFood(food);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      widget.onSaved();
    }
  }
} 