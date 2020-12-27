class AdminController < ActionController::Base
  # This is a temporary solution to password-protecting the admin section.
  http_basic_authenticate_with name: "tvchat", password: "za!4aOFQ$WZe43CUPGho", unless: -> { Rails.env.development? }
  layout 'admin'
end
