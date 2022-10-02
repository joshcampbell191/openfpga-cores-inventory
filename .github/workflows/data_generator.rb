# frozen_string_literal: true

require "json"
require "net/http"
require "open-uri"
require "uri"

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

  attr_reader :username, :repository, :display_name
  attr_accessor :directory

  def initialize(username, repository, display_name)
    @username     = username
    @repository   = repository
    @display_name = display_name
  end

  def call
    puts repository
    json = []

    fetch_download_urls.each do |url|
      @directory = download_asset(url)
      json << build_json
    end

    json.flatten
  end

  private

  def fetch_download_urls
    uri = URI.parse("https://api.github.com/repos/#{username}/#{repository}/releases")
    request = Net::HTTP::Get.new(uri)
    # TODO: Replace with workflow access token
    request["Authorization"] = ""

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    # TODO: Figure out what to do in this case.
    if response.code == "403"
      puts "rate limit exceeded"
      return []
    end

    # TODO: In order to get repos with only pre-releases, we have to use the /releases endpoint,
    #       instead of the /releases/latest endpoint. This returns an array of release objects,
    #       instead of a single release. That's what the #first call is for. We might want to
    #       do something about this if we don't want to always get a pre-release version.
    JSON.parse(response.body).first["assets"].map { |asset| asset["browser_download_url"] }
  end

  def download_asset(url)
    file_name = URI.parse(url).path.split("/").last
    dir_name  = File.basename(file_name, ".zip")

    # If the directory already exists, don't download it again.
    return dir_name if Dir.exist?(dir_name)

    open(file_name, "wb") do |file|
      file << URI.open(url).read
    end
    system("unzip -q #{file_name} -d #{dir_name}")
    File.delete(file_name)

    dir_name
  end

  def build_json
    metadata = parse_json_file(CORE_FILE)&.dig("core", "metadata")

    # Some releases include additional assets on top of the core.
    # If the asset does not include a core.json file, we can safely
    # assume it's not the core and skip it.
    return [] unless metadata

    platform_id   = metadata["platform_ids"].first # TODO: There can probably be multiple platform_ids
    platform_json = parse_json_file("#{platform_id}.json")["platform"]

    {
      "repository"   => repository,
      "display_name" => display_name,
      "identifier"   => "#{metadata["author"]}.#{metadata["shortname"]}",
      "platform"     => platform_json["name"],
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

    # If the file doesn't exist, the directory is not a core.
    return unless file_path

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
