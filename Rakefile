require "rake/testtask"

Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

Rake::TestTask.new("bench") do |t|
  t.pattern = "test/bench/*_bench.rb"
end

task :default => [:test]
task :all     => [:test, :bench]
