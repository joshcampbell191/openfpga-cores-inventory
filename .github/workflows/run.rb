# frozen_string_literal: true

require "json"
require "yaml"
require_relative "./data_generator"

COMMENT = <<~TXT
  #################################################
  ##                                             ##
  ##         THIS FILE IS AUTO-GENERATED         ##
  ##            DO NOT EDIT THIS FILE            ##
  ##    ADD NEW CORE REPOSITORIES TO REPOS.YML   ##
  ##                                             ##
  #################################################

TXT

data = YAML.load_file("../../_data/repos.yml")
new_data = []

data.each do |entry|
  cores = []

  entry["cores"].each do |core|
    cores << DataGenerator.new(
      entry["username"],
      core["repository"],
      core["display_name"]
    ).call
  end
  new_data << { "username" => entry["username"], "cores" => cores.flatten }
end

File.open("../../_data/cores.yml", "wb") do |f|
  f << COMMENT
  f << new_data.to_yaml
end
