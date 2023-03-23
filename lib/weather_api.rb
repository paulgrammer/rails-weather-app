# frozen_string_literal: true

require 'net/http'
require 'json'

# module to weather forecast information
module WeatherApi
  class << self
    def fetch_weather(location)
      coordinates = GeoApi.get_coordinates(location)
      latitude = coordinates[:lat]
      longitude = coordinates[:lon]
      uri = URI(BASE_URL + 'data/3.0/onecall')
      params = { lat: latitude, lon: longitude, exclude: 'hourly,minutely,alerts', units: 'metric',
                 appid: ENV['API_KEY'] }
      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Get.new(uri)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      weather_resp = JSON.parse(response.body).with_indifferent_access

      {
        location: location_name(latitude, longitude),
        units: 'C',
        current: {
          high: weather_resp[:daily][0][:temp][:max],
          low: weather_resp[:daily][0][:temp][:min],
          wind: weather_resp[:daily][0][:wind_speed],
          humidity: weather_resp[:daily][0][:humidity],
          temp: weather_resp[:current][:feels_like].try(:to_i),
          conditions: weather_resp[:current][:weather][0][:description],
          icon: ICON_URL + weather_resp[:current][:weather][0][:icon] + '.png',
          date: Date.today
        },
        forecast: (1..3).map do |idx|
          {
            high: weather_resp[:daily][idx][:temp][:max],
            low: weather_resp[:daily][idx][:temp][:min],
            wind: weather_resp[:daily][idx][:wind_speed],
            humidity: weather_resp[:daily][idx][:humidity],
            temp: ((weather_resp[:daily][idx][:temp][:max] + weather_resp[:daily][idx][:temp][:min]) / 2).try(:to_i),
            conditions: weather_resp[:daily][idx][:weather][0][:description],
            icon: ICON_URL + weather_resp[:daily][idx][:weather][0][:icon] + '.png',
            date: Date.today + idx
          }
        end
      }.with_indifferent_access
    end

    def location_name(lat, lon)
      uri = URI(BASE_URL + 'geo/1.0/reverse')
      params = { lat:, lon:, limit: 1, appid: ENV['API_KEY'] }
      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Get.new(uri)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      JSON.parse(response.body)[0]['name']
    end
  end
end
