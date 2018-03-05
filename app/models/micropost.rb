class Micropost < ApplicationRecord
  belongs_to :user
  validates :content, presence: true, length: {maximum: 140}
  validates_presence_of :user_id
  default_scope ->{order created_at: :desc}
end
