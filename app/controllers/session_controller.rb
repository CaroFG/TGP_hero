class SessionController < ApplicationController

	def new
	end

  def index
  end

def create
  # cherche s'il existe un utilisateur en base avec l’e-mail
  user = User.find_by(email: params[:email])
   
 
  # on vérifie si l'utilisateur existe bien ET si on arrive à l'authentifier (méthode bcrypt) avec le mot de passe 
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    remember user
   
    # redirige où tu veux, avec un flash ou pas
    redirect_to root_path
  else
    flash.now[:danger] = 'Invalid email/password combination'
    render 'new'
  end
end

  def destroy
    log_out if logged_in?
    redirect_to new_session_path
  end

end
