# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'meetings/edit', type: :view do
  let(:meeting) { create(:meeting) }

  before(:each) do
    assign(:meeting, meeting)
    assign(:users, [meeting.user])
  end

  it 'renders the edit meeting form' do
    render

    assert_select 'form[action=?][method=?]', meeting_path(meeting), 'post' do
      assert_select 'input[name=?]', 'meeting[name]'

      assert_select 'input[name=?]', 'meeting[user_id]'
    end
  end
end
