class UserSeeder
  def self.seed!
    User.create!(
      first_name: 'Hannah',
      middle_name: 'Lee',
      last_name: 'Choi',
      password: 'asdfasdf',
      email: 'hannahlee9994@gmail.com',
      phone_number: '254-449-0828',
      company_id: Company.find_by(name: 'Central Texas Connection').id,
      location_id: Location.find_by(name: 'Cricket Wireless').id
    )

    UserSeeder.create_test_user
    UserSeeder.create_maximum_3_user
  end

  def self.create_maximum_3_user
    FactoryBot.create(:user, :under_texas_central_connection) while User.count < 4
  end

  def self.create_test_user
    FactoryBot.create(
      :user,
      email: 'test@test.com',
      password: 'asdfasdf',
      color: Faker::Color.hex_color
    )
  end
end
