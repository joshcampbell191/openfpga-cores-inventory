# frozen_string_literal: true

require "yaml"
require_relative "core_data_generator"

class YAMLGenerator
  COMMENT = <<~TXT
    # ##############################################################################
    # #                                                                            #
    # #                        THIS FILE IS AUTO-GENERATED                         #
    # #                           DO NOT EDIT THIS FILE                            #
    # #                   ADD NEW CORE REPOSITORIES TO REPOS.YML                   #
    # #                                                                            #
    # ##############################################################################
  TXT
  INPUT_FILE  = "_data/repos.yml"
  OUTPUT_FILE = "_data/cores.yml"

  attr_reader :output_data

  def initialize
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
    @input_data.each do |entry|
      cores = entry["cores"].each.with_object([]) do |core, arr|
        arr << GitHub::CoreDataGenerator.new(
          entry["username"],
          core["repository"],
          core["display_name"]
        ).call
      end

      output_data << { "username" => entry["username"], "cores" => cores }
    end
  end

  def write_file
    File.open(OUTPUT_FILE, "wb") do |f|
      f << COMMENT
      f << output_data.to_yaml
    end
  end
end
