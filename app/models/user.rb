class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  attr_accessor :remember_token, :activation_token, :password_reset_token
  has_many :microposts, dependent: :destroy
  validates :email, presence: true, length: {maximum: 200},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false}
  validates :name,  presence: true, length: {maximum: 50}
  has_secure_password
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true
  before_create :create_activation_digest
  before_save ->{email.downcase!}

  # Store token in db to remember user persistent session
  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  # Forget a user by set remember token in db to nil
  # Use this when user logout
  def forget
    update_attribute :remember_digest, nil
  end

  # Check if the given token matches the digested token stored in database
  def authenticated? token_type, token
    token_digest = send "#{token_type}_digest"
    return false if token_digest.nil?
    BCrypt::Password.new(token_digest).is_password? token
  end

  # Activate user account
  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  # Create token use to verify user when user requests to reset password
  def forgot_password
    self.password_reset_token = User.new_token
    update_columns password_reset_digest:  User.digest(password_reset_token),
                   password_reset_sent_at: Time.zone.now
  end

  # Check if the password reset token is expired or not
  def password_reset_expired?
    password_reset_sent_at < 1.hour.ago
  end

  # Send activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Defines a proto-feed.
  def feed
    Micropost.where("user_id = ?", id)
  end

  private

  # Generate activation token before create a new user
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest activation_token
  end

  class << self
    # Return the hash digest of the given string
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost: cost)
    end

    # Return a random token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end
end
