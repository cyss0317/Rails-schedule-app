# frozen_string_literal: true

module TimeHelper
  def idx_to_time(idx)
    if idx < 12
      idx
    elsif idx > 12
      idx - 12
    else
      12
    end
  end
end
