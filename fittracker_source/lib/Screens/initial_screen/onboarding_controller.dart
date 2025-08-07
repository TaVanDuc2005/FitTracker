import 'package:flutter/material.dart';
import 'Step1_UserInfo.dart';
import 'Step2_Lifestyle.dart';
import 'Step3_DietaryRestrictions.dart';
import 'Step4_ListDietaryRestriction.dart';
import 'Step5_HealthGoal.dart';

class StepProgressForm extends StatefulWidget {
  const StepProgressForm({super.key});

  @override
  State<StepProgressForm> createState() => _StepProgressFormState();
}

class _StepProgressFormState extends State<StepProgressForm> {
  int currentStep = 1;
  int previousStep = 1;

  void goToNextStep() {
    if (currentStep < 5) {
      setState(() {
        currentStep++;
      });
    }
  }

  void goToPreviousStep() {
    setState(() {
      if (currentStep == 5 && previousStep == 3) {
        currentStep = 3;
        previousStep = 1; // reset sau khi quay lại
      } else if (currentStep > 1) {
        currentStep--;
      }
    });
  }

  void goToCustomStep(int step) {
    if (step >= 1 && step <= 5) {
      setState(() {
        previousStep = currentStep;
        currentStep = step;
      });
    }
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Row(
        children: List.generate(5, (index) {
          final step = index + 1;
          final isCompleted = step < currentStep;
          final isActive = step == currentStep;
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

  Widget _buildCurrentStepWidget() {
    switch (currentStep) {
      case 1:
        return Step1UserInfo(onNext: goToNextStep, onBack: goToPreviousStep);
      case 2:
        return Step2Lifestyle(onNext: goToNextStep, onBack: goToPreviousStep);
      case 3:
        return Step3DietaryRestriction(
          onNext: goToNextStep,
          onBack: goToPreviousStep,
          onSkipToStep: goToCustomStep,
        );
      case 4:
        return Step4ListDietaryRestrictions(onNext: goToNextStep, onBack: goToPreviousStep);
      case 5:
        return Step5HealthGoal(onBack: goToPreviousStep);
      default:
        return const SizedBox.shrink();
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
            Expanded(child: _buildCurrentStepWidget()),
          ],
        ),
      ),
    );
  }
}
