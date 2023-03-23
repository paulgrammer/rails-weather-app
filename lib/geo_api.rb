# frozen_string_literal: true

require 'net/http'
require 'json'

# module to convert locations or zip codes to geo co-ordinates
module GeoApi
  PARAMS = { limit: 1, appid: ENV['API_KEY'] }

  class << self
    def get_coordinates(location)
      query_values = get_params(location)
      uri = URI(query_values[:url])
      params = query_values[:query_params]
      uri.query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new(uri)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(req)
      end

      ret_val = JSON.parse(response.body)
      generic_resp = ret_val.is_a?(Array) ? ret_val.first : ret_val

      { lat: generic_resp['lat'], lon: generic_resp['lon'] }.with_indifferent_access
    end

    def get_params(value)
      if zipcode?(value)
        { url: BASE_URL + 'geo/1.0/zip', query_params: PARAMS.merge({ zip: value }) }.with_indifferent_access
      else
        { url: BASE_URL + 'geo/1.0/direct', query_params: PARAMS.merge({ q: value }) }.with_indifferent_access
      end
    end

    def zipcode?(value)
      value.scan(/\D/).empty?
    end
  end
end
