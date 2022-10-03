# This is the entrypoint for GitHub Actions

require_relative "./yaml_generator.rb"

YAMLGenerator.new.call
