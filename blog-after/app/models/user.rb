class User < ActiveRecord::Base
  has_many :authentications

  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :authentications
  
  validates_presence_of :username
  validates_uniqueness_of :username

  def apply_omniauth(omniauth)
    logger.debug('apply omniauth')
    self.email = omniauth['info']['email'] if email.blank?
    authentications.build(
      :provider => omniauth['provider'], 
      :uid => omniauth['uid'],
      :token => omniauth['credentials']['token'])
  end
  
  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end
  
  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end
end
