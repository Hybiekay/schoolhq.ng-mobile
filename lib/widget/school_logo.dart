import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class SchoolLogo extends StatelessWidget {
  final String logo;
  final double size;
  final double radius;

  const SchoolLogo({
    super.key,
    required this.logo,
    required this.size,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = logo.startsWith('http://') || logo.startsWith('https://');

    if (isNetwork) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          logo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _assetFallback(),
        ),
      );
    }

    return _assetFallback(path: logo);
  }

  Widget _assetFallback({String? path}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        (path == null || path.isEmpty) ? AppImages.logo : path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Icon(
              Icons.school,
              color: AppColors.primary,
              size: size * 0.55,
            ),
          );
        },
      ),
    );
  }
}
