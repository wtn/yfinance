require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = FileList["test/**/*_test.rb"]
end

task :default => :test

# Default directory to look in is `/specs`
# Run with `rake spec`
# RSpec::Core::RakeTask.new(:spec) do |task|
#   task.rspec_opts = ['--color', '--format', 'nested']
#   end
#
# task :default => :spec

