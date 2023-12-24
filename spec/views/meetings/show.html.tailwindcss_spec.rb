# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'meetings/show', type: :view do
  before(:each) do
    assign(:meeting, Meeting.create!(
                       name: 'Name',
                       user_id: 2
                     ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2/)
  end
end
