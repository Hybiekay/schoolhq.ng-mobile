import 'package:schoolhq_ng/core/school/current_school.dart';

String currentSchoolCurrencySymbol() {
  final school = currentSchool();
  final directSymbol = school.currencySymbol.trim();
  if (directSymbol.isNotEmpty) {
    return directSymbol;
  }

  final code = school.currencyCode.trim().toUpperCase();
  switch (code) {
    case 'USD':
      return '\$';
    case 'EUR':
      return 'EUR ';
    case 'GBP':
      return 'GBP ';
    case 'KES':
      return 'KSh ';
    case 'GHS':
      return 'GH₵';
    default:
      return '₦';
  }
}

String formatSchoolMoney(dynamic value) {
  final amount = (value is num)
      ? value.toDouble()
      : double.tryParse('${value ?? 0}') ?? 0;
  final decimals = amount.abs() >= 1000 ? 0 : 2;
  return '${currentSchoolCurrencySymbol()}${amount.toStringAsFixed(decimals)}';
}
