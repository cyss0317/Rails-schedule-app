# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Day, type: :model do
  it 'creates one Day object' do
    a = create(:day)

    expect(a.user_id).to be(1)
  end
end
