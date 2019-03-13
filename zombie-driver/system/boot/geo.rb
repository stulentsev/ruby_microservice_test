Application.boot(:geo) do |container|
  init do
    require 'geokit'

    Geokit.default_units = :meters
    # Flat-surface formulae as the distances we're dealing with are tiny
    # and we don't need spherical projection and planar approximation should
    # work just fine
    Geokit.default_formula = :flat
  end

  start do
    container.register('geo.distance', call: false) do |from:, to:|
      Geokit::GeoLoc.distance_between(
        [from.latitude, from.longitude], [to.latitude, to.longitude]
      )
    end
  end
end
