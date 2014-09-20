class Avatar
  IMAGE_DIRECTORY = "public/profile_images/"
  def initialize(user)
    @user = user
  end

  def image
    avatar_file = Dir.entries(IMAGE_DIRECTORY).grep(/^#{@user.handle}\..*$/).first
    return avatar_path_for(avatar_file) if avatar_file
    download_avatar_image
  end

  private
  def download_avatar_image
    image_url = Chirper.new(@user.handle).user.profile_image_url(:bigger).to_s
    extension = File.extname(image_url)
    file_path = File.join([IMAGE_DIRECTORY, @user.handle, extension])

    File.open(file_path, 'w') do |output|
      open(image_url) do |input|
        output << input.read
      end
    end
    avatar_path_for(file_path)
  end

  def avatar_path_for(image_file)
    File.join(["profile_images", image_file])
  end
end
