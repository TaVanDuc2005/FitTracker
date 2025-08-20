import 'package:flutter/material.dart';

// Import your step screens
import 'Step1_UserInfo.dart';
import 'Step2_Lifestyle.dart';
import 'Step3_DietaryRestrictions.dart';
import 'Step4_ListDietaryRestriction.dart';
import 'Step5_HealthGoal.dart';
import 'Step6_ResultSummary.dart';

enum StepScreen {
  policyAgreement,
  login,
  step1UserInfo,
  step2Lifestyle,
  step3DietaryRestrictions,
  step4ListDietaryRestriction,
  step5HealthGoal,
  step6ResultSummary,
}

class StepFlow extends StatefulWidget {
  const StepFlow({super.key});

  @override
  _StepFlowState createState() => _StepFlowState();
}

class _StepFlowState extends State<StepFlow> {
  StepScreen currentStep = StepScreen.step1UserInfo;

  void goToNextStep() {
    setState(() {
      switch (currentStep) {
        case StepScreen.step1UserInfo:
          currentStep = StepScreen.step2Lifestyle;
          break;
        case StepScreen.step2Lifestyle:
          currentStep = StepScreen.step3DietaryRestrictions;
          break;
        case StepScreen.step3DietaryRestrictions:
          currentStep = StepScreen.step4ListDietaryRestriction;
          break;
        case StepScreen.step4ListDietaryRestriction:
          currentStep = StepScreen.step5HealthGoal;
          break;
        case StepScreen.step5HealthGoal:
          currentStep = StepScreen.step6ResultSummary;
          break;
        default:
          break;
      }
    });
  }

  void goToPreviousStep() {
    setState(() {
      switch (currentStep) {
        case StepScreen.step2Lifestyle:
          currentStep = StepScreen.step1UserInfo;
          break;
        case StepScreen.step3DietaryRestrictions:
          currentStep = StepScreen.step2Lifestyle;
          break;
        case StepScreen.step4ListDietaryRestriction:
          currentStep = StepScreen.step3DietaryRestrictions;
          break;
        case StepScreen.step5HealthGoal:
          currentStep = StepScreen.step4ListDietaryRestriction;
          break;
        case StepScreen.step6ResultSummary:
          currentStep = StepScreen.step5HealthGoal;
          break;
        default:
          break;
      }
    });
  }

  void skipToStep(StepScreen step) {
    setState(() {
      currentStep = step;
    });
  }

  int getStepNumber(StepScreen step) {
    switch (step) {
      case StepScreen.step1UserInfo:
        return 1;
      case StepScreen.step2Lifestyle:
        return 2;
      case StepScreen.step3DietaryRestrictions:
        return 3;
      case StepScreen.step4ListDietaryRestriction:
        return 4;
      case StepScreen.step5HealthGoal:
        return 5;
      case StepScreen.step6ResultSummary:
        return 6;
      default:
        return -1;
    }
  }

  Widget _buildStepScreen() {
    switch (currentStep) {
      case StepScreen.step1UserInfo:
        return Step1UserInfo(
          onNext: goToNextStep,
          onBack: goToPreviousStep,
          onSkip: () => skipToStep(StepScreen.step6ResultSummary),
        );
      case StepScreen.step2Lifestyle:
        return Step2Lifestyle(
          onNext: goToNextStep,
          onBack: goToPreviousStep,
          onSkip: () => skipToStep(StepScreen.step6ResultSummary),
        );
      case StepScreen.step3DietaryRestrictions:
        return Step3DietaryRestriction(
          onNext: goToNextStep,
          onBack: goToPreviousStep,
          onSkip: () => skipToStep(StepScreen.step6ResultSummary),
          onDecision: (bool decision) {},
        );
      case StepScreen.step4ListDietaryRestriction:
        return Step4ListDietaryRestrictions(
          onNext: goToNextStep,
          onBack: goToPreviousStep,
          onSkip: () => skipToStep(StepScreen.step6ResultSummary),
        );
      case StepScreen.step5HealthGoal:
        return Step5HealthGoal(
          onNext: goToNextStep,
          onBack: goToPreviousStep,
          onSkip: () => skipToStep(StepScreen.step6ResultSummary),
        );
      case StepScreen.step6ResultSummary:
        return Step6IdealWeight(
          onNext: goToNextStep,
          onPrevious: goToPreviousStep,
        );
      default:
        return const Center(child: Text("Unknown step"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildStepScreen());
  }
}
