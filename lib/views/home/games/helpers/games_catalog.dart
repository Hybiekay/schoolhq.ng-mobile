import 'package:flutter/material.dart';
import 'package:schoolhq_ng/routes/route_names.dart';

final gamesFeaturedModes = <Map<String, dynamic>>[
  {
    'title': 'Math Sprint',
    'subtitle': 'Quick-fire number rounds with streak points.',
    'icon': Icons.calculate_rounded,
    'gradient': const LinearGradient(
      colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'badge': 'Speed Lab',
    'route': RouteNames.mathSprint,
    'action': 'Start sprint',
  },
  {
    'title': 'Word Builder',
    'subtitle': 'Grow vocabulary and subject keywords under time pressure.',
    'icon': Icons.spellcheck_rounded,
    'gradient': const LinearGradient(
      colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'badge': 'Language Boost',
    'action': 'Coming soon',
  },
  {
    'title': 'Science Quest',
    'subtitle': 'Explore bite-size concept challenges from class topics.',
    'icon': Icons.rocket_launch_rounded,
    'gradient': const LinearGradient(
      colors: [Color(0xFF059669), Color(0xFF14B8A6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'badge': 'Discovery Mode',
    'action': 'Coming soon',
  },
];

final gamesDailyMissions = <Map<String, dynamic>>[
  {
    'title': 'Daily streak',
    'value': '7 days',
    'icon': Icons.local_fire_department_rounded,
  },
  {'title': 'Quick duels', 'value': '12 ready', 'icon': Icons.flash_on_rounded},
  {'title': 'Warm-up time', 'value': '5 mins', 'icon': Icons.timer_rounded},
  {'title': 'Reward stars', 'value': '128', 'icon': Icons.auto_awesome_rounded},
];
