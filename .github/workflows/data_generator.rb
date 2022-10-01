# frozen_string_literal: true

require "json"
require "yaml"
require "net/http"
require "uri"
require "open-uri"

class DataGenerator
  # https://www.analogue.co/developer/docs/core-definition-files/data-json#parameters-bitmap
  # Uncomment a line to add the parameter to the core's API entry.
  BITMAP = {
    # "user_reloadable"   => 0b000000001,
    "core_specific"     => 0b000000010,
    # "nonvolatile"       => 0b000000100,
    # "read_only"         => 0b000001000,
    "instance_json"     => 0b000010000,
    # "init_on_load"      => 0b000100000,
    # "reset_while_load"  => 0b001000000,
    # "reset_around_load" => 0b010000000,
    # "full_reload"       => 0b100000000
  }.freeze

  CORE_FILE = "core.json".freeze
  DATA_FILE = "data.json".freeze

  attr_reader :url, :username, :repo, :json
  attr_accessor :directory

  def initialize(url)
    @url = url
    @username, @repo = URI.parse(url).path.split("/").drop(1)
    @json = {
      "username" => username,
      "cores"    => []
    }
  end

  def call
    fetch_download_urls.each do |download_url|
      @directory = download_repo(download_url)
      build_json
    end

    json
  end

  private

  def fetch_download_urls
    api_uri  = URI.parse("https://api.github.com/repos/#{username}/#{repo}/releases/latest")
    response = Net::HTTP.get_response(api_uri)
    JSON.parse(response.body)["assets"].map { |asset| asset["browser_download_url"] }
  end

  def download_repo(download_url)
    file_name = URI.parse(download_url).path.split("/").last
    dir_name  = File.basename(file_name, ".zip")

    open(file_name, "wb") do |file|
      file << URI.open(download_url).read
    end
    system("unzip -q #{file_name} -d #{dir_name}")
    File.delete(file_name)

    dir_name
  end

  def build_json
    metadata      = parse_json_file(CORE_FILE).dig("core", "metadata")
    platform_id   = metadata["platform_ids"].first # TODO: There can probably be multiple platform_ids
    platform_json = parse_json_file("#{platform_id}.json")["platform"]

    core_json = core_json_template(
      metadata["author"],
      metadata["shortname"],
      platform_json["name"],
      platform_id
    )

    json["cores"] << core_json
  end

  def core_json_template(author, shortname, platform_name, platform_id)
    {
      "repository"   => repo,
      "display_name" => "TODO",
      "identifier"   => "#{author}.#{shortname}",
      "platform"     => platform_name,
      "assets"       => build_asset_json(platform_id)
    }
  end

  def build_asset_json(platform)
    data_slots = parse_json_file(DATA_FILE).dig("data", "data_slots")

    data_slots.select { |slot| slot["required"] }.map do |slot|
      { "platform" => platform }.tap do |hash|
        hash["extensions"] = slot["extensions"] if slot["extensions"]
        hash["filename"]   = slot["filename"]   if slot["filename"]
      end.merge(extract_parameters(slot["parameters"]))
         .reject { |asset| asset["instance_json"] }
    end
  end

  def parse_json_file(file_name)
    file_path = Dir["#{directory}/**/#{file_name}"].first
    file = File.read(file_path)
    JSON.parse(file)
  end

  def extract_parameters(int)
    int = int.to_i(16) if int.is_a?(String)

    BITMAP.map.with_object({}) do |(key, val), hash|
      hash[key] = (int & val != 0)
    end.select { |_, val| val }
  end
end

# url = "https://github.com/spiritualized1997/openFPGA-GBA"
url = "https://github.com/spiritualized1997/openFPGA-GB-GBC"
g = DataGenerator.new(url)
pp g.call
