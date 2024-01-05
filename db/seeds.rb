# frozen_string_literal: true
require 'factory_bot_rails'
require_relative './seeds/company_seeder'
require_relative './seeds/location_seeder'
require_relative './seeds/user_seeder'
require_relative './seeds/meeting_seeder'

User.delete_all
Company.delete_all
Location.delete_all
Meeting.delete_all

CompanySeeder.seed!
LocationSeeder.seed!
UserSeeder.seed!
MeetingSeeder.seed!
