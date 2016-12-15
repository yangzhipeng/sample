class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update]
  before_action :correct_user, only: [:edit, :update]

  def index
    @users = User.paginate(page: params[:page])
  end

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
  end

  def update
    if @user.update_attributes(user_params)
      # 处理更新成功的情况
      flash[:success] = "Update successful!"
      redirect_to user_path(@user)
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

    #前置过滤器

    #确保用户已登录
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    #确保是正确的用户
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

end
