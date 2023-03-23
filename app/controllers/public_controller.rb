# frozen_string_literal: true

# main public controller
class PublicController < ApplicationController
  def index
    location = params[:city]
    return if location.blank?

    @weather = fetch_weather(location)
  rescue StandardError => e
    redirect_to root_url, alert: "Could not forecast weather for #{location}"
  end

  private

  def fetch_weather(location)
    cache_id = location.downcase
    cache = Rails.cache.read(cache_id)
    return cache.merge(cache: true).with_indifferent_access unless cache.blank?

    weather = WeatherApi.fetch_weather(location)
    Rails.cache.write(cache_id, weather, expires_in: 30.minutes)

    weather
  end
end
