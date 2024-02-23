# frozen_string_literal: true

module SimpleCalendar
  class Calendar
    def year
      date_range[(date_range.length / 2).to_i].year
    end
  end

  class WeekCalendar
    def current_month_in_string
      Date::MONTHNAMES[date_range[3].month]
    end

    def render_shifts_by_hour(shifts)
      hours = (8..24).to_a

      shifts.count
    end
  end

  class MonthCalendar
    def current_month_in_string
      Date::MONTHNAMES[(url_for_next_view.split('=')[1].to_time.-1.month).month]
    end
  end
end

SimpleCalendar.extend SimpleCalendar
