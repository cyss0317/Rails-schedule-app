class LocationSeeder
  def self.seed!
    Location.create!(
      name: 'Cricket Wireless',
      address: '2030 E Oltorf St Ste 104B, Austin, TX 78741',
      phone_number: '512-912-9479',
      company_id: Company.find_by(name: 'Central Texas Connection').id
    )
  end
end
