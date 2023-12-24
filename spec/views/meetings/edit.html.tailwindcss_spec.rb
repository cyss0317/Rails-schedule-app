# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'meetings/edit', type: :view do
  let(:meeting) do
    Meeting.create!(
      name: 'MyString',
      user_id: 1
    )
  end

  before(:each) do
    assign(:meeting, meeting)
  end

  it 'renders the edit meeting form' do
    render

    assert_select 'form[action=?][method=?]', meeting_path(meeting), 'post' do
      assert_select 'input[name=?]', 'meeting[name]'

      assert_select 'input[name=?]', 'meeting[user_id]'
    end
  end
end
