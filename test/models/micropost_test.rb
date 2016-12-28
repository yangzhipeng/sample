require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@user = users(:haloyoung)
  	#这行代码不符合常见做法
  	@micropost = @user.microposts.build(content: "Lorem ipsum") #build 方法返回一个存储在内存中的对象，不会修改数据库
  end

  test "should be valid" do
  	assert @micropost.valid?
  end

  test "user id should be present" do
  	@micropost.user_id = nil
  	assert_not @micropost.valid?
  end

  test "content should be present" do
  	@micropost.content = " "
  	assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
  	@micropost.content = "a" * 141
  	assert_not @micropost.valid?
  end

  test "order should be most recent first" do
  	assert_equal microposts(:most_recent), Micropost.first
  end

end
