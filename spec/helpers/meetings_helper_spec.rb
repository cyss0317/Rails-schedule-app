# frozen_string_literal: true

require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the MeetingsHelper. For example:
#
# describe MeetingsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe MeetingsHelper, type: :helper do
  describe '#convert_time' do
    it 'converts a string to a DateTime object' do
    end
  end
end
