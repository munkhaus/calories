import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../widgets/calorie_overview_widget.dart';
import '../widgets/daily_nutrition_widget.dart';
import '../widgets/recent_meals_widget.dart';
import '../../onboarding/presentation/onboarding_page.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../food_logging/domain/user_food_log_model.dart';

/// Main dashboard page showing daily overview
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    KSizes.margin4x,
                    KSizes.margin2x,
                    KSizes.margin4x,
                    KSizes.margin6x,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with greeting and notification
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: KSizes.fontSizeS,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                KSizes.spacingVerticalXS,
                                Text(
                                  userProfile.name.isNotEmpty 
                                      ? userProfile.name.split(' ').first 
                                      : 'der',
                                  style: TextStyle(
                                    fontSize: KSizes.fontSizeXXL,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                              onPressed: () {
                                // TODO: Navigate to notifications
                              },
                              icon: Icon(
                                MdiIcons.bellOutline,
                                color: AppColors.primary,
                                size: KSizes.iconM,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Main content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: KSizes.margin4x),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Calorie overview widget (main card matching the image)
                    const CalorieOverviewWidget(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Daily nutrition widget
                    const DailyNutritionWidget(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Recent meals with enhanced design
                    const RecentMealsWidget(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Water tracking and streak section
                    Row(
                      children: [
                        Expanded(
                          child: _buildWaterTrackingCard(),
                        ),
                        KSizes.spacingHorizontalM,
                        Expanded(
                          child: _buildStreakCard(),
                        ),
                      ],
                    ),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Quick actions section
                    _buildQuickActions(context, ref),
                    
                    // Bottom padding for FAB
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'God morgen';
    } else if (hour < 17) {
      return 'God eftermiddag';
    } else {
      return 'God aften';
    }
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String actionText,
    IconData icon, {
    VoidCallback? onPressed,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(KSizes.margin2x),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.secondary.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(KSizes.radiusM),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: KSizes.iconS,
          ),
        ),
        KSizes.spacingHorizontalM,
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (actionText.isNotEmpty)
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: KSizes.margin3x,
                vertical: KSizes.margin2x,
              ),
            ),
            child: Text(
              actionText,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: KSizes.fontSizeM,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Column(
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.only(bottom: KSizes.margin4x),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(KSizes.margin2x),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                    child: Icon(
                      MdiIcons.flash,
                      color: AppColors.primary,
                      size: KSizes.iconS,
                    ),
                  ),
                  KSizes.spacingHorizontalM,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hurtige handlinger',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeL,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Nem adgang til nøglefunktioner',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeXS,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // First row - all same height
            SizedBox(
              height: 90, // Reduced from 110 to fix overflow
              child: Row(
                children: [
                  Expanded(
                    child: _ModernQuickActionCard(
                      icon: MdiIcons.camera,
                      label: 'Tag foto',
                      subtitle: 'Scan din mad',
                      gradient: [Colors.green.shade400, Colors.green.shade600],
                      isPrimary: true,
                      onTap: () {
                        print('Take photo tapped');
                      },
                    ),
                  ),
                  const SizedBox(width: KSizes.margin2x),
                  Expanded(
                    child: _ModernQuickActionCard(
                      icon: MdiIcons.qrcodeScan,
                      label: 'Scan kode',
                      subtitle: 'Stregkode/QR',
                      gradient: [Colors.blue.shade400, Colors.blue.shade600],
                      isPrimary: false,
                      onTap: () {
                        print('Scan code tapped');
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: KSizes.margin2x),
            
            // Second row - all same height
            SizedBox(
              height: 90, // Reduced from 110 to fix overflow
              child: Row(
                children: [
                  Expanded(
                    child: _ModernQuickActionCard(
                      icon: MdiIcons.magnify,
                      label: 'Søg mad',
                      subtitle: 'Find fødevarer',
                      gradient: [Colors.orange.shade400, Colors.orange.shade600],
                      isPrimary: false,
                      onTap: () {
                        print('Search food tapped');
                      },
                    ),
                  ),
                  const SizedBox(width: KSizes.margin2x),
                  Expanded(
                    child: _ModernQuickActionCard(
                      icon: MdiIcons.refresh,
                      label: 'Genopsæt',
                      subtitle: 'Nulstil data',
                      gradient: [Colors.amber.shade400, Colors.amber.shade600],
                      isPrimary: false,
                      onTap: () {
                        print('Reset tapped');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterTrackingCard() {
    // TODO: Get actual water data from database
    const currentGlasses = 4;
    const targetGlasses = 8;
    final progress = (currentGlasses / targetGlasses).clamp(0.0, 1.0);

    return Container(
      height: KSizes.cardHeightL,
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin2x),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(KSizes.margin1x),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
              child: Icon(
                MdiIcons.water,
                color: Colors.white,
                size: KSizes.iconS,
              ),
            ),
            Text(
              'Vand',
              style: TextStyle(
                fontSize: KSizes.fontSizeS,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textPrimary,
              ),
            ),
            Column(
              children: [
                Text(
                  '$currentGlasses / $targetGlasses',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.info,
                  ),
                ),
                Text(
                  'glas',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXS,
                    color: AppColors.textSecondary,
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ],
            ),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.2),
                borderRadius: BorderRadius.circular(KSizes.radiusS),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    // TODO: Get actual streak data from database
    const currentStreak = 7;
    const bestStreak = 23;

    return Container(
      height: KSizes.cardHeightL,
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin2x),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(KSizes.margin1x),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
              child: Icon(
                MdiIcons.fire,
                color: Colors.white,
                size: KSizes.iconS,
              ),
            ),
            Text(
              'Streak',
              style: TextStyle(
                fontSize: KSizes.fontSizeS,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textPrimary,
              ),
            ),
            Column(
              children: [
                Text(
                  '$currentStreak',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.warning,
                  ),
                ),
                Text(
                  'dage',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXS,
                    color: AppColors.textSecondary,
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KSizes.margin1x,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusS),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Bedste: $bestStreak',
                style: TextStyle(
                  fontSize: KSizes.fontSizeXS,
                  color: AppColors.warning,
                  fontWeight: KSizes.fontWeightSemiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestartOnboardingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusXL),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  MdiIcons.refresh,
                  color: Colors.white,
                  size: KSizes.iconS,
                ),
              ),
              KSizes.spacingHorizontalM,
              Text(
                'Genstart onboarding',
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.05),
              borderRadius: BorderRadius.circular(KSizes.radiusL),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Er du sikker på, at du vil genstarte onboarding processen?',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                KSizes.spacingVerticalS,
                Text(
                  'Dine eksisterende data bliver ikke slettet.',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: KSizes.margin4x,
                  vertical: KSizes.margin2x,
                ),
              ),
              child: Text(
                'Annuller',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(onboardingProvider.notifier).restartOnboardingFlow();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  // Navigate to onboarding
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingPage(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: KSizes.margin4x,
                  vertical: KSizes.margin2x,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                ),
              ),
              child: Text(
                'Genstart',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ModernQuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ModernQuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_ModernQuickActionCard> createState() => _ModernQuickActionCardState();
}

class _ModernQuickActionCardState extends State<_ModernQuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: Container(
              height: 90, // Reduced to match SizedBox height
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradient,
                ),
                borderRadius: BorderRadius.circular(KSizes.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.first.withOpacity(0.25),
                    blurRadius: KSizes.blurRadiusM,
                    offset: KSizes.shadowOffsetM,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 4,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(KSizes.margin1x), // Reduced padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: KSizes.iconM, // Reduced from iconL
                      color: Colors.white,
                    ),
                    KSizes.spacingVerticalXS, // Reduced spacing
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS, // Reduced from fontSizeM
                        fontWeight: KSizes.fontWeightBold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXS, // Reduced from fontSizeS
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 