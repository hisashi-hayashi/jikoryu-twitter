class Tweet < ApplicationRecord
  belongs_to :user

  belongs_to :parent, class_name: :Tweet, optional: true
  has_many :children, class_name: :Tweet, foreign_key: :parent_id, dependent: :destroy

  validates :comment, presence: true, length: { maximum: 300 }
  validate :validate_update_parent_id, if: :persisted?

  def my_teet?(id)
    user_id == id.to_i
  end

  def reply
    results = []
    children.where(display_flg: true).each do |child|
      if child.children.present?
        results << child
        results << child.reply
      else
        results << child
      end
    end
    results.flatten
  end

  def validate_update_parent_id
    if changed.include?('parent_id')
      errors.add(:parent_id, 'parent_idは更新できません。')
    end
  end
end
