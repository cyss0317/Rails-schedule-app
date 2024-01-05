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
  end
end
