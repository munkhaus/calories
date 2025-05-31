import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../application/food_database_cubit.dart';
import '../domain/food_record_model.dart';
import '../domain/online_food_models.dart';
import 'widgets/food_category_chips.dart';
import 'widgets/food_database_search_bar.dart';
import 'widgets/food_item_card.dart';
import 'widgets/food_edit_dialog.dart';
import 'online_food_search_page.dart';

class FoodDatabasePage extends ConsumerStatefulWidget {
  const FoodDatabasePage({super.key});

  @override
  ConsumerState<FoodDatabasePage> createState() => _FoodDatabasePageState();
}

class _FoodDatabasePageState extends ConsumerState<FoodDatabasePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _selectedTags = [];
  bool _showTagSuggestions = false;

  // Kategoriserede tags for bedre brugeroplevelse
  final Map<String, List<String>> _tagCategories = {
    '🕐 Tid på dagen': [
      '🌅 Morgenmad',
      '☀️ Formiddag',
      '🌞 Frokost', 
      '🌤️ Eftermiddag',
      '🌆 Aftensmad',
      '🌙 Aften/Nat'
    ],
    '🍽️ Mad typer': [
      '🍎 Frugt',
      '🥕 Grøntsager', 
      '🥩 Kød',
      '🐟 Fisk',
      '🥛 Mejeriprodukter',
      '🌾 Korn & Brød',
      '🥜 Nødder',
      '🫘 Bælgfrugter'
    ],
    '🍳 Tilberedning': [
      '🔥 Varme retter',
      '❄️ Kolde retter',
      '🥗 Salater',
      '🍲 Supper',
      '🥪 Sandwich',
      '🍝 Pasta retter',
      '🍕 Pizza'
    ],
    '🎯 Særlige': [
      '🌱 Vegetarisk',
      '🌿 Vegansk',
      '💪 Højt protein',
      '⚡ Hurtig mad',
      '🍰 Søde sager',
      '🥤 Drikkevarer'
    ]
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    // Initialize when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(foodDatabaseProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    ref.read(foodDatabaseProvider.notifier).searchFoods(query);
  }

  void _onFocusChanged() {
    setState(() {
      _showTagSuggestions = _searchFocusNode.hasFocus;
    });
  }

  void _addTag(String tag) {
    if (!_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
      _performTagSearch();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
    _performTagSearch();
  }

  void _performTagSearch() {
    final searchTerms = [
      _searchController.text,
      ..._selectedTags.map((tag) => tag.replaceAll(RegExp(r'[🍎🥕🥩🐟🥛🌾🥜🫘🌿🥤🍰🫒🍽️🥞🥗🍝🍿🧁]'), '').trim())
    ].where((term) => term.isNotEmpty).join(' ');
    
    ref.read(foodDatabaseProvider.notifier).searchFoods(searchTerms);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodDatabaseProvider);
    final cubit = ref.read(foodDatabaseProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mad Database'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: Icon(MdiIcons.web, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OnlineFoodSearchPage(),
                ),
              );
            },
            tooltip: 'Søg online',
          ),
          IconButton(
            icon: Icon(MdiIcons.refresh),
            onPressed: () => cubit.refresh(),
            tooltip: 'Opdater',
          ),
          IconButton(
            icon: Icon(MdiIcons.broom),
            onPressed: state.searchQuery.isNotEmpty || _selectedTags.isNotEmpty
                ? () {
                    cubit.searchFoods('');
                    setState(() {
                      _searchController.clear();
                      _selectedTags.clear();
                    });
                  }
                : null,
            tooltip: 'Ryd filtre',
          ),
        ],
      ),
      // Ensure FAB is always visible
      floatingActionButton: FloatingActionButton(
        heroTag: "food_db_fab",
        onPressed: () => _showAddFoodDialog(context, cubit),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: Icon(Icons.add, size: 28),
        tooltip: 'Tilføj Mad',
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: Column(
          children: [
            // Enhanced search section
            _buildEnhancedSearchSection(),

            // Content area
            Expanded(
              child: _buildContent(context, state, cubit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSearchSection() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(KSizes.margin3x),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Søg efter mad eller tags...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty || _selectedTags.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _selectedTags.clear();
                          });
                          ref.read(foodDatabaseProvider.notifier).searchFoods('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
          ),
          
          // Selected tags
          if (_selectedTags.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: KSizes.margin3x),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aktive tags:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: KSizes.margin1x),
                  Wrap(
                    spacing: KSizes.margin1x,
                    runSpacing: KSizes.margin1x,
                    children: _selectedTags.map((tag) => _buildSelectedTag(tag)).toList(),
                  ),
                  SizedBox(height: KSizes.margin2x),
                ],
              ),
            ),
          
          // Tag suggestions
          if (_showTagSuggestions)
            Container(
              padding: EdgeInsets.symmetric(horizontal: KSizes.margin3x),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tag kategorier:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: KSizes.margin2x),
                  
                  // Horizontal scrolling categories
                  SizedBox(
                    height: 120, // Increased height for category sections
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _tagCategories.length,
                      itemBuilder: (context, categoryIndex) {
                        final category = _tagCategories.keys.elementAt(categoryIndex);
                        final tags = _tagCategories[category]!;
                        
                        return Container(
                          width: 180,
                          margin: EdgeInsets.only(right: KSizes.margin3x),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category header
                              Text(
                                category,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: KSizes.margin1x),
                              
                              // Tags in this category
                              Expanded(
                                child: Wrap(
                                  spacing: KSizes.margin1x,
                                  runSpacing: KSizes.margin1x / 2,
                                  children: tags.map((tag) {
                                    final isSelected = _selectedTags.contains(tag);
                                    if (isSelected) return const SizedBox.shrink();
                                    
                                    return _buildTagSuggestion(tag);
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: KSizes.margin2x),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: KSizes.margin2x,
        vertical: KSizes.margin1x,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: KSizes.margin1x),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSuggestion(String tag) {
    return GestureDetector(
      onTap: () => _addTag(tag),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: KSizes.margin3x,
          vertical: KSizes.margin2x,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          tag,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, state, FoodDatabaseCubit cubit) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.hasError) {
      return _buildEmptyState(
        icon: MdiIcons.databaseOff,
        title: 'Fejl ved indlæsning',
        subtitle: state.errorMessage.isNotEmpty ? state.errorMessage : 'Prøv igen senere',
        color: AppColors.error,
        actionText: 'Prøv igen',
        onAction: () => cubit.refresh(),
      );
    }

    final foods = state.filteredFoods;

    if (foods.isEmpty) {
      return _buildEmptyState(
        icon: state.searchQuery.isNotEmpty || state.selectedCategory != null
            ? MdiIcons.magnify
            : MdiIcons.foodOffOutline,
        title: state.searchQuery.isNotEmpty || state.selectedCategory != null
            ? 'Ingen mad fundet'
            : 'Ingen mad tilføjet endnu',
        subtitle: state.searchQuery.isNotEmpty || state.selectedCategory != null
            ? 'Prøv at justere dine søgetermer'
            : 'Tryk på + knappen for at tilføje din første mad',
        color: AppColors.primary,
        actionText: state.searchQuery.isNotEmpty || state.selectedCategory != null ? 'Ryd filtre' : null,
        onAction: state.searchQuery.isNotEmpty || state.selectedCategory != null 
            ? () => cubit.clearFilters() 
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(KSizes.margin4x),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return FoodItemCard(
          food: food,
          onTap: () => _showFoodDetails(context, food, cubit),
          onEdit: () => _showEditFoodDialog(context, food, cubit),
          onDelete: () => _showDeleteConfirmation(context, food, cubit),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin6x),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(KSizes.margin6x),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: color,
              ),
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              title,
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                color: AppColors.textPrimary,
                fontWeight: KSizes.fontWeightBold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: KSizes.margin4x),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddFoodDialog(BuildContext context, FoodDatabaseCubit cubit) {
    cubit.startAddingFood();
    _showFoodEditDialog(context, cubit);
  }

  void _showEditFoodDialog(BuildContext context, FoodRecordModel food, FoodDatabaseCubit cubit) {
    cubit.startEditingFood(food);
    _showFoodEditDialog(context, cubit);
  }

  void _showFoodEditDialog(BuildContext context, FoodDatabaseCubit cubit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FoodEditDialog(
        cubit: cubit,
        onSaved: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cubit.state.isAddingFood ? 'Mad tilføjet!' : 'Mad opdateret!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
        onCancelled: () {
          cubit.cancelEditing();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showFoodDetails(BuildContext context, FoodRecordModel food, FoodDatabaseCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusL),
        ),
        title: Row(
          children: [
            Text(food.category.emoji),
            SizedBox(width: KSizes.margin2x),
            Expanded(child: Text(food.name)),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (food.description.isNotEmpty) ...[
              Text(
                food.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: KSizes.margin4x),
            ],
            
            // Simple calories display
            Row(
              children: [
                Icon(MdiIcons.fire, color: Colors.orange, size: KSizes.iconM),
                SizedBox(width: KSizes.margin2x),
                Text(
                  '${food.caloriesPer100g} kalorier per 100g',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            if (food.servingSizes.isNotEmpty) ...[
              SizedBox(height: KSizes.margin4x),
              Text(
                'Portionsstørrelser:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: KSizes.margin2x),
              // Simple list format
              ...food.servingSizes.map((serving) => Padding(
                padding: EdgeInsets.only(bottom: KSizes.margin1x),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(serving.name),
                    Row(
                      children: [
                        Text('${serving.grams.toStringAsFixed(0)} g'),
                        if (serving.isDefault) ...[
                          SizedBox(width: KSizes.margin2x),
                          Text(
                            'Standard',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: KSizes.fontSizeXS,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Luk'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditFoodDialog(context, food, cubit);
            },
            child: const Text('Rediger'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showDeleteConfirmation(context, food, cubit);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Slet'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FoodRecordModel food, FoodDatabaseCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Slet mad'),
        content: Text('Er du sikker på at du vil slette "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await cubit.deleteFood(food);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${food.name} slettet'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Slet'),
          ),
        ],
      ),
    );
  }
} 