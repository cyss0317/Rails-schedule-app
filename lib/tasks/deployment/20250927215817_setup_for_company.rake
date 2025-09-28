namespace :after_party do
  desc 'Deployment task: setup_for_company'
  task setup_for_company: :environment do
    puts "Running deploy task 'setup_for_company'"

    # Put your task implementation HERE.
    user = User.find_by(email: 'hannahlee9994@gmail.com')
    if user.present?
      ActiveRecord::Base.transaction do
        company = Company.create(name: 'Cricket', user_id: user.id)
        location = Location.create(name: 'Oltorf', street_address: '2030 E Oltorf St', building_number: 'Ste 104B',
                                   city: 'Austin', state: 'Texas', zip_code: '78741', country: 'United States',
                                   company_id: company.id)
        users = User.all
        users.each do |u|
          LocationUser.create(location_id: location.id, user_id: u.id, role: u != user ? 'user' : 'admin')
        end

        Meeting.all.each do |m|
          m.update(location_id: location.id)
        end
        puts 'All the jobs ran successfully'
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
