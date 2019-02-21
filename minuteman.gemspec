Gem::Specification.new do |s|
  s.name              = "minuteman"
  s.version           = "3.0.0"
  s.summary           = "Bit Analytics"
  s.description       = "Fast and furious tracking system using Redis bitwise operations"
  s.authors           = ["elcuervo"]
  s.licenses          = ["MIT", "HUGWARE"]
  s.email             = ["yo@brunoaguirre.com"]
  s.homepage          = "http://github.com/elcuervo/minuteman"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files test`.split("\n")

  s.add_dependency("redic", "~> 1.5.1")
  s.add_dependency("nest",  "~> 3.1.2")
  s.add_dependency("ohm",   "~> 3.1.1")

  s.add_development_dependency("cutest", "~> 1.2.3")
end
