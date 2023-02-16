class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar
  default_scope { where(deleted_at: nil) }
  acts_as_paranoid

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :password,
            length: { minimum: 8 },
            if: -> { new_record? || !password.nil? }

  scope :active, -> { where(deleted_at: nil) }        
  scope :created_within, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  before_validation :generate_username, on: :create

  def generate_username
    self.username ||= UsernameGeneratorService.generate_username
  end

  def avatar_url
    if avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(avatar)
    else
      return nil
    end
  end

  def process_avatar
    return unless avatar.attached?

    # Resize the image to a maximum width of 300 pixels
    avatar.variant(resize_to_limit: [300, 300])

    # Compress the image to a maximum quality of 60%
    avatar.variant(quality: 60)

    # Convert the image to the JPEG format
    avatar.variant(convert: 'jpg')

    # Save the changes to the avatar image
    avatar.save
  end
  
  def restore
    update_attribute(:deleted_at, nil)
  end

  def settings
    Rails.cache.fetch([self, 'settings']) do
      # Retrieve the user-specific settings from the database
      user_settings = UserSettings.find_by(user_id: self.id)
  
      # If the user-specific settings do not exist, create them
      user_settings ||= UserSettings.create(user_id: self.id)
  
      # Return the user-specific settings
      user_settings
    end
  end

  private

  def generate_unique_username
    return if username.blank?

    # Check if the username is already taken
    if User.exists?(username: username)
      # Generate a random string and append it to the username
      random_string = SecureRandom.hex(4)
      self.username = "#{username}_#{random_string}"
    end
  end
end