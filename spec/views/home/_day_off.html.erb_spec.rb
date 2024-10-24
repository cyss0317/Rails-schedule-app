require 'rails_helper'

describe 'home/_day_off.html.erb', type: :view do
  let!(:admin_user) { create(:user, :admin) }
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  context 'when user is admin user' do
    let(:day_off) { create(:day_off, user: admin_user) }
    let(:date) { day_off.start_time.to_date }

    before do
      allow(view).to receive(:current_user).and_return(admin_user)
    end

    it 'displays description when mouse enter' do
      render partial: 'home/day_off', locals: { day_off:, date:, class_name: 'none' }

      expect(rendered).to have_text(day_off.off_time_info(date.in_time_zone))
      expect(rendered).to have_css('span', text: day_off.description)
    end
  end

  context 'when user is not admin user' do
    it 'displays description when mouse enter on OWN day off' do
      day_off =  create(:day_off, user:)
      date = day_off.start_time.to_date

      allow(view).to receive(:current_user).and_return(user)

      render partial: 'home/day_off', locals: { day_off:, date:, class_name: 'none' }

      expect(rendered).to have_text(day_off.off_time_info(date.in_time_zone))
      expect(rendered).to have_css('span', text: day_off.description)
    end
    it 'does NOT display description when mouse enter on OTHER employees day off' do
      day_off = create(:day_off, user_id: other_user.id)
      date = day_off.start_time.to_date

      allow(view).to receive(:current_user).and_return(user)

      render partial: 'home/day_off', locals: { day_off:, date:, class_name: 'none' }

      expect(rendered).to have_text(day_off.off_time_info(date.in_time_zone))
      expect(rendered).not_to have_css('span', text: day_off.description)
    end
  end
end
