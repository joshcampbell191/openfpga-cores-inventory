# This is the entrypoint for GitHub Actions

require_relative "./yaml_generator.rb"

token = ARGV[0]
YAMLGenerator.new(token: token).call
