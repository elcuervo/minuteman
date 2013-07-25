Gem::Specification.new do |s|
  s.name              = "minuteman"
  s.version           = "1.0.2"
  s.summary           = "Bit Analytics"
  s.description       = "Fast and furious tracking system using Redis bitwise operations"
  s.authors           = ["elcuervo"]
  s.licenses          = ["MIT", "HUGWARE"]
  s.email             = ["yo@brunoaguirre.com"]
  s.homepage          = "http://github.com/elcuervo/minuteman"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files test`.split("\n")

  s.add_dependency("redis", "~> 3.0.3")

  s.add_development_dependency("minitest",        "~> 4.3.0")
  s.add_development_dependency("minitest-given",  "~> 3.0.0")
  s.add_development_dependency("redis-namespace", "~> 1.2.1")
end
