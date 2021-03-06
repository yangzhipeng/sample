require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@user = User.new(name: "Example user", email: "user@example.com", password: "123abc", password_confirmation: "123abc")
  end

  test "should be valid" do
  	assert @user.valid?
  end

  test "name should be present" do
  	@user.name = " "
  	assert_not @user.valid?
  end

  test "email should be present" do
  	@user.email = "  "
  	assert_not @user.valid?
  end

  test "name should not be too long" do
  	@user.name = "a" * 51
  	assert_not @user.valid?
  end

  test "email should not be too long" do
  	@user.email = "b" * 244 + "@example.com"
  	assert_not @user.valid?
  end

  test "email validation should accept valid address" do
  	valid_addresses = %w[user@hotmail.com user@qq.com user@gmail.com 
  		user@sina.cn user@163.com]
  	valid_addresses.each do |valid_address|
  		@user.email = valid_address
  		assert @user.valid?,"#{valid_address.inspect} should be valid"
  	end
  end
  test "email validation should reject invalid address" do
  	invalid_addresses = %w[user@hotmail,com userqq.com user.a@ha
  		user@s_ina.cn user@ne+aat.com]
  	invalid_addresses.each do |invalid_address|
  		@user.email = invalid_address
  		assert_not @user.valid?,"#{invalid_address.inspect} should be invalid"
  	end
  end

  test "email addresses should be unique" do
  	duplicate_user = @user.dup
  	duplicate_user.email = @user.email.upcase
  	@user.save
  	assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
  	mixed_case_email = "UsEr@ExamPlE.CoM"
  	@user.email = mixed_case_email
  	@user.save
  	assert_equal mixed_case_email.downcase, @user.reload.email #使用 reload 方法从数据库中重新加载数据
  end

  test "password should be present (nonblank)" do
  	@user.password = @user.password_confirmation = " " * 6
  	assert_not @user.valid?
  end

  test "password should hace a minimum length" do
  	@user.password = @user.password_confirmation = "a" * 5
  	assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content:"Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    haloyoung = users(:haloyoung)
    joanna = users(:joanna)
    assert_not haloyoung.following?(joanna)
    haloyoung.follow(joanna)
    assert haloyoung.following?(joanna)
    assert joanna.followers.include?(haloyoung)
    haloyoung.unfollow(joanna)
    assert_not haloyoung.following?(joanna)
  end

  test "feed should have the right posts" do
    haloyoung = users(:haloyoung)
    joanna = users(:joanna)
    user_1 = users(:user_1)
    #关注的用户发布的微博
    joanna.microposts.each do |post_following|
      assert haloyoung.feed.include?(post_following)
    end
    #自己的微博
    haloyoung.microposts.each do |post_self|
      assert haloyoung.feed.include?(post_self)
    end
    #未关注用户的微博
    user_1.microposts.each do |post_unfollowed|
      assert_not haloyoung.feed.include?(post_unfollowed)
    end
  end

end
