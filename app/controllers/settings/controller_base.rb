class Settings::ControllerBase < ApplicationController
  login_required
  force_ssl
end
