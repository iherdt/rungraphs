# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :address        => Rails.application.secrets.action_mailer["address"],
  :domain         => Rails.application.secrets.action_mailer["domain"],
  :port           => Rails.application.secrets.action_mailer["port"],
  :user_name      => Rails.application.secrets.action_mailer["user_name"],
  :password       => Rails.application.secrets.action_mailer["password"],
  :authentication => :plain,
  :enable_starttls_auto => true
}