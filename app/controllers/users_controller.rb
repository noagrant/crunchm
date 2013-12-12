class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)
    if @user.save
      sign_in @user
      redirect_to new_comparison_path @user
      #redirect_to :back
    else
      redirect_to :back, flash: { state: 'register', errors: @user.errors.full_messages } 
    end
  end

  def show
  	@user = user.find(params[:id])
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to root_path
  end  

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :comparisons_attributes)
  end

end
