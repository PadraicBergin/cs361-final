require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase

  def test_waypoints
    w = WayPoint.new(:lat => -121.5, :long => 45.5, :elevation => 30, :name => "home", :icon => "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(w.json)
    assert_equal(result, expected)

    w = WayPoint.new(:lat => -121.5,:long => 45.5, :elevation =>nil, :name => nil, :icon =>  "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.json)
    assert_equal(result, expected)

    w = WayPoint.new(:lat => -121.5,:long =>  45.5, :elevation =>nil, :name =>  "store", :icon =>   nil)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.json)
    assert_equal(result, expected)
  end

  def test_tracks
    ts1 = TrackSegment.new(:points => [
      Point.new(:lat => -122,:long => 45),
      Point.new(:lat => -122,:long =>  46),
      Point.new(:lat => -121,:long =>  46)
    ])

    ts2 = TrackSegment.new(:points => [ Point.new(:lat => -121,:long => 45), Point.new(:lat => -121,:long => 46)])

    ts3 = TrackSegment.new(:points => [
      Point.new(:lat => -121,:long => 45.5),
      Point.new(:lat => -122,:long => 45.5)
    ])

    t = Track.new(:tracksegments => [ts1, ts2],:name => "track 1")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(t.json)
    assert_equal(expected, result)

    t = Track.new(:tracksegments => [ts3],:name => "track 2")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    result = JSON.parse(t.json)
    assert_equal(expected, result)
  end

  def test_world
    w = WayPoint.new(:lat => -121.5, :long => 45.5, :elevation => 30, :name => "home", :icon => "flag")
    w2 = WayPoint.new(:lat => -121.5, :long => 45.6, :elevation => nil, :name => "store", :icon => "dot")
    ts1 = TrackSegment.new(:points => [
      Point.new(:lat => -122,:long => 45),
      Point.new(:lat => -122,:long =>  46),
      Point.new(:lat => -121,:long =>  46)
    ])

    ts2 = TrackSegment.new(:points => [ Point.new(:lat => -121,:long => 45), Point.new(:lat => -121,:long => 46)])

    ts3 = TrackSegment.new(:points => [
      Point.new(:lat => -121,:long => 45.5),
      Point.new(:lat => -122,:long => 45.5)
    ])

    t = Track.new(:tracksegments => [ts1, ts2],:name => "track 1")
    t2 = Track.new(:tracksegments => [ts3],:name => "track 2")

    w = World.new(:name => "My Data",:features => [w, w2, t, t2])

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(w.json)
    assert_equal(expected, result)
  end

end
