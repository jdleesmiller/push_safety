# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'push_safety/version'
 
Gem::Specification.new do |s|
  s.name              = 'push_safety'
  s.version           = PushSafety::VERSION
  s.platform          = Gem::Platform::RUBY
  s.authors           = ['John Lees-Miller']
  s.email             = ['jdleesmiller@gmail.com']
  s.homepage          = 'http://github.com/jdleesmiller'
  s.summary           = <<SUMMARY
Avoid accidentally pushing a private gem to rubygems.org (reduce paranoia).
SUMMARY
  s.description       = <<DESCRIPTION
The gem push command makes it incredibly easy to publish your gems... maybe a
little too easy. PushSafety is a RubyGems plugin that refuses to push a gem
unless it is on a whitelist. Add your open source gems to the whitelist, and 
keep your private gems safe from accidental pushes.
DESCRIPTION

  #s.rubyforge_project = 'push_safety'

  #s.add_runtime_dependency '...'
  s.add_development_dependency 'gemma', '>= 1.0.0', '~> 1.0'

  s.files       = Dir.glob('{lib,bin}/**/*.rb') + %w(README.rdoc)
  s.executables = Dir.glob('bin/*').map{|f| File.basename(f)}

  s.rdoc_options = [
    "--main",    "README.rdoc",
    "--title",   "#{s.full_name} Documentation"]
  s.extra_rdoc_files << "README.rdoc"
end

