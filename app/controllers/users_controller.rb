class UsersController < ApplicationController
  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
  	#debugger #把它当成 Rails 控制台，在其中执行代码，查看应用的状态
  end

  def create
  	#binding.pry
  	@user = User.new(user_params)
  	if @user.save
        #redirect_to @user
        log_in @user
        flash[:success] = "Welcome to Sample App!"
        redirect_to user_url(@user)
  	else
  		render 'new'
  	end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # 处理更新成功的情况

    else
      render 'edit'
    end
  end

  private
  
  #user_params 方法只会在 Users 控制器内部使用，不需要开放给外部用户
    def user_params
    	params.require(:user).permit(:name, :email, :password,
    	                             :password_confirmation)
    end

end
