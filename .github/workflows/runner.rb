# frozen_string_literal: true

# This is the entrypoint for GitHub Actions

require_relative "yaml_generator"

token = ARGV[0]
YAMLGenerator.new(token: token).call
