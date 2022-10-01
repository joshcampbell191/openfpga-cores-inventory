# frozen_string_literal: true

require "json"
require "yaml"
require "net/http"
require "uri"
require "open-uri"

def unzip(file_name)
  cmd = "uzip #{file_name}"
  system(cmd)
end

class ConfigGenerator
  BIT_MASK = {
    user_reloadable:    0b000000001,
    core_specific:      0b000000010,
    nonvolatile:        0b000000100,
    read_only:          0b000001000,
    instance_json:      0b000010000,
    init_on_load:       0b000100000,
    reset_while_load:   0b001000000,
    reset_around_load:  0b010000000,
    full_reload:        0b100000000
  }.freeze

  CORE_FILE = "core.json".freeze
  DATA_FILE = "data.json".freeze

  attr_reader :url, :author, :repo

  def initialize(url)
    uri        = URI.parse(url)
    path_parts = uri.path.split("/")
    @url       = url
    @author    = path_parts[1]
    @repo      = path_parts[2]
  end

  def call
    download_repo
    build_config
  end

  private

  def download_repo
    download_url = fetch_download_url
    file_name    = URI.parse(download_url).path.split("/").last
    open(file_name, "wb") do |file|
      file << URI.open(download_url).read
    end
    # unzip(file_name)
    # File.delete(file_name)
  end

  def fetch_download_url
    api_uri  = URI.parse("https://api.github.com/repos/#{author}/#{repo}/releases/latest")
    response = Net::HTTP.get_response(api_uri)
    # There can probably be multiple assets here.
    JSON.parse(response.body).dig("assets", 0, "browser_download_url")
  end

  def build_config
    core_json     = parse_json_file(directory, CORE_FILE)
    author_name   = core_json.dig("core", "metadata", "author")
    core_name     = core_json.dig("core", "metadata", "shortname")
    # There can probably be multiple platform_ids
    platform_id   = core_json.dig("core", "metadata", "platform_ids").first
    platform_json = parse_json_file(directory, "#{platform_id}.json")

    {
      username: author,
      cores: [{
        "repository"   => repo,
        "display_name" => "TODO",
        "identifier"   => "#{author_name}.#{core_name}",
        "platform"     => platform_json.dig("platform", "name"),
        "assets"       => build_asset_json(platform_id)
      }]
    }#.to_yaml
  end

  def build_asset_json(platform)
    json = parse_json_file(directory, DATA_FILE)
    json.dig("data", "data_slots").select { |slot| slot["required"] }.map do |slot|
      { "platform" => platform }.tap do |hash|
        hash["extensions"] = slot["extensions"] if slot["extensions"]
        hash["filename"]   = slot["filename"]   if slot["filename"]
      end.merge(extract_parameters(slot["parameters"]))
    end
  end

  def parse_json_file(directory, file)
    path = Dir["#{directory}/**/#{file}"].first
    file = File.read(path)
    JSON.parse(file)
  end

  def extract_parameters(int)
    # TODO: Account for hex strings
    { core_specific: (int & BIT_MASK[:core_specific] != 0) }
  end
end

url = "https://github.com/spiritualized1997/openFPGA-GBA"
g = ConfigGenerator.new(url)
g.call

# [
#   {
#     "username": "spiritualized1997",
#     "cores": [
#       {
#         "repository": "openFPGA-GBA",
#         "display_name": "Spiritualized GBA",
#         "identifier": "Spiritualized.GBA",
#         "platform": "Game Boy Advance",
#         "assets": [
#           {
#             "platform": "gba",
#             "extensions": [
#               "gba",
#               "rom"
#             ]
#           },
#           {
#             "platform": "gba",
#             "filename": "gba_bios.bin",
#             "extensions": [
#               "bin"
#             ]
#           }
#         ]
#       }
#     ]
#   }
# ]
