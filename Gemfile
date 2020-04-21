source 'https://rubygems.org'
ruby '2.6.6'

# https://stackoverflow.com/questions/41454333/meaning-of-new-block-git-sourcegithub-in-gemfile
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "webpacker"
gem "react-rails"
gem "pry-rails"
gem "rails", "5.2.3"
gem "pg", "~> 0.18"
gem "puma", "~> 3.7"
gem "mutations"
gem "octokit", "~> 4.0"
gem "restpack_serializer", "~> 0.6"
gem "warden-github-rails", "~> 1.1.0"
gem "rack", "~> 2.2.2"
gem "rack-cors", :require => "rack/cors"
gem "sprockets"
gem "slack-ruby-client"
gem "retries"
gem "whenever", require: false
gem "listen", ">= 3.0.5", "< 3.2"
gem "graphql-client"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rspec-rails", "~> 3.7"
  gem "factory_bot_rails"
end

group :development do
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "foreman"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
