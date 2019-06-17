class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :tweets

  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, if: -> { new_record? || changes[:crypted_password] }
end
