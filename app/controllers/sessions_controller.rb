class SessionsController < ApplicationController  
def new
end  
#login
def create
	user = User.find_by(email: params[:user][:email])
	if user == false || user.nil?
		redirect_to new_user_path, notice: 'Sorry, no match found for this email address'
	else
		user = user.try(:authenticate, params[:user][:password])
    if user == false || user.nil?
      redirect_to :back, notice: 'Yikes... wrong combination of user email and password. Please retry.'
    else
    sign_in user
	  redirect_to root_path user
	  end
  end
end

  #logout
  def destroy
  	sign_out
  	redirect_to root_path
  end

end
