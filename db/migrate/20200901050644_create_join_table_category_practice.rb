# frozen_string_literal: true

class CreateJoinTableCategoryPractice < ActiveRecord::Migration[6.0]
  def change
    create_join_table :categories, :practices do |t|
      t.index [:category_id, :practice_id]
      t.index [:practice_id, :category_id]
    end
  end
end
