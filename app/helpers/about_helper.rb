module AboutHelper
  def ssl_instructions_path
    about_ssl_path(:show_instructions => 1) + "#instructions"
  end

  def ssl_instructions_image(filename)
    image_tag "cacert-instructions/#{filename}.png",
      :class => "cacert-instructions"
  end
end
