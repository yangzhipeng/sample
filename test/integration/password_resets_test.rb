require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
  	ActionMailer::Base.deliveries.clear
  	@user = users(:haloyoung)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    #电子邮件地址无效
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    #电子邮件地址有效
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    #密码重设表单
    user = assigns(:user) #assigns 的作用是获取相应动作中的实例变量
    #电子邮件地址错误
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    assert_not flash.empty?
    #用户未激活
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    #电子邮件地址正确，令牌不对
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    #电子邮件地址正确，令牌也对
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email #页面中有 name 属性、类型（隐藏）和电子邮件地址都正确的 input 标签
    #密码和密码确认不匹配
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:  "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
    #密码为空值
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:  "",
                    	    password_confirmaiton: "" } }
    assert_select 'div#error_explanation'
    #密码和密码确认有效
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password: "foobaz",
                    	    password_confirmaiton: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "expired token" do
  	get new_password_reset_path
  	post password_resets_path,
  	     params: { password_reset: { email: @user.email } }

  	@user = assigns(:user)
  	@user.update_attribute(:reset_sent_at, 3.hours.ago)
  	patch password_reset_path(@user.reset_token),
  	      params: { email: @user.email,
  	                user: { password: "foobar",
  	                	    password_confirmaiton: "foobar" } }
  	assert_response :redirect
  	follow_redirect!
  	assert_match /a/i, response.body
  end
end
