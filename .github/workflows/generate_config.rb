# frozen_string_literal: true

require "json"
require "yaml"
require "net/http"
require "uri"
require "open-uri"

BIT_MASK = {
  user_reloadable:    0b000000001,
  core_specific:      0b000000010,
  nonvolatile:        0b000000100,
  read_only:          0b000001000,
  instance_json:      0b000010000,
  init_on_load:       0b000100000,
  reset_while_loaD:   0b001000000,
  reset_around_loAD:  0b010000000,
  full_reload:        0b100000000
}.freeze

CORE_FILE = "core.json".freeze
DATA_FILE = "data.json".freeze

def download_repo(url)
  repo_uri        = URI.parse(url)
  api_uri         = URI.parse("https://api.github.com/repos#{repo_uri.path}/releases/latest")
  response        = Net::HTTP.get_response(api_uri)
  # There can probably be multiple assets here.
  zip_browser_url = JSON.parse(response.body).dig("assets", 0, "browser_download_url")
  zip_uri         = URI.parse(zip_browser_url)
  file_name       = zip_uri.path.split("/").last
  open(file_name, "wb") do |file|
    file << URI.open(zip_browser_url).read
  end
  unzip(file_name)
  # File.delete(file_name)
end

def unzip(file_name)
  cmd = "unar #{file_name}"
  system(cmd)
end

def generate_config(directory)
  core_json = parse_json(directory, CORE_FILE)
  data_json = parse_json(directory, DATA_FILE)

  author_name = core_json.dig("core", "metadata", "author")
  core_name   = core_json.dig("core", "metadata", "shortname")
  platform_id = core_json.dig("core", "metadata", "platform_ids").first

  platform_file = "#{platform_id}.json"
  platform_json = parse_json(directory, platform_file)

  {
    username: "TODO",
    cores: [
      {
        repository: "TODO",
        display_name: "TODO",
        identifier: "#{author_name}.#{core_name}",
        platform: platform_json.dig("platform", "name"),
        assets: generate_assets(data_json, platform_id)
      }
    ]
  }.to_yaml
end

def generate_assets(json, platform)
  json.dig("data", "data_slots").select { |slot| slot["required"] }.map do |slot|
    { "platform" => platform }.tap do |hash|
      hash["extensions"] = slot["extensions"] if slot["extensions"]
      hash["filename"]   = slot["filename"]   if slot["filename"]
    end.merge(apply_mask(slot["parameters"]))
  end
end

def parse_json(directory, file)
  path = Dir["#{directory}/**/#{file}"].first
  file = File.read(path)
  JSON.parse(file)
end

def apply_mask(int)
  { core_specific: (int & BIT_MASK[:core_specific] != 0) }
end

url = ARGV[0]
pp download_repo(url)
