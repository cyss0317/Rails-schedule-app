# frozen_string_literal: true

module MeetingsHelper
  def convert_time(time)
    time.instance_of?(String) ? DateTime.parse(time) : time
  end
end
