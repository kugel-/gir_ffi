source "https://rubygems.org"

# The gem's dependencies are specified in gir_ffi.gemspec
gemspec

if ENV["CI"]
  gem 'coveralls', require: false, type: :development, platform: :mri
else
  gem 'simplecov', '~> 0.8.2', require: false, type: :development, platform: :mri
  gem 'pry', '~> 0.10.0', type: :development
  gem 'repl_rake', '0.0.3', type: :development
  gem 'yard', '~> 0.8.7', type: :development
end

gem 'rubysl', :platform => :rbx
