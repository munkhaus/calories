import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../widgets/food_item_card.dart';
import '../widgets/meal_type_selector.dart';
import '../../domain/food_item_model.dart';
import '../../domain/user_food_log_model.dart';
import '../../infrastructure/food_logging_service.dart';
import 'food_portion_page.dart';

class FoodSearchPage extends StatefulWidget {
  final MealType? initialMealType;

  const FoodSearchPage({
    super.key,
    this.initialMealType,
  });

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<FoodItemModel> _searchResults = [];
  List<FoodItemModel> _recentFoods = [];
  List<FoodItemModel> _popularFoods = [];
  
  bool _isSearching = false;
  bool _isLoadingRecent = true;
  bool _isLoadingPopular = true;
  
  MealType _selectedMealType = MealType.morgenmad;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedMealType = widget.initialMealType ?? MealType.morgenmad;
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadRecentFoods(),
      _loadPopularFoods(),
    ]);
  }

  Future<void> _loadRecentFoods() async {
    setState(() => _isLoadingRecent = true);
    try {
      final foods = await FoodLoggingService.getRecentFoodItems(limit: 10);
      setState(() {
        _recentFoods = foods;
        _isLoadingRecent = false;
      });
    } catch (e) {
      setState(() => _isLoadingRecent = false);
    }
  }

  Future<void> _loadPopularFoods() async {
    setState(() => _isLoadingPopular = true);
    try {
      final foods = await FoodLoggingService.getPopularFoodItems(limit: 15);
      setState(() {
        _popularFoods = foods;
        _isLoadingPopular = false;
      });
    } catch (e) {
      setState(() => _isLoadingPopular = false);
    }
  }

  Future<void> _searchFoods(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      final foods = await FoodLoggingService.searchFoodItems(query.trim());
      setState(() {
        _searchResults = foods;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _onFoodSelected(FoodItemModel food) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodPortionPage(
          foodItem: food,
          mealType: _selectedMealType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button and header
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
                      child: StandardPageHeader(
                        title: 'Find dine fødevarer 🔍',
                        subtitle: 'Søg og vælg det du har spist',
                        icon: MdiIcons.magnify,
                        iconColor: AppColors.primary,
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
                      // Meal Type Selector
                      Container(
                        padding: EdgeInsets.all(KSizes.margin4x),
                        child: MealTypeSelector(
                          selectedMealType: _selectedMealType,
                          onMealTypeChanged: (mealType) {
                            setState(() => _selectedMealType = mealType);
                          },
                        ),
                      ),
                      
                      // Search Bar
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Søg efter fødevarer...',
                            prefixIcon: Icon(
                              MdiIcons.magnify,
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      MdiIcons.close,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _searchFoods('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KSizes.radiusM),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KSizes.radiusM),
                              borderSide: BorderSide(color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                          onChanged: _searchFoods,
                        ),
                      ),
                      
                      SizedBox(height: KSizes.margin4x),
                      
                      // Content Tabs or Search Results
                      Expanded(
                        child: _searchController.text.isEmpty
                            ? _buildTabContent()
                            : _buildSearchResults(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Populære'),
              Tab(text: 'Seneste'),
              Tab(text: 'Mine'),
            ],
          ),
        ),
        
        SizedBox(height: KSizes.margin2x),
        
        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPopularFoods(),
              _buildRecentFoods(),
              _buildMyFoods(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.foodOff,
              size: KSizes.iconXL,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              'Ingen fødevarer fundet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Prøv at søge med et andet ord',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: KSizes.margin2x),
          child: FoodItemCard(
            foodItem: _searchResults[index],
            onTap: () => _onFoodSelected(_searchResults[index]),
          ),
        );
      },
    );
  }

  Widget _buildPopularFoods() {
    if (_isLoadingPopular) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
      itemCount: _popularFoods.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: KSizes.margin2x),
          child: FoodItemCard(
            foodItem: _popularFoods[index],
            onTap: () => _onFoodSelected(_popularFoods[index]),
          ),
        );
      },
    );
  }

  Widget _buildRecentFoods() {
    if (_isLoadingRecent) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    
    if (_recentFoods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.clockOutline,
              size: KSizes.iconXL,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              'Ingen seneste fødevarer',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Log dine første måltider',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
      itemCount: _recentFoods.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: KSizes.margin2x),
          child: FoodItemCard(
            foodItem: _recentFoods[index],
            onTap: () => _onFoodSelected(_recentFoods[index]),
          ),
        );
      },
    );
  }

  Widget _buildMyFoods() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.bookmarkPlusOutline,
            size: KSizes.iconXL,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: KSizes.margin4x),
          Text(
            'Mine Fødevarer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            'Kommer snart',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
} 