import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';

class WorkActivityStepWidget extends ConsumerWidget {
  const WorkActivityStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hvor fysisk krævende er dit arbejde?',
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Vælg det niveau der bedst beskriver dit arbejde',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: KSizes.margin6x),
            
            // Work activity level cards
            _buildActivityCard(
              context: context,
              level: WorkActivityLevel.sedentary,
              title: 'Stillesiddende',
              description: 'Kontorarbejde, mest ved skrivebord',
              icon: Icons.computer,
              color: Colors.blue,
              isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.sedentary,
              onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.sedentary),
            ),
            SizedBox(height: KSizes.margin4x),
            
            _buildActivityCard(
              context: context,
              level: WorkActivityLevel.light,
              title: 'Let aktivitet',
              description: 'Lærere, butiksassistenter, let fysisk arbejde',
              icon: Icons.person_2,
              color: Colors.green,
              isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.light,
              onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.light),
            ),
            SizedBox(height: KSizes.margin4x),
            
            _buildActivityCard(
              context: context,
              level: WorkActivityLevel.moderate,
              title: 'Moderat aktivitet',
              description: 'Sygeplejersker, håndværkere, service',
              icon: Icons.build,
              color: Colors.orange,
              isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.moderate,
              onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.moderate),
            ),
            SizedBox(height: KSizes.margin4x),
            
            _buildActivityCard(
              context: context,
              level: WorkActivityLevel.heavy,
              title: 'Tung aktivitet',
              description: 'Byggearbejdere, landmænd, flyttemænd',
              icon: Icons.fitness_center,
              color: Colors.red,
              isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.heavy,
              onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.heavy),
            ),
            SizedBox(height: KSizes.margin4x),
            
            _buildActivityCard(
              context: context,
              level: WorkActivityLevel.veryHeavy,
              title: 'Meget tung aktivitet',
              description: 'Meget krævende fysisk arbejde, tungt løft',
              icon: Icons.construction,
              color: Colors.purple,
              isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.veryHeavy,
              onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.veryHeavy),
            ),
            
            SizedBox(height: KSizes.margin6x),
            
            // Information box
            Container(
              padding: EdgeInsets.all(KSizes.margin4x),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: KSizes.iconM,
                  ),
                  SizedBox(width: KSizes.margin3x),
                  Expanded(
                    child: Text(
                      'Dette hjælper os med at beregne dit daglige kalorieforbrug mere præcist',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: Colors.blue[700],
                      ),
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

  Widget _buildActivityCard({
    required BuildContext context,
    required WorkActivityLevel level,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        side: BorderSide(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: KSizes.iconL,
                ),
              ),
              SizedBox(width: KSizes.margin4x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : null,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: KSizes.iconM,
                ),
            ],
          ),
        ),
      ),
    );
  }
} 