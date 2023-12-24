# frozen_string_literal: true

class AddIndicesToMeetings < ActiveRecord::Migration[7.1]
  def change
    add_index :meetings, :time
    add_index :meetings, :start_date
    add_index :meetings, :start_time
  end
end
