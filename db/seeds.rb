# frozen_string_literal: true

# Idempotent seed — safe to re-run at any time.
#
# Creates:
#   • 1 developer/admin user: test@test.com  (password: asdfasdf)
#   • 1 company + 1 location
#   • 4 active employees tied to the location
#   • 4 weeks of historical morning/evening meetings (CST) so
#     ShiftGenerationService can detect patterns on the first run.
#
# Patterns seeded (every day of the week):
#   Alice + Bob  → morning shift (9AM–3PM CST) Mon–Sun
#   Carol + Dave → evening shift (3PM–9PM CST) Mon–Sun

TZ = 'America/Chicago'

EMPLOYEE_COLORS = %w[
  #546E7A
  #7E57C2
  #FFA726
  #689F38
  #FF4081
  #4FC3F7
].freeze

# ── Developer / Admin user ────────────────────────────────────────────────────

developer = User.find_or_create_by!(email: 'test@test.com') do |u|
  u.first_name  = 'Test'
  u.middle_name = ''
  u.last_name   = 'User'
  u.password    = 'asdfasdf'
  u.color       = '#8C6E63'
end

Flipper.enable_actor(:developer, Flipper::Actor.new('test@test.com'))
Flipper.enable_actor(:admin,     Flipper::Actor.new('test@test.com'))
Flipper.enable_actor(:active,    Flipper::Actor.new('test@test.com'))

# ── Company & Location ────────────────────────────────────────────────────────

company = Company.find_or_create_by!(name: 'Schedule App Demo') do |c|
  c.user = developer
end

location = Location.find_or_create_by!(name: 'Main Office') do |l|
  l.company        = company
  l.street_address = '123 N Michigan Ave'
  l.city           = 'Chicago'
  l.state          = 'IL'
  l.zip_code       = '60601'
end

# Developer gets an active admin seat at the location
LocationUser.find_or_create_by!(user: developer, location:) do |lu|
  lu.role   = 'admin'
  lu.active = true
end

# ── Employees ─────────────────────────────────────────────────────────────────

EMPLOYEE_ATTRS = [
  { first_name: 'Alice', middle_name: 'M', last_name: 'Johnson',  color: EMPLOYEE_COLORS[0] },
  { first_name: 'Bob',   middle_name: 'T', last_name: 'Williams', color: EMPLOYEE_COLORS[1] },
  { first_name: 'Carol', middle_name: 'L', last_name: 'Davis',    color: EMPLOYEE_COLORS[2] },
  { first_name: 'Dave',  middle_name: 'R', last_name: 'Martinez', color: EMPLOYEE_COLORS[3] },
].freeze

employees = EMPLOYEE_ATTRS.map do |attrs|
  email = "#{attrs[:first_name].downcase}@example.com"

  user = User.find_or_create_by!(email:) do |u|
    u.first_name  = attrs[:first_name]
    u.middle_name = attrs[:middle_name]
    u.last_name   = attrs[:last_name]
    u.password    = 'asdfasdf'
    u.color       = attrs[:color]
  end

  Flipper.enable_actor(:active, Flipper::Actor.new(email))

  LocationUser.find_or_create_by!(user:, location:) do |lu|
    lu.role   = 'user'
    lu.active = true
  end

  user
end

alice, bob, carol, dave = employees

# ── Historical meetings (8 weeks back) ────────────────────────────────────────
# Simple, consistent pattern so ShiftGenerationService detects it on first run:
#   Alice + Bob  → morning shift (9AM–3PM CST) every day Mon–Sun
#   Carol + Dave → evening shift (3PM–9PM CST) every day Mon–Sun
#
# 4 weeks matches LOOKBACK_WEEKS exactly. All slots appear 4/4 times, well
# above the ranking threshold, so the top-2 selection fires immediately.

MORNING_USERS = [alice, bob].freeze
EVENING_USERS = [carol, dave].freeze

4.times do |week_offset|
  ref_monday = (Date.today - (week_offset + 1).weeks).beginning_of_week

  (1..7).each do |cwday|
    date = ref_monday + (cwday - 1).days

    MORNING_USERS.each do |user|
      start_t = date.in_time_zone(TZ).change(hour: 9)
      end_t   = date.in_time_zone(TZ).change(hour: 15)
      Meeting.find_or_create_by!(user:, location:, start_time: start_t, end_time: end_t)
    end

    EVENING_USERS.each do |user|
      start_t = date.in_time_zone(TZ).change(hour: 15)
      end_t   = date.in_time_zone(TZ).change(hour: 21)
      Meeting.find_or_create_by!(user:, location:, start_time: start_t, end_time: end_t)
    end
  end
end

# ── Summary ───────────────────────────────────────────────────────────────────

puts <<~SUMMARY
  Seed complete.
    Company:   #{company.name}
    Location:  #{location.name} (id: #{location.id})
    Developer: #{developer.email}  [developer + admin + active]
    Employees: #{employees.map(&:first_name).join(', ')}  (password: asdfasdf)
    Meetings:  #{Meeting.where(location:).count} historical shifts seeded
SUMMARY
