#!/usr/bin/env ruby
# Setup script for Ruby Enterprise E-Commerce Platform

puts "🚀 Setting up Ruby Enterprise E-Commerce Platform..."

# Check Ruby version
required_ruby = "3.2.0"
current_ruby = RUBY_VERSION

if Gem::Version.new(current_ruby) < Gem::Version.new(required_ruby)
  puts "❌ Ruby #{required_ruby}+ required. Current version: #{current_ruby}"
  exit 1
end

puts "✅ Ruby version: #{current_ruby}"

# Check if Docker is available
if system("docker --version > /dev/null 2>&1")
  puts "✅ Docker is available"
else
  puts "⚠️  Docker not found. You'll need to install PostgreSQL, Redis, and Elasticsearch manually."
end

# Check if Docker Compose is available
if system("docker-compose --version > /dev/null 2>&1")
  puts "✅ Docker Compose is available"
else
  puts "⚠️  Docker Compose not found."
end

puts "\n📋 Next steps:"
puts "1. Run 'docker-compose up -d' to start services"
puts "2. Run 'bundle install' to install gems"
puts "3. Run 'rails db:create db:migrate' to setup database"
puts "4. Run 'rails server' to start the application"
puts "\n🎉 Setup complete! Ready for development."
