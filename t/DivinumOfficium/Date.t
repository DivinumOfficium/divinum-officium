use strict;
use warnings;
use DivinumOfficium::Date
   qw(getweek leapyear geteaster get_sday nextday day_of_week monthday prevnext ydays_to_date date_to_ydays);
use Test::Simple tests => 75;

### leapyear
# Given the purpose of this application, we only need to test the Gregorian leap year rules, not the Julian ones,
# Meaning that we only need to test years from 1582 onward.
# TODO:
# Add robustness & input validation tests:
#  - String inputs as "2024" (Perl dynamically handles string-to-number conversions, we need to ensure it parses correctly)
#  - Invalid inputs ("abc", undef, or floats like 2024.5)

ok(leapyear(1996), '1996 is a leap year');
ok(leapyear(2024), '2024 is a leap year');
ok(leapyear(2028), '2028 is a leap year');
ok(leapyear(1600), '1600 is a leap year (div by 400)');
ok(leapyear(2000), '2000 is a leap year (div by 400)');
ok(leapyear(2400), '2400 is a leap year (div by 400)');
ok(!leapyear(1900), '1900 is not a leap year (div by 100, not 400)');
ok(!leapyear(2100), '2100 is not a leap year (div by 100, not 400)');
ok(!leapyear(1999), '1999 is not a leap year');
ok(!leapyear(2023), '2023 is not a leap year');
ok(!leapyear(2026), '2026 is not a leap year');

### geteaster
# Reference dates cross-checked against published Easter tables.
# TODO: Add robustness & input validation tests (e.g., invalid years)

ok(join(',', geteaster(2024)) eq '31,3,2024', 'Easter 2024 is March 31');
ok(join(',', geteaster(2025)) eq '20,4,2025', 'Easter 2025 is April 20');
ok(join(',', geteaster(2000)) eq '23,4,2000', 'Easter 2000 is April 23');

### date_to_ydays / ydays_to_date round-trip
# TODO: Add robustness & input validation tests (e.g., invalid dates)

ok(date_to_ydays(1, 1, 2024) == 1, '1 Jan is day 1 of the year');
ok(date_to_ydays(31, 12, 2023) == 365, '31 Dec of non-leap year is day 365');
ok(date_to_ydays(31, 12, 2024) == 366, '31 Dec of leap year is day 366');
ok(date_to_ydays(29, 2, 2024) == 60, '29 Feb is day 60 in a leap year');

ok(join(',', ydays_to_date(1, 2024)) eq '1,1,2024', 'Day 1 round-trips to 1 Jan');
ok(join(',', ydays_to_date(60, 2024)) eq '29,2,2024', 'Day 60 round-trips to 29 Feb in a leap year');
ok(join(',', ydays_to_date(366, 2024)) eq '31,12,2024', 'Day 366 round-trips to 31 Dec in a leap year');

### day_of_week
# 0 = Sunday .. 6 = Saturday (Monday 1 Jan 2024 confirmed against a real calendar).
# TODO: Add robustness & input validation tests (e.g., invalid dates)

ok(day_of_week(1, 1, 2024) == 1, '1 Jan 2024 was a Monday');
ok(day_of_week(7, 1, 2024) == 0, '7 Jan 2024 was a Sunday');
ok(!defined(day_of_week(0, 1, 2024)), 'Falsy day returns undef');

### get_sday
# In leap years the internal folder day is shifted: 24 Feb is kept as the
# 'leap day' (29), and 25-29 Feb are each renumbered back by one.
# TODO: Add robustness & input validation tests (e.g., invalid dates)

ok(get_sday(2, 24, 2024) eq '02-29', 'Leap year: 24 Feb maps to folder 02-29');
ok(get_sday(2, 25, 2024) eq '02-24', 'Leap year: 25 Feb maps to folder 02-24');
ok(get_sday(2, 29, 2024) eq '02-28', 'Leap year: 29 Feb maps to folder 02-28');
ok(get_sday(2, 23, 2024) eq '02-23', 'Leap year: days before 24 Feb are unaffected');
ok(get_sday(2, 24, 2023) eq '02-24', 'Non-leap year: 24 Feb is unaffected');
ok(get_sday(3, 1, 2024) eq '03-01', 'Months other than Feb are unaffected');

### nextday

ok(nextday(12, 31, 2023) eq '01-01', '31 Dec rolls over into 1 Jan of next year');
ok(nextday(1, 1, 2024) eq '01-02', '1 Jan advances to 2 Jan');
ok(nextday(2, 23, 2024) eq '02-29', 'In a leap year, the day after 23 Feb is folder 02-29 (the leap day)');
ok(nextday(2, 24, 2024) eq '02-24', 'In a leap year, the day after 24 Feb is folder 02-24 (real 25 Feb)');
ok(nextday(2, 28, 2024) eq '02-28', 'In a leap year, the day after 28 Feb is folder 02-28 (real 29 Feb)');
ok(nextday(2, 29, 2024) eq '03-01', 'In a leap year, the day after 29 Feb is folder 03-01');
ok(nextday(2, 28, 2023) eq '03-01', 'In a non-leap year, the day after 28 Feb is 1 Mar');

### prevnext

