class User < ApplicationRecord
	attr_accessor :remember_token
	has_secure_password
	belongs_to :city
	has_many :gossips
	has_many :comments
	has_many :sent_messages, foreign_key: "sender_id", class_name: 'PrivateMessage'
	has_many :received_messages, foreign_key: "recipient_id", class_name: 'PrivateMessage'
	has_many :likes, dependent: :destroy
	validates :password, presence: true, length: { minimum: 6 }
	validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, message: "email adress please" }

	
def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  #the User model already has a remember_digest attribute, 
  #but it doesn’t yet have a remember_token attribute. 
  #We need a way to make a token available via user.remember_token (for storage in the cookies)
  # without storing it in the database. We use attr_accessor to create an accessible attribute,

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  #make a user.remember method that associates a remember token with the user 
  #and saves the corresponding remember digest to the database
  # Remembers a user in the database for use in persistent sessions.
  def remember
  	#without self the assignment would create a local variable called remember_token, 
  	#Using self ensures that assignment sets the user’s remember_token attribute.
    self.remember_token = User.new_token
    #the update_attribute method updates the remember digest.
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  #we can create a valid token and associated digest by first making a new remember 
  #token using User.new_token, and then updating the remember digest with the result 
  #of applying User.digest. This procedure gives the remember method shown
  #Having created a working user.remember method, we’re now in a position to create a persistent session 
  #by storing a user’s (encrypted) id and remember token as permanent cookies on the browser. 
  #The way to do this is with the cookies method.

   # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
  	return false if remember_digest.nil?
  	#The final piece of the puzzle is to verify that a given remember token matches the user’s remember digest
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

end
