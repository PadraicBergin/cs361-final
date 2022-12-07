#!/usr/bin/env ruby
require 'json'
class Track             #List of TrackSegments
    attr_reader :tracksegments, :name, :args
    
    def initialize(args)
        @args = args
        @tracksegments = args.fetch(:tracksegments)
        @name = args.fetch(:name, nil)
    end

    def get_track_segments()
        geometry = []
        tracksegments.each do |tracksegment|
            geometry.append(tracksegment.create_point_list)
        end
        return geometry
    end

    def json()
        type = "MultiLineString"
        properties = Properties.new(args)
        format = "{'type':'Feature','properties':{#{properties.json}},'geometry':{'type':'#{type}','coordinates':#{get_track_segments}}}"
        format = format.gsub("\'","\"")
        return format
    end

end

class TrackSegment      #List of Points
    attr_reader :points

    def initialize(args)
        @points = args.fetch(:points)
    end

    def create_point_list()
        point_list = []
        points.each do |point|
            point_list.append(point.as_list())
        end
        return point_list
    end
    
end

class Point             #used for track segment. Lat, long and possible elevation. NO NAME or ICON
    attr_reader :lat, :long, :elevation, :args

    def initialize(args)
        @args = args
        @lat = args.fetch(:lat)
        @long = args.fetch(:long)
        @elevation = args.fetch(:elevation, nil)
    end

    def as_list()
        geometry = Geometry.new(args)
        return geometry.as_list
    end
end

class Properties
    attr_reader :name, :icon

    def initialize(args)
        @name = args.fetch(:name, nil)
        @icon = args.fetch(:icon, nil)
    end

    def json
        name_string = ""
        format = ""
        if name != nil
            name_string += name
            name = name_string.gsub("\'","")
            format += "'title':'#{name}'"
            if icon != nil
                format += ",'icon':'#{icon}'"
            end
        elsif icon != nil
            format += "'icon':'#{icon}'"
        end
        
        return format
    end
end

class Geometry
    attr_reader :lat, :long, :elevation

    def initialize(args)
        @lat = args.fetch(:lat)
        @long = args.fetch(:long)
        @elevation = args.fetch(:elevation, nil)
    end

    def json
        format = "[#{lat},#{long}"
        if elevation != nil
            format += ",#{elevation}]"
        else
            format += "]"
        end
        return format
    end

    def as_list
        format = []
        format.append(lat)
        format.append(long)
        if elevation != nil
            format.append(elevation)
        end
        return format
    end
end

class WayPoint          #has lat, long and possible elevation. Possible NAME and ICON
    attr_reader :lat, :long, :elevation, :name, :icon, :args

    def initialize(args)
        @args = args
        @lat = args.fetch(:lat)
        @long = args.fetch(:long)
        @elevation = args.fetch(:elevation, nil)
        @name = args.fetch(:name, nil)
        @icon = args.fetch(:icon, nil)
    end

    def json()
        '''
        "type":"Feature",
            "properties":{
                "title":"home",
                "icon":"flag"
            },
            "geometry":{
                "type":"Point",
                "coordinates":[ -121.5, 45.5, 30 ]
            }
        '''
        properties = Properties.new(args)
        geometry = Geometry.new(args)
        format = "{'type':'Feature','properties':{#{properties.json}},'geometry':{'type':'Point','coordinates':#{geometry.json}}}"
        format = format.gsub("\'","\"")
        return format
    end

    def print()
        puts lat, long, name, icon
    end
end

class World
    attr_reader :features
    def initialize(args)
        @features = args.fetch(:features, nil)
        
    end

    def get_features()
        features_string = ""
        if features != nil
            features.each do |feature|
                features_string += feature.json()
                features_string += ","
            end
            return features_string.chomp(",")
        end
    end

    def json()
        format = "{'type':'FeatureCollection','features':[#{get_features}]}"
        format = format.gsub("\'","\"")
        return format
    end
end

class Tests 
    def way_point_test1
        wp = WayPoint.new(:lat => -121.5, :long => 45.5, :elevation => 30, :name => "home", :icon => "flag")
        puts wp.json()
    end

    def way_point_test2
        wp1 = WayPoint.new(:lat => 100, :long => 99, :icon => "house", :name => "myhouse")
        puts wp1.json()
    end

    def way_point_test3
        wp2 = WayPoint.new(:lat => 100, :long => 99, :elevation => 102)
        puts wp2.json()
    end

    def track_segment_test1
        p1 = Point.new(:lat => 100, :long => 99, :elevation => 102)
        p2 = Point.new(:lat => 100, :long => 99, :elevation => 102)
        p3 = Point.new(:lat => 100, :long => 99, :elevation => 102)
        
        ts1 = TrackSegment.new(:points => [p1, p2, p3])
        ts1.create_point_list()
    end

    def track_test1
        p1 = Point.new(:lat => 100, :long => 99, :elevation => 102)
        p2 = Point.new(:lat => 100, :long => 99, :elevation => 102)
        p3 = Point.new(:lat => 100, :long => 99, :elevation => 102)

        ts1 = TrackSegment.new(:points => [p1, p2, p3])

        t1 = Track.new(:tracksegments => [ts1])
        puts t1.json

    end

    def world_test1
        p1 = Point.new(:lat => 100, :long => 99, :elevation => 102)
        p2 = Point.new(:lat => 100, :long => 99, :elevation => 102)
        p3 = Point.new(:lat => 100, :long => 99, :elevation => 102)

        ts1 = TrackSegment.new(:points => [p1, p2, p3])

        t1 = Track.new(:tracksegments => [ts1, ts1])

        wp1 = WayPoint.new(:lat => 100, :long => 99, :icon => "house", :name => "myhouse")

        w1 = World.new(:features => [wp1, t1])
        data = w1.json()
        puts data
        JSON.parse(data)
    end

    def world_test2()
        wp1 = WayPoint.new(:lat => -121.5, :long => 45.5, :elevation => 30, :name => "home", :icon => "flag")

        wp2 = WayPoint.new(:lat => -121.5, :long => 45.6, :name => "store", :icon => "dot")


        p3 = Point.new(:lat => -122, :long => 45)
        p4 = Point.new(:lat => -122, :long => 46)
        p5 = Point.new(:lat => -121, :long => 46)

        p6 = Point.new(:lat => -121, :long => 45)
        p7 = Point.new(:lat => -121, :long => 46)

        p8 = Point.new(:lat => -121, :long => 45.5)
        p9 = Point.new(:lat => -122, :long => 45.5)

        ts1 = TrackSegment.new(:points => [p3, p4, p5])
        ts2 = TrackSegment.new(:points => [p6, p7])

        t1 = Track.new(:tracksegments => [ts1, ts2], :name => "track's 1")

        ts3 = TrackSegment.new(:points => [p8, p9])

        t2 = Track.new(:tracksegments => [ts3], :name => "track 2")

        w1 = World.new(:features => [wp1, wp2, t1, t2])
        data = w1.json()
        puts data
        JSON.parse(data)


    end
end

def main()
    t1 = Tests.new()
    t1.world_test2()
end

if File.identical?(__FILE__, $0)
    main()
end