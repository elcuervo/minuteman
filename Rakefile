require "rake/testtask"

Rake::TestTask.new("spec") do |t|
  t.pattern = "test/**/*_test.rb"
end

Rake::TestTask.new("bench") do |t|
  t.pattern = "test/bench/*_bench.rb"
end

task :default => [:test]
task :all     => [:test, :bench]
task :test    => [:spec]
