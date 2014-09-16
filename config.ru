require './app'
# Replace the directory names to taste
use Rack::Static, :urls => ['/css', '/js', '/profile_images'], :root => 'public'
run Sinatra::Application