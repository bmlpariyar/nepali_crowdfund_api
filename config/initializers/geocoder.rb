# config/initializers/geocoder.rb
Geocoder.configure(
  # Geocoding service
  lookup: :nominatim,
  language: :en,
  use_https: true,
  units: :km,
)
