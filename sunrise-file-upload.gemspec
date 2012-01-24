# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sunrise/file_upload/version"

Gem::Specification.new do |s|
  s.name = "sunrise-file-upload"
  s.version = Sunrise::FileUpload::VERSION.dup
  s.platform = Gem::Platform::RUBY 
  s.summary = "Rails HTML5 FileUpload helpers"
  s.description = "Sunrise is a Aimbulance CMS"
  s.authors = ["Igor Galeta", "Pavlo Galeta"]
  s.email = "galeta.igor@gmail.com"
  s.rubyforge_project = "sunrise-core"
  s.homepage = "https://github.com/galetahub/sunrise-file-upload"
  
  s.files = Dir["{app,lib,config,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["{spec}/**/*"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.require_paths = ["lib"]
end
