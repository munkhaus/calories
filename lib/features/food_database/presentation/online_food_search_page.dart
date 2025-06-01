import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../application/online_food_cubit.dart';
import '../application/online_food_state.dart';
import 'widgets/online_food_result_card.dart';
import 'widgets/online_food_detail_view.dart';
import '../domain/online_food_models.dart';

class OnlineFoodSearchPage extends ConsumerStatefulWidget {
  const OnlineFoodSearchPage({super.key});

  @override
  ConsumerState<OnlineFoodSearchPage> createState() => _OnlineFoodSearchPageState();
}

class _OnlineFoodSearchPageState extends ConsumerState<OnlineFoodSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  SearchMode? _selectedSearchMode; // null = alle

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = ref.read(onlineFoodProvider.notifier);
      cubit.initialize(); // Initialize service when page loads
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(onlineFoodProvider);
        final cubit = ref.read(onlineFoodProvider.notifier);
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: AppDesign.backgroundGradient,
            ),
            child: SafeArea(
              child: !state.isServiceAvailable && !state.isLoading
                  ? _buildErrorState(cubit)
                  : Column(
                      children: [
                        // Header with back button
                        Padding(
                          padding: const EdgeInsets.all(KSizes.margin4x),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: Icon(
                                    MdiIcons.arrowLeft,
                                    color: AppColors.textPrimary,
                                    size: KSizes.iconM,
                                  ),
                                ),
                              ),
                              const SizedBox(width: KSizes.margin4x),
                              Expanded(
                                child: AppPageHeader(
                                  title: 'Madvaresøgning 🔍',
                                  subtitle: 'Søg og tilføj nye fødevarer',
                                  titleIcon: MdiIcons.magnify,
                                  titleIconColor: AppColors.primary,
                                  showInfoButton: false,
                                ),
                              ),
                              // Debug button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    print('🐛 DEBUG: Checking database contents...');
                                    cubit.debugDatabaseContents();
                                  },
                                  icon: Icon(
                                    MdiIcons.database,
                                    color: Colors.white,
                                    size: KSizes.iconM,
                                  ),
                                  tooltip: 'Debug database',
                                ),
                              ),
                              SizedBox(width: KSizes.margin2x),
                              // Clear database button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Clear Database'),
                                        content: Text('Dette vil slette ALLE fødevarer fra din database. Er du sikker?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('Annuller'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              cubit.debugClearDatabase();
                                            },
                                            child: Text('Ja, slet alt', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    MdiIcons.deleteEmpty,
                                    color: Colors.white,
                                    size: KSizes.iconM,
                                  ),
                                  tooltip: 'Clear all foods',
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
                            child: Column(
                              children: [
                                // Search section in a card
                                Container(
                                  padding: EdgeInsets.all(KSizes.margin4x),
                                  decoration: AppDesign.cardDecoration,
                                  child: Column(
                                    children: [
                                      // Search Field
                                      TextField(
                                        controller: _searchController,
                                        focusNode: _searchFocus,
                                        decoration: InputDecoration(
                                          hintText: 'Søg efter fødevarer...',
                                          prefixIcon: Icon(
                                            MdiIcons.magnify,
                                            color: AppColors.textSecondary,
                                          ),
                                          suffixIcon: _searchController.text.isNotEmpty
                                              ? IconButton(
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    cubit.clearResults();
                                                  },
                                                  icon: Icon(
                                                    MdiIcons.close,
                                                    color: Colors.grey[600],
                                                    size: KSizes.iconS,
                                                  ),
                                                )
                                              : null,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(KSizes.radiusM),
                                            borderSide: BorderSide(
                                              color: AppColors.border,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(KSizes.radiusM),
                                            borderSide: BorderSide(
                                              color: AppColors.primary,
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: AppColors.surface,
                                        ),
                                        onSubmitted: (query) {
                                          if (query.trim().isNotEmpty) {
                                            _performSearch(query.trim());
                                          }
                                        },
                                        onChanged: (value) {
                                          setState(() {}); // Update UI for clear button
                                        },
                                      ),
                                      
                                      SizedBox(height: KSizes.margin3x),
                                      
                                      // Search mode filter
                                      _buildSearchModeFilter(),
                                      
                                      SizedBox(height: KSizes.margin3x),
                                      
                                      // Quick Search Tags
                                      Wrap(
                                        spacing: KSizes.margin1x,
                                        runSpacing: KSizes.margin1x,
                                        children: _getQuickTags().map((tag) => _buildQuickTag(tag, cubit)).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                SizedBox(height: KSizes.margin4x),
                                
                                // Results Area
                                Expanded(
                                  child: _buildResultsArea(state, cubit),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          floatingActionButton: state.isSelectionMode
              ? FloatingActionButton.extended(
                  onPressed: state.selectedFoodIds.isNotEmpty && !state.isAddingToDatabase
                      ? () => _addSelectedFoods(cubit)
                      : null,
                  backgroundColor: state.selectedFoodIds.isNotEmpty
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  foregroundColor: Colors.white,
                  icon: state.isAddingToDatabase 
                      ? SizedBox(
                          width: KSizes.iconM,
                          height: KSizes.iconM,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(MdiIcons.plus),
                  label: Text(
                    state.isAddingToDatabase 
                        ? 'Tilføjer...' 
                        : 'Tilføj ${state.selectedFoodIds.length}',
                  ),
                )
              : state.searchResults.isNotEmpty
                  ? FloatingActionButton.extended(
                      onPressed: () => cubit.toggleSelectionMode(),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      icon: Icon(MdiIcons.checkboxMultipleMarked),
                      label: Text('Vælg flere'),
                    )
                  : null,
        );
      },
    );
  }

  Widget _buildErrorState(OnlineFoodCubit cubit) {
    return Padding(
      padding: EdgeInsets.all(KSizes.margin6x),
      child: Column(
        children: [
          // Header with back button
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                  boxShadow: AppDesign.smallShadow,
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    MdiIcons.arrowLeft,
                    color: AppColors.textPrimary,
                    size: KSizes.iconM,
                  ),
                ),
              ),
              const SizedBox(width: KSizes.margin4x),
              Expanded(
                child: AppPageHeader(
                  title: 'Madvaresøgning',
                  titleIcon: MdiIcons.magnify,
                  titleIconColor: AppColors.primary,
                  showInfoButton: false,
                ),
              ),
            ],
          ),
          
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(KSizes.margin6x),
                decoration: AppDesign.cardDecoration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      MdiIcons.cloudOff,
                      size: 64,
                      color: AppColors.error,
                    ),
                    SizedBox(height: KSizes.margin4x),
                    Text(
                      'Service ikke tilgængelig',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: KSizes.fontWeightBold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: KSizes.margin2x),
                    Text(
                      'Søgetjenesten er ikke tilgængelig lige nu. Prøv igen senere.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: KSizes.margin4x),
                    ElevatedButton.icon(
                      onPressed: () => cubit.initialize(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: KSizes.margin6x,
                          vertical: KSizes.margin4x,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                        ),
                      ),
                      icon: Icon(MdiIcons.refresh, size: KSizes.iconM),
                      label: Text(
                        'Prøv igen',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          fontWeight: KSizes.fontWeightMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTag(String tag, OnlineFoodCubit cubit) {
    return InkWell(
      onTap: () {
        _searchController.text = tag;
        _performSearch(tag);
        _searchFocus.unfocus();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: KSizes.margin3x,
          vertical: KSizes.margin2x,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(KSizes.radiusL),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          tag,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: KSizes.fontWeightMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsArea(OnlineFoodState state, OnlineFoodCubit cubit) {
    if (state.isLoading) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(KSizes.margin6x),
          decoration: AppDesign.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              SizedBox(height: KSizes.margin4x),
              Text(
                'Søger efter fødevarer...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.hasError) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(KSizes.margin6x),
          decoration: AppDesign.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                MdiIcons.alertCircle,
                size: 48,
                color: AppColors.error,
              ),
              SizedBox(height: KSizes.margin4x),
              Text(
                'Søgefejl',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: KSizes.fontWeightBold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: KSizes.margin2x),
              Text(
                state.errorMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: KSizes.margin4x),
              ElevatedButton.icon(
                onPressed: () => cubit.dismissError(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
                icon: Icon(MdiIcons.refresh, size: KSizes.iconM),
                label: Text('Prøv igen'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.searchResults.isEmpty && state.searchQuery.isNotEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(KSizes.margin6x),
          decoration: AppDesign.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                MdiIcons.foodOff,
                size: 48,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: KSizes.margin4x),
              Text(
                'Ingen resultater',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: KSizes.fontWeightBold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: KSizes.margin2x),
              Text(
                'Prøv med andre søgeord eller tjek stavningen.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state.searchResults.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(KSizes.margin6x),
          decoration: AppDesign.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                MdiIcons.magnify,
                size: 48,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: KSizes.margin4x),
              Text(
                'Søg efter fødevarer',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: KSizes.fontWeightBold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: KSizes.margin2x),
              Text(
                'Indtast et søgeord eller vælg en af de hurtige tags ovenfor.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Selection controls (if in selection mode)
        if (state.isSelectionMode) ...[
          Container(
            padding: EdgeInsets.all(KSizes.margin4x),
            decoration: AppDesign.cardDecoration,
            child: Column(
              children: [
                // Selection mode header
                Row(
                  children: [
                    Icon(
                      MdiIcons.checkboxMultipleMarked,
                      color: AppColors.primary,
                      size: KSizes.iconM,
                    ),
                    SizedBox(width: KSizes.margin2x),
                    Expanded(
                      child: Text(
                        'Vælg fødevarer',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: KSizes.fontWeightBold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => cubit.toggleSelectionMode(),
                      icon: Icon(
                        MdiIcons.close,
                        color: AppColors.textSecondary,
                        size: KSizes.iconM,
                      ),
                      tooltip: 'Afslut valg',
                    ),
                  ],
                ),
                
                SizedBox(height: KSizes.margin3x),
                
                // Selection controls
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${state.selectedFoodIds.length} valgt',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: KSizes.fontWeightBold,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        print('🔘 UI: Vælg/Fravælg alle button pressed');
                        cubit.toggleSelectAllFoods();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: EdgeInsets.symmetric(
                          horizontal: KSizes.margin4x,
                          vertical: KSizes.margin3x,
                        ),
                      ),
                      icon: Icon(
                        // Show different icon based on selection state
                        state.selectedFoodIds.length == state.searchResults.length
                            ? MdiIcons.selectOff
                            : MdiIcons.selectAll,
                        size: KSizes.iconS,
                      ),
                      label: Text(
                        // Show different text based on selection state
                        state.selectedFoodIds.length == state.searchResults.length
                            ? 'Fravælg alle'
                            : 'Vælg alle',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: KSizes.margin3x),
        ],
        
        // Results list
        Expanded(
          child: ListView.separated(
            itemCount: state.searchResults.length,
            separatorBuilder: (context, index) => SizedBox(height: KSizes.margin2x),
            itemBuilder: (context, index) {
              final food = state.searchResults[index];
              return OnlineFoodResultCard(
                foodResult: food,
                showSelection: state.isSelectionMode,
                isSelected: state.selectedFoodIds.contains(food.id),
                onSelectionToggle: () => cubit.toggleFoodSelection(food.id),
                onTap: () => _showFoodDetails(context, food, cubit),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFoodDetails(BuildContext context, food, OnlineFoodCubit cubit) async {
    // Get details (should be cached and immediate)
    await cubit.getFoodDetails(food.id);
    
    if (!mounted) return;
    
    final state = ref.read(onlineFoodProvider);
    if (state.selectedFoodDetails != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top + KSizes.margin4x,
            left: KSizes.margin4x,
            right: KSizes.margin4x,
            bottom: MediaQuery.of(context).viewInsets.bottom + KSizes.margin4x,
          ),
          child: OnlineFoodDetailView(
            foodDetails: state.selectedFoodDetails!,
            onAddToDatabase: () async {
              await cubit.addFoodToDatabase(food);
              
              if (!mounted) return;
              
              Navigator.pop(context);
              
              // Show appropriate feedback
              final currentState = ref.read(onlineFoodProvider);
              final isInfoMessage = currentState.errorMessage.contains('✅') || 
                                   currentState.errorMessage.contains('findes allerede');
              
              if (!currentState.hasError || isInfoMessage) {
                // Show success/info message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          isInfoMessage ? MdiIcons.informationOutline : MdiIcons.checkCircle,
                          color: Colors.white,
                          size: KSizes.iconM,
                        ),
                        SizedBox(width: KSizes.margin2x),
                        Expanded(
                          child: Text(
                            currentState.errorMessage.isNotEmpty 
                                ? currentState.errorMessage 
                                : '✅ "${food.name}" tilføjet til database',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: isInfoMessage ? AppColors.primary : AppColors.success,
                    duration: Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                  ),
                );
              } else {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          MdiIcons.alertCircle,
                          color: Colors.white,
                          size: KSizes.iconM,
                        ),
                        SizedBox(width: KSizes.margin2x),
                        Expanded(
                          child: Text(
                            currentState.errorMessage,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                    duration: Duration(seconds: 4),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                    action: SnackBarAction(
                      label: 'Prøv igen',
                      textColor: Colors.white,
                      onPressed: () => _showFoodDetails(context, food, cubit),
                    ),
                  ),
                );
              }
            },
            onClose: () {
              Navigator.pop(context);
            },
            isLoading: state.isAddingToDatabase,
          ),
        ),
      );
    }
  }

  List<String> _getQuickTags() {
    return [
      'Morgenmad',
      'Frokost', 
      'Aftensmad',
      'Snack',
      'Mellemmåltid',
      'Dessert',
      'Drikke',
      'Tilbehør',
    ];
  }

  void _onSearchModeChanged(SearchMode? mode) {
    setState(() {
      _selectedSearchMode = mode;
    });
    
    // Hvis der allerede er søgt, søg igen med ny filter
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    final cubit = ref.read(onlineFoodProvider.notifier);
    cubit.searchFoods(query, searchMode: _selectedSearchMode);
  }

  void _clearSearch() {
    _searchController.clear();
    final cubit = ref.read(onlineFoodProvider.notifier);
    cubit.clearResults();
  }

  Future<void> _addSelectedFoods(OnlineFoodCubit cubit) async {
    final selectedCount = ref.read(onlineFoodProvider).selectedFoodIds.length;
    
    await cubit.addSelectedFoodsToDatabase();
    
    if (!mounted) return;
    
    final state = ref.read(onlineFoodProvider);
    
    // Determine if this is truly an error or just info
    final isInfoMessage = state.errorMessage.contains('✅') || 
                         state.errorMessage.contains('fandtes allerede') ||
                         state.errorMessage.contains('findes allerede');
    
    if (!state.hasError || isInfoMessage) {
      // Show success/info message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isInfoMessage ? MdiIcons.informationOutline : MdiIcons.checkCircle,
                color: Colors.white,
                size: KSizes.iconM,
              ),
              SizedBox(width: KSizes.margin2x),
              Expanded(
                child: Text(
                  state.errorMessage.isNotEmpty 
                      ? state.errorMessage 
                      : '$selectedCount fødevarer behandlet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isInfoMessage ? AppColors.primary : AppColors.success,
          duration: Duration(seconds: isInfoMessage ? 4 : 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusM),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                MdiIcons.alertCircle,
                color: Colors.white,
                size: KSizes.iconM,
              ),
              SizedBox(width: KSizes.margin2x),
              Expanded(
                child: Text(
                  state.errorMessage,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusM),
          ),
          action: SnackBarAction(
            label: 'Prøv igen',
            textColor: Colors.white,
            onPressed: () => _addSelectedFoods(cubit),
          ),
        ),
      );
    }
  }

  Widget _buildSearchModeFilter() {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Text(
            'Søg efter:',
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(width: KSizes.margin2x),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Alle',
                    icon: MdiIcons.foodVariant,
                    isSelected: _selectedSearchMode == null,
                    onTap: () => _onSearchModeChanged(null),
                  ),
                  SizedBox(width: KSizes.margin2x),
                  _buildFilterChip(
                    label: 'Retter',
                    icon: MdiIcons.food,
                    isSelected: _selectedSearchMode == SearchMode.dishes,
                    onTap: () => _onSearchModeChanged(SearchMode.dishes),
                  ),
                  SizedBox(width: KSizes.margin2x),
                  _buildFilterChip(
                    label: 'Fødevarer',
                    icon: MdiIcons.carrot,
                    isSelected: _selectedSearchMode == SearchMode.ingredients,
                    onTap: () => _onSearchModeChanged(SearchMode.ingredients),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: KSizes.margin3x,
          vertical: KSizes.margin2x,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: KSizes.iconS,
              color: isSelected ? AppColors.primary : Colors.white,
            ),
            SizedBox(width: KSizes.margin1x),
            Text(
              label,
              style: TextStyle(
                fontSize: KSizes.fontSizeS,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 