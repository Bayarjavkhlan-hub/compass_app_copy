// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Stable identifiers for UI automation (Maestro flows in `.maestro/`).
///
/// Applied with `Semantics(container: true, identifier: ...)`. Flutter exposes
/// the identifier as `resource-id` on Android and `accessibilityIdentifier`
/// on iOS, so a single `id:` selector works on both platforms.
///
/// Changing a value breaks the flows that use it.
abstract final class TestIds {
  // Home
  static const bookNewTrip = 'home_book_new_trip';
  static const logoutButton = 'home_logout';
  static String bookingItem(int id) => 'home_booking_$id';

  // Shared navigation
  static const homeButton = 'nav_home';
  static const backButton = 'nav_back';

  // Search form
  static String continent(String name) =>
      'search_continent_${name.toLowerCase().replaceAll(' ', '_')}';
  static const dates = 'search_dates';
  static const guestsAdd = 'search_guests_add';
  static const guestsRemove = 'search_guests_remove';
  static const guestsCount = 'search_guests_count';
  static const searchSubmit = 'search_submit';

  // Results
  static String result(String ref) => 'result_$ref';

  // Activities
  static String activityCheckbox(String ref) => 'activity_$ref';
  static const activitiesConfirm = 'activities_confirm';

  // Booking
  static const shareTrip = 'booking_share';

  // Login
  static const loginEmail = 'login_email';
  static const loginPassword = 'login_password';
  static const loginSubmit = 'login_submit';
}
