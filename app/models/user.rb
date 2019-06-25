class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :tweets, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :password, presence: true, length: { maximum: 100 }, if: -> { new_record? || changes[:crypted_password] }
end
