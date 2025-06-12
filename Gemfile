source "https://rubygems.org"

gem "rails", "~> 7.2.2", ">= 7.2.2.1"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

# user added

gem "rack-cors"
gem "bcrypt", "~> 3.1.7"
gem "jwt", "~> 2.7"
gem "active_model_serializers"
gem "kaminari"
gem "byebug"
gem "geocoder"
gem "faker"
#========================================================================================
group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", require: false

  gem "rubocop-rails-omakase", require: false
end
