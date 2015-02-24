gem 'krikri'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

run "bundle install"

options = ENV.fetch("KRIKRI_INSTALL_OPTIONS", '')

generate 'krikri:install', options

# run the database migrations
rake "krikri:install:migrations"

# run the database migrations
rake "db:migrate"