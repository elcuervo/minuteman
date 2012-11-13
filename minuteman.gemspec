Gem::Specification.new do |s|
  s.name              = "minuteman"
  s.version           = "0.2.0.pre"
  s.summary           = "Bit Analytics"
  s.description       = "Fast and furious tracking system using Redis bitwise operations"
  s.authors           = ["elcuervo"]
  s.email             = ["yo@brunoaguirre.com"]
  s.homepage          = "http://github.com/elcuervo/minuteman"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files test`.split("\n")

  s.add_dependency("redis", "~> 3.0.2")

  s.add_development_dependency("minitest", "~> 4.1.0")
end
