import 'package:flutter/material.dart';

import '../../app/auth_dependencies.dart';
import '../../app/data_session.dart';
import '../../app/reminder_notifications.dart';
import '../../core/app_state.dart';
import '../../core/design_tokens.dart';
import '../../core/widgets/section_hero.dart';
import '../auth/presentation.dart';
import '../games/presentation/game_catalog_page.dart';

part 'parts/main_scaffold.dart';
part 'parts/home_dashboard.dart';
part 'parts/caregiver_dashboard.dart';
part 'parts/reminder_views.dart';
part 'parts/album_views.dart';
part 'parts/health_forms.dart';
part 'parts/settings_sheet.dart';
part 'parts/bottom_nav_item.dart';
part 'parts/care_link_screen.dart';

extension on Lembrete {
  IconData get icone => _iconFromCode(iconCodePoint);
  set icone(IconData value) => iconCodePoint = value.codePoint;
}

extension on Pessoa {
  IconData get icone => _iconFromCode(iconCodePoint);
  Color get cor => Color(colorArgb);
}

IconData _iconFromCode(int code) {
  if (code == Icons.medication_outlined.codePoint)
    return Icons.medication_outlined;
  if (code == Icons.local_drink_outlined.codePoint)
    return Icons.local_drink_outlined;
  if (code == Icons.psychology_outlined.codePoint)
    return Icons.psychology_outlined;
  if (code == Icons.directions_walk_outlined.codePoint)
    return Icons.directions_walk_outlined;
  if (code == Icons.restaurant_outlined.codePoint)
    return Icons.restaurant_outlined;
  if (code == Icons.people_outline.codePoint) return Icons.people_outline;
  if (code == Icons.bedtime_outlined.codePoint) return Icons.bedtime_outlined;
  if (code == Icons.local_hospital_outlined.codePoint)
    return Icons.local_hospital_outlined;
  if (code == Icons.person.codePoint) return Icons.person;
  return Icons.notifications_outlined;
}
