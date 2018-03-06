class Micropost < ApplicationRecord
  belongs_to :user
  validates :content, presence: true, length: {maximum: 140}
  validates_presence_of :user_id
  default_scope ->{order created_at: :desc}
  mount_uploader :picture, PictureUploader
  validate :picture_size

  private

  # Validate the size of an uploaded picture
  def picture_size
    return unless picture.size > 5.megabytes
    errors.add(:picture, "should be less than 5MB")
  end
end
