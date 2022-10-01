# frozen_string_literal: true

require "json"
require "yaml"
require "net/http"
require "uri"
require "open-uri"

class ConfigGenerator
  # https://www.analogue.co/developer/docs/core-definition-files/data-json#parameters-bitmap
  BITMAP = {
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
  attr_accessor :directory

  def initialize(url)
    uri        = URI.parse(url)
    path_parts = uri.path.split("/")
    @url       = url
    @author    = path_parts[1]
    @repo      = path_parts[2]
  end

  def call
    @directory = download_repo
    build_config
  end

  private

  def download_repo
    download_url = fetch_download_url
    file_name    = URI.parse(download_url).path.split("/").last
    dir_name     = File.basename(file_name, ".zip")

    open(file_name, "wb") do |file|
      file << URI.open(download_url).read
    end
    system("unzip -q #{file_name} -d #{dir_name}")
    File.delete(file_name)

    dir_name
  end

  def fetch_download_url
    api_uri  = URI.parse("https://api.github.com/repos/#{author}/#{repo}/releases/latest")
    response = Net::HTTP.get_response(api_uri)
    # There can probably be multiple assets here.
    JSON.parse(response.body).dig("assets", 0, "browser_download_url")
  end

  def build_config
    core_json     = parse_json_file(CORE_FILE)
    author_name   = core_json.dig("core", "metadata", "author")
    core_name     = core_json.dig("core", "metadata", "shortname")
    # There can probably be multiple platform_ids
    platform_id   = core_json.dig("core", "metadata", "platform_ids").first
    platform_json = parse_json_file("#{platform_id}.json")

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
    json = parse_json_file(DATA_FILE)
    json.dig("data", "data_slots").select { |slot| slot["required"] }.map do |slot|
      { "platform" => platform }.tap do |hash|
        hash["extensions"] = slot["extensions"] if slot["extensions"]
        hash["filename"]   = slot["filename"]   if slot["filename"]
      end.merge(extract_parameters(slot["parameters"]))
    end
  end

  def parse_json_file(file)
    path = Dir["#{directory}/**/#{file}"].first
    file = File.read(path)
    JSON.parse(file)
  end

  def extract_parameters(int)
    int = int.to_i(16) if int.is_a?(String)
    { "core_specific" => (int & BITMAP[:core_specific] != 0) }
  end
end

url = "https://github.com/spiritualized1997/openFPGA-GBA"
g = ConfigGenerator.new(url)
pp g.call

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
#
# {
#   "username": "spiritualized1997",
#   "cores": [
#     {
#       "repository": "openFPGA-GBA",
#       "display_name": "TODO",
#       "identifier": "Spiritualized.GBA",
#       "platform": "Game Boy Advance",
#       "assets": [
#         {
#           "platform": "gba",
#           "extensions": [
#             "gba",
#             "rom"
#           ],
#           "core_specific": false
#         },
#         {
#           "platform": "gba",
#           "extensions": [
#             "bin"
#           ],
#           "filename": "gba_bios.bin",
#           "core_specific": false
#         }
#       ]
#     }
#   ]
# }
