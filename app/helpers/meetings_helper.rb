module MeetingsHelper
  def convert_time(time)
    time.class == String ? DateTime.parse(time) : time
  end
end
