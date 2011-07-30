class About::SslController < ApplicationController
  def index
    @show_instructions = params[:show_instructions].present?
  end

  def more
  end

  def why
  end

  def accept
    set_ssl_accepted
    redirect_to_original_uri
  end
end
