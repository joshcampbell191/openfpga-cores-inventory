# frozen_string_literal: true

require "yaml"
require_relative "./data_generator"

class YAMLGenerator
  COMMENT = <<~TXT
    #################################################
    ##                                             ##
    ##         THIS FILE IS AUTO-GENERATED         ##
    ##            DO NOT EDIT THIS FILE            ##
    ##    ADD NEW CORE REPOSITORIES TO REPOS.YML   ##
    ##                                             ##
    #################################################
  TXT
  INPUT_FILE  = "../../_data/repos.yml"
  OUTPUT_FILE = "../../_data/cores.yml"

  attr_reader :data_generator, :input_data, :output_data

  def initialize(data_generator: GitHub::DataGenerator)
    @data_generator = data_generator
    @output_data = []
  end

  def call
    read_file
    generate_data
    write_file
  end

  private

  def read_file
    @input_data = YAML.load_file(INPUT_FILE)
  end

  def generate_data
    input_data.each do |entry|
      cores = []

      entry["cores"].each do |core|
        cores << data_generator.new(
          entry["username"],
          core["repository"],
          core["display_name"]
        ).call
      end

      # TODO: Not sure if this #flatten is needed
      output_data << { "username" => entry["username"], "cores" => cores.flatten }
    end
  end

  def write_file
    File.open(OUTPUT_FILE, "wb") do |f|
      f << COMMENT
      f << output_data.to_yaml
    end
  end
end

YAMLGenerator.new.call
