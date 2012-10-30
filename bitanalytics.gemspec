Gem::Specification.new do |s|
  s.name              = "bitanalytics"
  s.version           = "0.0.1.pre"
  s.summary           = "Bit Analytics"
  s.description       = ""
  s.authors           = ["elcuervo"]
  s.email             = ["yo@brunoaguirre.com"]
  s.homepage          = "http://github.com/elcuervo/bitanalytics"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files test`.split("\n")

  s.add_dependency("redis", "~> 3.0.2")

  s.add_development_dependency("minitest", "~> 4.1.0")
end
