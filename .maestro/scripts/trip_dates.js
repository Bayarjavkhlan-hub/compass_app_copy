// Computes a trip date range relative to today and exposes it as
// accessibility-label fragments matching Flutter's date picker,
// e.g. "November 16, 2026". Used by subflows/select_dates.yaml.
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'];

function label(daysFromToday) {
  const d = new Date();
  d.setDate(d.getDate() + daysFromToday);
  return MONTHS[d.getMonth()] + ' ' + d.getDate() + ', ' + d.getFullYear();
}

// START_OFFSET / LENGTH can be passed as env; default: a 3-day trip starting in 2 days.
const start = Number(typeof START_OFFSET !== 'undefined' ? START_OFFSET : 2);
const length = Number(typeof LENGTH !== 'undefined' ? LENGTH : 3);
output.tripStart = label(start);
output.tripEnd = label(start + length);