ok(prevnext('12-31-2023', 1) eq '01-01-2024', 'prevnext steps forward across a year boundary');
ok(prevnext('01-01-2024', -1) eq '12-31-2023', 'prevnext steps backward across a year boundary');
ok(prevnext('06-15-2024', 5) eq '06-20-2024', 'prevnext steps forward within a month');
ok(prevnext('02-28-2024', 1) eq '02-29-2024', 'prevnext steps forward a day in leap year');
ok(prevnext('02-29-2024', 1) eq '03-01-2024', 'prevnext steps forward a day in leap year');
ok(prevnext('02-28-2025', 1) eq '03-01-2025', 'prevnext steps forward a day in non leap year');
ok(prevnext('02-29-2024', -1) eq '02-28-2024', 'prevnext steps backward a day in leap year');
ok(prevnext('03-01-2024', -1) eq '02-29-2024', 'prevnext steps backward a day in leap year');
ok(prevnext('03-01-2025', -1) eq '02-28-2025', 'prevnext steps backward a day in non leap year');

### getweek
# Spot checks at the season boundaries, cross-checked against the
# liturgical calendar for the given years (Easter 2024 = 31 March).

ok(getweek(1, 1, 2024) eq 'Nat01', '1 Jan (before Epiphany octave ends) is in the Nativity season');
ok(getweek(7, 1, 2024) eq 'Epi1', '7 Jan 2024 is the first week after Epiphany');
ok(getweek(28, 1, 2024) eq 'Quadp1', '28 Jan 2024 is Septuagesima week (Quadp1)');
ok(getweek(11, 2, 2024) eq 'Quadp3', '11 Feb 2024 is Quinquagesima week (Quadp3)');
ok(getweek(18, 2, 2024) eq 'Quad1', '18 Feb 2024 is the first week of Lent');
ok(getweek(31, 3, 2024) eq 'Pasc0', 'Easter Sunday itself is Pasc0');
ok(getweek(19, 5, 2024) eq 'Pasc7', '19 May 2024 (Whit Sunday) is the seventh Sunday after Easter (Pasc7)');
ok(getweek(1, 12, 2024) eq 'Adv1', '1 Dec 2024 is the first Sunday of Advent');
ok(getweek(25, 12, 2024) eq 'Nat25', 'Christmas Day is Nat25');
ok(getweek(14,1,2016) eq 'Epi1', '14 Jan 2016 is in the first week after Epiphany');
ok(getweek(7,2,2016) eq 'Quadp3', '7 Feb 2016 is Quinquagesima Sunday (Quadp3)');
ok(getweek(20,2,2016) eq 'Quad1', '20 Feb 2016 is the first week of Lent (Ember Saturday)');
ok(getweek(12,3,2016) eq 'Quad4', '12 Mar 2016 is the fourth week of Lent');
ok(getweek(4,4,2016) eq 'Pasc1', '4 Apr 2016 is the week of the first Sunday after Easter (Pasc1)');
ok(getweek(5,5,2016) eq 'Pasc5', '5 May 2016 is Ascension Thursday week (Pasc5)');
ok(getweek(23,5,2016) eq 'Pent01', '23 May 2016 is Monday of first week after the octave of Pentecost (Pent01)');
ok(getweek(11,9,2016) eq 'Pent17', '11 Sept 2016 is week 17 after the octave of Pentecost');
ok(getweek(24,9,2016) eq 'Pent18', '24 Sept 2016 is week 18 after the octave of Pentecost; ember week');
ok(getweek(11,12,2016) eq 'Adv3', '11 Dec 2016 is the third Sunday of Advent (Gaudete Sunday)');
ok(getweek(17,12,2016) eq 'Adv3', '18 Dec 2016 is the Saturday after the third Sunday of Advent');

# "Resumed Epiphany" weeks and the Pent23/Pent24 boundary near the end of the
# liturgical year, verified for 2024 (Easter 31 March).
ok(getweek(1, 11, 2024) eq 'Pent23', '1 Nov 2024 is still Pent23');
ok(getweek(8, 11, 2024) eq 'Epi4', '8 Nov 2024 falls back to a resumed Epiphany week (Epi4)');
ok(getweek(22, 11, 2024) eq 'Epi6', '22 Nov 2024 is the last resumed Epiphany week (Epi6)');
ok(getweek(29, 11, 2024) eq 'Pent24', '29 Nov 2024 is the last week of the liturgical year (Pent24)');
ok(getweek(01, 12, 2024) eq 'Adv1', '1 Dec 2024 is the first week of Advent (Adv1)');

### monthday
# 1960-rubrics-specific week-skip logic in Aug-Nov.

# October: with the 1960 rubrics, the III week of October vanishes when the
# first Sunday of October falls on the 4th-7th (as it does in 2024, when 1
# Oct is a Tuesday).
ok(monthday(13, 10, 2024, 1) eq '102-0', '1960 rubrics skip the III week of October in 2024');
ok(monthday(13, 10, 2024, 0) eq '103-0', 'Traditional rubrics keep the III week of October in 2024');

# November: with the 1960 rubrics, the II week of November always vanishes.
ok(monthday(8, 11, 2023, 1) eq '111-3', '1960 rubrics skip the II week of November (2023)');
ok(monthday(8, 11, 2023, 0) eq '112-3', 'Traditional rubrics keep the II week of November (2023)');
