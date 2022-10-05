# frozen_string_literal: true

require "json"
require "net/http"
require "open-uri"
require "uri"
require "yaml"

module GitHub
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

    CORE_FILE   = "core.json"
    DATA_FILE   = "data.json"
    CACHED_DATA = "_data/cores.yml"

    attr_reader :username, :repository, :display_name

    def initialize(username, repository, display_name)
      @username     = username
      @repository   = repository
      @display_name = display_name
    end

    def call
      fetch_download_urls.each.with_object([]) do |metadata, arr|
        arr << if version_changed?(metadata["version"])
          puts "Updating data for #{repository}."
          @directory = download_asset(metadata["file_name"], metadata["url"])
          json = build_json(metadata)
          return json unless json.nil?
        else
          puts "#{repository} is already up-to-date."
          return cached_data
        end
      end.flatten
    end

    private

    def fetch_download_urls
      uri = URI.parse("https://api.github.com/repos/#{username}/#{repository}/releases")
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{$github_token}"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      unless response.is_a?(Net::HTTPOK)
        puts "Something went wrong while fetching the download URLs for #{repository}."
        exit 1 # Signal to GitHub Actions that the workflow run failed.
      end

      # TODO: In order to get repos with only pre-releases, we have to use the /releases endpoint,
      #       instead of the /releases/latest endpoint. This returns an array of release objects,
      #       instead of a single release. That's what the #first call is for. We might want to
      #       do something about this if we don't want to always get a pre-release version.
      body = JSON.parse(response.body).first
      # TODO: Add pre_release version if there is one
      # pre_release = body["prerelease"]

      body["assets"].tap { |arr| skip_asset(arr) }.map do |asset|
        {
          "file_name"    => asset["name"],
          "url"          => asset["url"],
          "version"      => body["tag_name"].delete_prefix("v"),
          "release_date" => body["published_at"]
        }
      end
    end

    # Hack for the openFPGA-GB-GBC repo that hosts cores for both the GB & GBC.
    def skip_asset(arr)
      case display_name
      when "Spiritualized GB"
        arr.delete_at(0)
      when "Spiritualized GBC"
        arr.delete_at(1)
      end
    end

    def cached_data
      @cached_data ||= YAML.load_file(CACHED_DATA)
                           &.detect { |author| author["username"] == username }
                           &.dig("cores")
                           &.detect { |core| core["repository"] == repository }
    end

    # TODO: This should probably be #core_changed? or something.
    #       Assets could be updated or something without a version change.
    def version_changed?(new_version)
      new_version != cached_data&.dig("version")
    end

    def download_asset(file_name, url)
      dir_name = File.basename(file_name, ".zip")

      # If the directory already exists, don't download it again.
      return dir_name if Dir.exist?(dir_name)

      File.open(file_name, "wb") do |file|
        headers = {
          "Accept" => "application/octet-stream",
          "Authorization" => "Bearer #{$github_token}"
        }
        file << URI.open(url, headers).read
      end
      system("unzip", "-q", file_name, "-d", dir_name)

      dir_name
    end

    def build_json(repo_metadata)
      core_metadata = parse_json_file(CORE_FILE)&.dig("core", "metadata")

      # Some releases include additional assets on top of the core.
      # If the asset does not include a core.json file, we can safely
      # assume it's not the core and skip it.
      return nil unless core_metadata

      # TODO: There can probably be multiple platform_ids
      platform_id   = core_metadata["platform_ids"].first
      platform_json = parse_json_file("#{platform_id}.json", "Platforms")["platform"]

      {
        "repository"   => repository,
        "display_name" => display_name,
        "identifier"   => "#{core_metadata["author"]}.#{core_metadata["shortname"]}",
        "platform"     => platform_json["name"],
        "version"      => repo_metadata["version"],
        "release_date" => repo_metadata["release_date"],
        "assets"       => build_asset_json(platform_id)
      }
    end

    def build_asset_json(platform)
      data_slots = parse_json_file(DATA_FILE).dig("data", "data_slots")

      data_slots.select { |slot| slot["required"] }.map do |slot|
        { "platform" => platform }.tap do |hash|
          hash["filename"]   = slot["filename"]   if slot["filename"]
          hash["extensions"] = slot["extensions"] if slot["extensions"]
        end.merge(extract_parameters(slot["parameters"]))
      end.reject { |slot| slot["instance_json"] }
    end

    def parse_json_file(file_name, subdirectory = "Cores")
      file_path = Dir.glob("#{@directory}/#{subdirectory}/**/#{file_name}").first

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
end
