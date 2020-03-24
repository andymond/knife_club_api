source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'

gem 'rails', '~> 5.2.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.1.0', require: false

gem 'active_model_serializers', '~> 0.10.8'
gem 'sorcery'
gem 'pundit'
gem 'bcrypt', '~> 3.1.7'
gem 'symmetric-encryption', '~> 4.1', '>= 4.1.2'
gem 'paranoia', '~> 2.4', '>= 2.4.1'
gem 'rswag'

group :development, :test do
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'pry-rails', '~> 0.3.9'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'annotate'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'timecop'
  gem 'rspec-rails'
  gem 'database_cleaner', '~> 1.7'
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.2'
  gem 'rails-controller-testing'
  gem 'simplecov'
end
