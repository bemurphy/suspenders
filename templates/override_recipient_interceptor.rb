# == Sending Email with Override Recipient Interceptor
#
# Use the OverrideRecipientInterceptor when you don't want your app to
# accidentally send emails to addresses other than the overridden recipient
# which you configure.
#
# An typical use case is in your app's staging environment, your development
# team will receive all staging emails without accidentally emailing users with
# active email addresses in the database.
#
#   heroku config:add EMAIL_RECIPIENTS="staging@example.com" --remote staging
#
require 'mail'

class OverrideRecipientInterceptor
  def delivering_email(message)
    add_custom_headers(message)
    message.to = ENV['EMAIL_RECIPIENTS'].split(',')
    message.cc = nil
    message.bcc = nil
  end

  private

  def add_custom_headers(message)
    {
      'X-Override-To' => message.to,
      'X-Override-Cc' => message.cc,
      'X-Override-Bcc' => message.bcc
    }.each do |header, addresses|
      if addresses
        addresses.each do |address|
          message.header = "#{message.header}\n#{header}: #{address}"
        end
      end
    end
  end
end

if Rails.env.staging?
  Mail.register_interceptor(OverrideRecipientInterceptor.new)
end
