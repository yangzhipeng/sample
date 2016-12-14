class User < ApplicationRecord
  attr_accessor :remember_token #创建一个可访问的属性
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum:20 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive:false }

  has_secure_password
  validates :password, presence: true, length: { minimum:6 }


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
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  #忘记用户
  def forget
    update_attribute(:remember_digest, nil)
  end
  
end
