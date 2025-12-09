import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';

final onboardingProvider = StateProvider<bool>((ref) {
  final box = Hive.box('app');
  return box.get('onboardingDone', defaultValue: false);
});

void completeOnboarding(WidgetRef ref) {
  Hive.box('app').put('onboardingDone', true);
  ref.read(onboardingProvider.notifier).state = true;
}
