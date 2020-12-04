require 'uri'
require 'net/http'
require 'openssl'
require 'json'

module Natour
  class PublicTransport
    def self.search_station(position, radius: 200)
      position = position.join(',') if position.is_a?(Array)
      uri = URI('https://timetable.search.ch/api/completion.json')
      uri.query = URI.encode_www_form(latlon: position.gsub(' ', ''))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = http.request(Net::HTTP::Get.new(uri))
      return unless response.is_a?(Net::HTTPSuccess)

      stations = JSON.parse(response.body, symbolize_names: true)
      stations.reject! { |station| station[:dist] > radius }
      station_types = %w[
        sl-icon-type-train
        sl-icon-type-strain
        sl-icon-type-tram
        sl-icon-type-bus
        sl-icon-type-ship
        sl-icon-type-funicular
        sl-icon-type-cablecar
        sl-icon-type-gondola
        sl-icon-type-chairlift
      ]

      stations = station_types.map do |station_type|
        stations.find { |station| station[:iconclass] == station_type }
      end

      station = stations.compact.first
      return unless station

      Station.new(
        station[:label],
        station[:iconclass].delete_prefix('sl-icon-type-').to_sym,
        station[:dist]
      )
    end
  end
end
