# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'meetings/new', type: :view do
  before(:each) do
    assign(:meeting, Meeting.new(
                       name: 'MyString',
                       user_id: 1
                     ))
  end

  it 'renders new meeting form' do
    render

    assert_select 'form[action=?][method=?]', meetings_path, 'post' do
      assert_select 'input[name=?]', 'meeting[name]'

      assert_select 'input[name=?]', 'meeting[user_id]'
    end
  end
end
