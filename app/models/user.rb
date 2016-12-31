class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy #主动关系实现关注
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy #被动关系实现
  has_many :following, through: :active_relationships, source: :followed #使用source参数指定following数组由followed_id组成
  has_many :followers, through: :passive_relationships, source: :follower #这里可省略followers关联中的source参数
  attr_accessor :remember_token, :activation_token, :reset_token #创建一个可访问的属性
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum:50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive:false }

  has_secure_password
  validates :password, presence: true, length: { minimum:6 }, allow_nil: true


  #返回指定字符串的哈希摘要
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  #返回一个随机令牌
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token  #使用self的目的是确保把值赋给用户的remember_token属性
    update_attribute(:remember_digest, User.digest(remember_token)) #更新记忆摘要
  end

  #如果指定的令牌和摘要匹配，返回true
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  #忘记用户
  def forget
    update_attribute(:remember_digest, nil)
  end

  #激活账户
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  #发送激活邮件
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  #设置密码重设相关的属性
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  #发送密码重设相关的属性
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  #如果密码重设请求超时了，返回true
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  #  返回用户的动态流
  def feed
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id) #使用插值的方式，不能使用转义的方式
  end

  #关注另一个用户
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  #取消关注另一个用户
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  #如果当前用户关注了指定的用户，返回true
  def following?(other_user)
    following.include?(other_user)
  end

  private

  #把电子邮件地址转换成小写
  def downcase_email
    self.email = email.downcase
  end

  #创建并赋值激活令牌和摘要
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
  
end