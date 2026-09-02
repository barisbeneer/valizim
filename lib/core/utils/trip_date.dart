/// Calendar-date helpers.
///
/// A trip's start date is a *calendar date*, not an instant. Storing it as a
/// local `DateTime` would let a DST change or a flight across time zones move a
/// trip to the previous or next day. So the rule throughout the app is:
///
///  * persist the date as UTC midnight of the intended calendar day
///    ([toStorage]);
///  * never do arithmetic on the stored instant - pull year/month/day out of it
///    and rebuild in the local zone ([toLocalDayStart], [atLocalTime]).
///
/// Every conversion in the app goes through this class so the rule is enforced
/// in one place and can be tested against real DST transitions.
abstract final class TripDate {
  const TripDate._();

  /// Normalises any [DateTime] to UTC midnight of its *local* calendar day.
  static DateTime toStorage(DateTime local) =>
      DateTime.utc(local.year, local.month, local.day);

  /// Today's calendar date, in storage form.
  static DateTime today({DateTime? now}) => toStorage(now ?? DateTime.now());

  /// Rebuilds the stored calendar day as local midnight.
  static DateTime toLocalDayStart(DateTime stored) =>
      DateTime(stored.year, stored.month, stored.day);

  /// Rebuilds the stored calendar day at a local wall-clock time.
  ///
  /// This is deliberately a *local* construction: on a spring-forward day the
  /// requested hour may not exist, and Dart resolves that the same way the OS
  /// clock does, which is what a user expects from an alarm.
  static DateTime atLocalTime(DateTime stored, int hour, int minute) =>
      DateTime(stored.year, stored.month, stored.day, hour, minute);

  /// Whole calendar days from today to [stored]. Negative for past dates.
  ///
  /// Both ends are reduced to UTC midnight *before* subtracting. Differencing
  /// two local midnights instead would be wrong across a DST boundary: five
  /// calendar days spanning a spring-forward is 119 elapsed hours, and
  /// `Duration.inDays` truncates that to 4.
  static int daysFromToday(DateTime stored, {DateTime? now}) {
    final from = toStorage(now ?? DateTime.now());
    final to = DateTime.utc(stored.year, stored.month, stored.day);
    return to.difference(from).inDays;
  }

  /// Last calendar day of a trip: start plus `durationDays - 1`.
  ///
  /// The day is added by *constructing* the date rather than by adding a
  /// `Duration`. `Duration(days: n)` is exactly `n * 24h`, but a local day
  /// containing a DST transition is 23 or 25 hours, so adding four of them to a
  /// 29 October start in Berlin lands at 23:00 on 1 November - a day early.
  /// `DateTime.utc` normalises day overflow and has no DST at all.
  static DateTime endDate(DateTime start, int durationDays) {
    final days = durationDays < 1 ? 1 : durationDays;
    return DateTime.utc(start.year, start.month, start.day + (days - 1));
  }

  /// True when the trip's last day is strictly before today.
  static bool isPast(DateTime start, int durationDays, {DateTime? now}) =>
      daysFromToday(endDate(start, durationDays), now: now) < 0;

  /// Same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
