require 'rubygems/command_manager'
require 'rubygems/commands/push_command'

#
# Patch the PushCommand to first check the whitelist.
#
# You can technically only push one gem at once, but if you pass several gems,
# we check that they are all on the whitelist.
#
class Gem::Commands::PushCommand
  # If this gets loaded twice, it will do strange things.
  if respond_to?(:unsafe_execute)
    raise "PushSafety has been loaded twice; please check for old versions."
  end

  alias unsafe_description description
  alias unsafe_initialize initialize
  alias unsafe_execute execute

  def initialize
    unsafe_initialize

    default_file = File.join(Gem.user_home, '.gem_push_safety')
    defaults.merge!(:push_safety_file => default_file)

    add_option :PushSafety, '--push-safety-file STRING',
      "whitelist file (default #{default_file})" do |value, options|
      options[:push_safety_file] = value
    end
  end

  def description
    "#{unsafe_description} (with PushSafety plugin)"
  end

  def execute
    white_list_file = options[:push_safety_file]
    unless File.exists?(white_list_file)
      raise "The whitelist file '#{white_list_file}' does not exist;"\
        " PushSafety will not allow you to push any gems."
    end

    white_list = File.read(white_list_file).split(/\s+/)
    if white_list.empty? || white_list.all?{|f| f.empty?}
      raise "The whitelist file '#{white_list_file}' is empty;"\
        " PushSafety will not allow you to push any gems."
    end

    grey_list = get_all_gem_names.map {|gem_file|
      get_gem_name_from_gem_file(gem_file)
    }
    black_list = grey_list - white_list

    unless black_list.empty?
      raise "The following gems are not on your PushSafety whitelist:"\
        "\n#{black_list.join("\n")}\nYour whitelist file is #{white_list_file}."
    end

    unsafe_execute
  end

  protected

  def get_gem_name_from_gem_file gem_file
    # compatibility issue: before ruby 2.0.0, we used Gem::Format to parse the
    # gem file to find its name, but Gem::Format has gone away, and the
    # functionality we need has moved to Gem::Package. Gem::Package was a
    # module in 1.9.3 and 1.8.7, so it did not respond to new, but in 2.0.0 it
    # does, so we test that
    require 'rubygems/package'
    if Gem::Package.respond_to?(:new)
      Gem::Package.new(gem_file).spec.name
    else
      require 'rubygems/format'
      Gem::Format.from_file_by_path(gem_file).spec.name
    end
  end
end

