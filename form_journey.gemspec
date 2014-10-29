$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "form_journey/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "form_journey"
  s.version     = FormJourney::VERSION
  s.authors     = ["Driftrock"]
  s.email       = ["dev@driftrock.com"]
  s.homepage    = "http://www.driftrock.com"
  s.summary     = "Rails form journey"
  s.description = "Create multi page form using Rails"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.6"

  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "pry"
end
