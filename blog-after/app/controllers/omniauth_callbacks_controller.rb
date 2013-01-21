class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      authentication.update_attributes(:token => omniauth[:credentials][:token])
      flash[:notice] = "Authentication successful."
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
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = "Signed in successfully."
      else
        session[:omniauth] = omniauth.except('extra')
      end
    end

    if user.persisted?
      flash.notice = "Signed in!"
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      logger.debug('new user reg')
      redirect_to new_user_registration_url
    end
  end
  alias_method :twitter, :all
  alias_method :singly, :all
end
