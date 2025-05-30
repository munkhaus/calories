import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';

/// Information page with comprehensive disclaimers and liability protection
class InfoPage extends StatelessWidget {
  final bool isInitialView;
  final VoidCallback? onAccepted;

  const InfoPage({
    super.key,
    this.isInitialView = false,
    this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isInitialView ? null : AppBar(
        title: Text(
          'Information og Ansvarsfraskrivelse',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(KSizes.margin4x),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isInitialView) ...[
                  // Initial welcome header
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          MdiIcons.informationOutline,
                          size: 64,
                          color: AppColors.primary,
                        ),
                        KSizes.spacingVerticalL,
                        Text(
                          'Vigtig Information',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: KSizes.fontWeightBold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        KSizes.spacingVerticalM,
                        Text(
                          'Læs venligst følgende information før du bruger appen',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  KSizes.spacingVerticalXL,
                ],

                // Main disclaimer sections
                _buildDisclaimerSection(
                  context,
                  'Generel Ansvarsfraskrivelse',
                  'Informationen i denne app er udelukkende til generel vejledning og må under ingen omstændigheder opfattes som medicinsk, ernæringsfaglig eller sundhedsmæssig rådgivning. Appen erstatter ikke professionel medicinsk konsultation, diagnose eller behandling.\n\nBrug af denne app sker på eget ansvar. Udvikleren påtager sig intet ansvar for eventuelle skader, tab eller konsekvenser der måtte opstå som følge af brug af appen eller de oplysninger den indeholder.',
                  MdiIcons.shieldAlert,
                  AppColors.error,
                ),

                KSizes.spacingVerticalL,

                _buildDisclaimerSection(
                  context,
                  'Kalorie Beregninger',
                  'Alle kalorie beregninger, TDEE estimater og ernæringsMål er baseret på generelle formler og algoritmer. Disse beregninger er vejledende og kan variere betydeligt fra dit faktiske behov.\n\nIndividuelle faktorer som genetik, sundhedstilstand, medicin, hormonelle forhold og andre fysiologiske faktorer kan påvirke dit energibehov væsentligt. Appen kan ikke og skal ikke erstatte professionel metabolisk måling eller medicinsk vurdering.',
                  MdiIcons.calculator,
                  AppColors.warning,
                ),

                KSizes.spacingVerticalL,

                _buildDisclaimerSection(
                  context,
                  'Sundhed og Vægttab',
                  'Appen giver ikke sundhedsrådgivning eller garantier for vægttab. Vægttab og ernæringsændringer kan have sundhedsmæssige konsekvenser og bør altid diskuteres med en læge eller autoriseret ernæringsekspert.\n\nPersoner med kroniske sygdomme, spiseforstyrrelser, metaboliske lidelser eller andre sundhedsproblemer bør konsultere en sundhedsprofessionel før de ændrer deres kost eller aktivitetsniveau.\n\nAppen anbefaler ikke ekstreme diæter eller hurtige vægttab. Enhver vægtændring bør ske gradvist og under faglig vejledning.',
                  MdiIcons.heartPulse,
                  AppColors.info,
                ),

                KSizes.spacingVerticalL,

                _buildDisclaimerSection(
                  context,
                  'Tekniske Begrænsninger',
                  'Appen er ikke et medicinsk device og er ikke valideret til klinisk brug. Data fra appen bør ikke bruges til medicinske beslutninger.\n\nAppens beregninger kan indeholde fejl eller unøjagtigheder. Brugerindtastede data kan være forkerte eller upræcise, hvilket påvirker alle beregninger.\n\nUdvikleren garanterer ikke appens nøjagtighed, pålidelighed eller egnethed til specifikke formål.',
                  MdiIcons.alertCircle,
                  AppColors.textSecondary,
                ),

                KSizes.spacingVerticalL,

                _buildDisclaimerSection(
                  context,
                  'Ansvarsfraskrivelse',
                  'Ved at bruge denne app accepterer du at:\n\n• Du bruger appen på eget ansvar\n• Du ikke holder udvikleren ansvarlig for eventuelle konsekvenser\n• Du forstår at appen ikke giver medicinsk rådgivning\n• Du vil konsultere en sundhedsprofessionel ved tvivl\n• Du accepterer at appens beregninger er estimater og ikke garantier\n\nHvis du ikke accepterer disse vilkår, bør du ikke bruge appen.',
                  MdiIcons.gavel,
                  AppColors.primary,
                ),

                if (isInitialView) ...[
                  KSizes.spacingVerticalXL,
                  
                  // Accept button for initial view
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onAccepted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: KSizes.margin4x,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                        ),
                      ),
                      child: Text(
                        'Jeg forstår og accepterer',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeL,
                          fontWeight: KSizes.fontWeightBold,
                        ),
                      ),
                    ),
                  ),
                  
                  KSizes.spacingVerticalM,
                  
                  Text(
                    'Ved at trykke "Jeg forstår og accepterer" bekræfter du at du har læst og forstået ovenstående information og accepterer at bruge appen på eget ansvar.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                KSizes.spacingVerticalXL,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: KSizes.iconM,
                ),
              ),
              KSizes.spacingHorizontalM,
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: KSizes.fontWeightBold,
                  ),
                ),
              ),
            ],
          ),
          
          KSizes.spacingVerticalM,
          
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 