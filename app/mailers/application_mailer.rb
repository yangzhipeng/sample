class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@example.com' #设置默认的发件人地址
  layout 'mailer'
end
