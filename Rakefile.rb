begin
  require 'rubygems'
  require 'bundler/setup'
  require 'gemma'

  Gemma::RakeTasks.with_gemspec_file 'push_safety.gemspec'
rescue LoadError
  puts 'Install gemma (sudo gem install gemma) for more rake tasks.'
end

require 'push_safety'

# Writing unit tests for rubygems plugins appears to be hard.
# Install the gem and make sure we show up in the output.
# Also tests some error conditions; these won't work on windows, at present.
desc "test local install"
task :test do 
  gem_name = "push_safety-#{PushSafety::VERSION}.gem"
  system "gem build push_safety.gemspec"
  system "gem install #{gem_name}"
  raise "installation failed" unless $?.exitstatus == 0

  Bundler.with_clean_env do
    output = `gem help push`
    raise "plugin failed" unless output =~ /PushSafety/
    raise "missing option" unless output =~ /--push-safety-file/

    test_path = File.expand_path(File.join(File.dirname(__FILE__), 'test'))
    missing_path = File.join(test_path, 'i_do_not_exist.txt')
    output = `gem push #{gem_name} --push-safety-file=#{missing_path} 2>&1`
    raise "did not detect missing file" if $?.exitstatus == 0 ||
      output !~ /PushSafety/ || output !~ /does not exist/

    blank_path = File.join(test_path, 'blank.txt')
    output = `gem push #{gem_name} --push-safety-file=#{blank_path} 2>&1`
    raise "did not detect empty file" if $?.exitstatus == 0 ||
      output !~ /PushSafety/ || output !~ /is empty/

    foo_path = File.join(test_path, 'foo.txt')
    output = `gem push #{gem_name} --push-safety-file=#{foo_path} 2>&1`
    raise "pushed gem that isn't on whitelist" if $?.exitstatus == 0 ||
      output !~ /are not on your PushSafety whitelist/

    puts "PASS"
  end
end

task :default => :test
