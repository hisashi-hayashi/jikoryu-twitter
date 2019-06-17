class Tweet < ApplicationRecord
  belongs_to :user

  validates :comment, presence: true

  def my_teet?(id)
    user_id == id.to_i
  end
end
