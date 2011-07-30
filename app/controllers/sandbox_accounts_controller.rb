class SandboxAccountsController < ApplicationController
  force_ssl

  def new
    @user = User.new_for_sandbox(:locale => I18n.locale.to_s,
                                 :timezone => "UTC")
    @user.create_with_new_account! do |account|
      account.sandbox = true
    end

    login(@user)
    redirect_to dashboard_path
  end
end
