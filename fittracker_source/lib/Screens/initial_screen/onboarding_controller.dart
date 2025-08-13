import 'package:flutter/material.dart';
import 'Step1_UserInfo.dart';
import 'Step2_Lifestyle.dart';
import 'Step3_DietaryRestrictions.dart';
import 'Step4_ListDietaryRestriction.dart';
import 'Step5_HealthGoal.dart';
import 'Step6_ResultSummary.dart';
import 'Policy_Agreement_Screen.dart';
import 'Login_Screen.dart';
import '../../services/user_service.dart';
import 'Loading_Screen.dart';

enum StepScreen {
  step1UserInfo,
  step2Lifestyle,
  step3DietaryRestriction,
  step4DietaryRestrictions,
  policyAgreement,
  login,
  step5HealthGoal,
  step6IdealWeight,
}

class StepProgressForm extends StatefulWidget {
  const StepProgressForm({super.key});

  @override
  State<StepProgressForm> createState() => _StepProgressFormState();
}

class _StepProgressFormState extends State<StepProgressForm> {
  StepScreen currentScreen = StepScreen.step1UserInfo;

  bool skipStep4 = false;
  static const int totalSteps = 6;

  double? userHeight;
  double? userWeight;
  String? userGoal;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userHeight = await UserService.getHeight() ?? 0;
    userWeight = await UserService.getWeight() ?? 0;
    userGoal = await UserService.getGoal() ?? '';
    setState(() {});
  }

  int getStepNumber(StepScreen screen) {
    switch (screen) {
      case StepScreen.step1UserInfo:
        return 1;
      case StepScreen.step2Lifestyle:
        return 2;
      case StepScreen.step3DietaryRestriction:
        return 3;
      case StepScreen.step4DietaryRestrictions:
        return 4;
      case StepScreen.policyAgreement:
        return 0;
      case StepScreen.login:
        return 0;
      case StepScreen.step5HealthGoal:
        return 1;
      case StepScreen.step6IdealWeight:
        return 2;
    }
  }

  void goToCustomStep(int stepIndex) {
    setState(() {
      switch (stepIndex) {
        case 1:
          currentScreen = StepScreen.step1UserInfo;
          break;
        case 2:
          currentScreen = StepScreen.step2Lifestyle;
          break;
        case 3:
          currentScreen = StepScreen.step3DietaryRestriction;
          break;
        case 4:
          currentScreen = StepScreen.step4DietaryRestrictions;
          break;
        case 5:
          currentScreen = StepScreen.policyAgreement;
          break;
        case 6:
          currentScreen = StepScreen.step5HealthGoal;
          break;
        case 7:
          currentScreen = StepScreen.step6IdealWeight;
          break;
        default:
          currentScreen = StepScreen.step1UserInfo;
      }
    });
  }

  void goToNextStep() {
    setState(() {
      switch (currentScreen) {
        case StepScreen.step1UserInfo:
          currentScreen = StepScreen.step2Lifestyle;
          break;
        case StepScreen.step2Lifestyle:
          currentScreen = StepScreen.step3DietaryRestriction;
          break;
        case StepScreen.step3DietaryRestriction:
          if (skipStep4) {
            currentScreen = StepScreen.policyAgreement;
          } else {
            currentScreen = StepScreen.step4DietaryRestrictions;
          }
          break;
        case StepScreen.step4DietaryRestrictions:
          currentScreen = StepScreen.policyAgreement;
          break;
        case StepScreen.policyAgreement:
          currentScreen = StepScreen.login;
          break;
        case StepScreen.login:
          currentScreen = StepScreen.step5HealthGoal;
          break;
        case StepScreen.step5HealthGoal:
          currentScreen = StepScreen.step6IdealWeight;
          break;
        case StepScreen.step6IdealWeight:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoadingScreen()),
          );
          break;
      }
    });
  }

  void goToPreviousStep() {
    setState(() {
      switch (currentScreen) {
        case StepScreen.step1UserInfo:
          Navigator.pop(context);
          break;
        case StepScreen.step2Lifestyle:
          currentScreen = StepScreen.step1UserInfo;
          break;
        case StepScreen.step3DietaryRestriction:
          currentScreen = StepScreen.step2Lifestyle;
          break;
        case StepScreen.step4DietaryRestrictions:
          currentScreen = StepScreen.step3DietaryRestriction;
          break;
        case StepScreen.policyAgreement:
          if (skipStep4) {
            currentScreen = StepScreen.step3DietaryRestriction;
          } else {
            currentScreen = StepScreen.step4DietaryRestrictions;
          }
          break;
        case StepScreen.login:
          currentScreen = StepScreen.policyAgreement;
          break;
        case StepScreen.step5HealthGoal:
          currentScreen = StepScreen.login;
          break;
        case StepScreen.step6IdealWeight:
          currentScreen = StepScreen.step5HealthGoal;
          break;
      }
    });
  }

  void handleStep3Decision(bool skip) {
    skipStep4 = skip;
  }

  Widget _buildProgressBar() {
    if (currentScreen == StepScreen.policyAgreement ||
        currentScreen == StepScreen.login) {
      return const SizedBox.shrink();
    }

    if (currentScreen == StepScreen.step5HealthGoal ||
        currentScreen == StepScreen.step6IdealWeight) {
      final currentStep = currentScreen == StepScreen.step5HealthGoal ? 1 : 2;
      const totalSteps = 2;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        child: Row(
          children: List.generate(totalSteps, (index) {
            final stepNum = index + 1;
            final isCompleted = stepNum < currentStep;
            final isActive = stepNum == currentStep;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isCompleted
                      ? Colors.orange
                      : isActive
                      ? Colors.orange.withOpacity(0.9)
                      : Colors.grey.shade300,
                ),
              ),
            );
          }),
        ),
      );
    }

    final currentStep = getStepNumber(currentScreen);
    const totalSteps = 6;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNum = index + 1;
          final isCompleted = stepNum < currentStep;
          final isActive = stepNum == currentStep;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isCompleted
                    ? Colors.orange
                    : isActive
                    ? Colors.orange.withOpacity(0.9)
                    : Colors.grey.shade300,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (currentScreen) {
      case StepScreen.step1UserInfo:
        return Step1UserInfo(onNext: goToNextStep, onBack: goToPreviousStep);
      case StepScreen.step2Lifestyle:
        return Step2Lifestyle(onNext: goToNextStep, onBack: goToPreviousStep);
      case StepScreen.step3DietaryRestriction:
        return Step3DietaryRestriction(
          onNext: goToNextStep,
          onBack: goToPreviousStep,
          onDecision: handleStep3Decision,
          onSkipToStep: goToCustomStep,
        );
      case StepScreen.step4DietaryRestrictions:
        return Step4ListDietaryRestrictions(
          onNext: goToNextStep,
          onBack: goToPreviousStep,
        );
      case StepScreen.policyAgreement:
        return PolicyAgreementScreen(
          onNext: goToNextStep,
          onPrevious: goToPreviousStep,
        );
      case StepScreen.login:
        return LoginScreen(onNext: goToNextStep, onBack: goToPreviousStep);
      case StepScreen.step5HealthGoal:
        return Step5HealthGoal(onNext: goToNextStep, onBack: goToPreviousStep);
      case StepScreen.step6IdealWeight:
        return Step6IdealWeight(
          onNext: goToNextStep,
          onPrevious: goToPreviousStep,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProgressBar(),
            const SizedBox(height: 12),
            Expanded(child: _buildCurrentScreen()),
          ],
        ),
      ),
    );
  }
}
