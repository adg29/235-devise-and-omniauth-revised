class Authentication < ActiveRecord::Base
  belongs_to :user
  attr_accessible :provider, :uid, :token, :user

  def self.from_omniauth(omniauth,current_user=nil)
    
    logger.debug('omniauth')
    logger.debug(omniauth.inspect)
    logger.debug(':provider') 
    logger.debug(omniauth['provider'])
    logger.debug(':uid')
    logger.debug(omniauth['uid'])
    logger.debug(':token')
    logger.debug(omniauth[:credentials][:token])

    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      authentication.update_attributes(:token => omniauth[:credentials][:token])

      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      current_user.authentications.create!(
        :provider => omniauth['provider'], 
        :uid => omniauth['uid'],
        :token => omniauth[:credentials][:token]
        )
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
    else
      user = User.new
      # apply omniauth
      user.email = omniauth['info']['email'] if email.blank?
      authentications.build(
        :provider => omniauth['provider'], 
        :uid => omniauth['uid'],
        :token => omniauth['credentials']['token'])
      user.save
    end
  end
  
  def provider_name
    if provider == 'open_id'
      "OpenID"
    else
      provider.titleize
    end
  end
end
