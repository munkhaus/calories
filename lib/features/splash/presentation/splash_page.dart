import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';

/// Splash page that showcases app features with beautiful visuals
class SplashPage extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SplashPage({
    super.key,
    required this.onComplete,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _featuresController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideUpAnimation;
  late Animation<double> _featuresAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideUpAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));
    
    _featuresAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _featuresController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    await _mainController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    await _featuresController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
              AppColors.warning,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_mainController, _featuresController]),
            builder: (context, child) {
              return Padding(
                padding: const EdgeInsets.all(KSizes.margin4x),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Transform.translate(
                        offset: Offset(0, _slideUpAnimation.value),
                        child: Opacity(
                          opacity: _fadeInAnimation.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App title with icons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Food icon
                                  Container(
                                    padding: EdgeInsets.all(KSizes.margin2x),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                                    ),
                                    child: Icon(
                                      MdiIcons.silverwareForkKnife,
                                      color: Colors.white,
                                      size: KSizes.iconL,
                                    ),
                                  ),
                                  
                                  SizedBox(width: KSizes.margin3x),
                                  
                                  // Main title
                                  Text(
                                    'Kalorie\nTracker',
                                    style: TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1,
                                      height: 1.1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  SizedBox(width: KSizes.margin3x),
                                  
                                  // Activity icon
                                  Container(
                                    padding: EdgeInsets.all(KSizes.margin2x),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                                    ),
                                    child: Icon(
                                      MdiIcons.runFast,
                                      color: Colors.white,
                                      size: KSizes.iconL,
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: KSizes.margin4x),
                              
                              // Subtitle with camera icon
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    MdiIcons.camera,
                                    color: Colors.white.withOpacity(0.9),
                                    size: KSizes.iconM,
                                  ),
                                  SizedBox(width: KSizes.margin2x),
                                  Text(
                                    'Tag billeder • Log aktiviteter • Følg dit mål',
                                    style: TextStyle(
                                      fontSize: KSizes.fontSizeL,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: KSizes.fontWeightMedium,
                                      height: 1.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    Expanded(
                      flex: 2,
                      child: Opacity(
                        opacity: _featuresAnimation.value,
                        child: _buildFeaturesShowcase(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesShowcase() {
    final features = [
      _FeatureItem(
        icon: MdiIcons.camera,
        title: 'Smart Foto',
        subtitle: 'Tag billeder af mad\nog få automatisk analyse',
        color: AppColors.warning,
        delay: 0,
      ),
      _FeatureItem(
        icon: MdiIcons.chartLine,
        title: 'Kalorie Tracking',
        subtitle: 'Følg dit daglige\nkalorie indtag',
        color: AppColors.primary,
        delay: 200,
      ),
      _FeatureItem(
        icon: MdiIcons.runFast,
        title: 'Aktivitet Logger',
        subtitle: 'Log din motion\nog forbrændte kalorier',
        color: AppColors.secondary,
        delay: 400,
      ),
      _FeatureItem(
        icon: MdiIcons.star,
        title: 'Favoritter',
        subtitle: 'Gem dine mest\nbrugte måltider',
        color: AppColors.info,
        delay: 600,
      ),
      _FeatureItem(
        icon: MdiIcons.target,
        title: 'Mål Tracking',
        subtitle: 'Sæt og følg dine\npersonlige mål',
        color: AppColors.success,
        delay: 800,
      ),
      _FeatureItem(
        icon: MdiIcons.calculator,
        title: 'Data & Tal',
        subtitle: 'BMR, BMI og\npersonlig statistik',
        color: AppColors.error,
        delay: 1000,
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: KSizes.margin4x,
        mainAxisSpacing: KSizes.margin4x,
        childAspectRatio: 1.3,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(feature, index);
      },
    );
  }

  Widget _buildFeatureCard(_FeatureItem feature, int index) {
    // Calculate a staggered delay for each card
    final delay = feature.delay + (index * 100);

    return AnimatedBuilder(
      animation: _featuresController,
      builder: (context, child) {
        // Apply slide and fade animation based on overall features animation
        // and individual card delay
        final cardAnimationProgress = Curves.easeOutCubic.transform(
          (_featuresAnimation.value - (delay / 2000)).clamp(0.0, 1.0),
        );
        
        return Transform.translate(
          offset: Offset(0, 50 * (1 - cardAnimationProgress)),
          child: Opacity(
            opacity: cardAnimationProgress,
            child: Container(
              padding: const EdgeInsets.all(KSizes.margin1x),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(KSizes.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(KSizes.margin1x),
                      decoration: BoxDecoration(
                        color: feature.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(KSizes.radiusL),
                      ),
                      child: Icon(
                        feature.icon,
                        color: Colors.white,
                        size: KSizes.iconM,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      feature.title,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXS,
                        fontWeight: KSizes.fontWeightBold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      feature.subtitle,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXS,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: KSizes.fontWeightRegular,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
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

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int delay;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.delay,
  });
} 