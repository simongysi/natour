require 'pathname'

module Natour
  class Report
    attr_reader :path
    attr_reader :title
    attr_reader :images
    attr_reader :species_lists
    attr_reader :gps_track
    attr_reader :map_image
    attr_reader :starting_point
    attr_reader :arrival_point

    def initialize(path,
                   title,
                   images,
                   species_lists,
                   gps_track: nil,
                   map_image: nil,
                   starting_point: nil,
                   arrival_point: nil)
      @path = path
      @title = title
      @images = images
      @species_lists = species_lists
      @gps_track = gps_track
      @map_image = map_image
      @starting_point = starting_point
      @arrival_point = arrival_point
    end

    def self.load_directory(dir, track_formats: %i[gpx fit], create_map: true, overwrite_map: false, map_layers: [])
      Dir.chdir(dir) do
        path = Pathname(dir)
        title = Pathname.pwd.basename.to_s.encode('utf-8')
                        .gsub(/^\d{4}-\d{2}-\d{2}( |_|-)?/, '')
        images = Pathname.glob('**/*.{[j|J][p|P][g|G],[j|J][p|P][e|E][g|G]}')
                         .map { |filename| Image.load_file(filename.to_s) }
                         .sort_by { |image| [image.date_time ? 0 : 1, image.date_time, image.path] }
        species_lists =
          Pathname.glob('**/*.{[c|C][s|S][v|V],[k|K][m|M][l|L]}')
                  .map { |filename| SpeciesList.load_file(filename.to_s) }
                  .flatten
                  .sort_by { |species_list| [species_list.type, species_list.date ? 0 : 1, species_list.date] }
        gps_tracks = if track_formats.empty?
                       []
                     else
                       track_patterns = { gpx: '[g|G][p|P][x|X]', fit: '[f|F][i|I][t|T]' }
                       track_pattern = track_formats.map { |track_format| track_patterns[track_format] }
                                                    .compact
                                                    .join(',')
                       Pathname.glob("**/*.{#{track_pattern}}")
                               .map { |filename| GPSTrack.load_file(filename.to_s) }
                               .compact
                               .sort_by { |gps_track| [gps_track.date, gps_track.path] }
                     end

        if create_map
          map_images = MapGeoAdmin.open do |map|
            Dir.mktmpdir do |tmp_dir|
              gps_tracks.map do |gps_track|
                track = Pathname(tmp_dir).join(gps_track.path).sub_ext('.gpx')
                gps_track.save_gpx(track, overwrite: true)
                filename = Pathname(gps_track.path).sub_ext('.jpg')
                map.save_image(filename, overwrite: overwrite_map, gps_files: [track], map_layers: map_layers)
                Image.load_file(filename.to_s)
              end
            end
          end
        end

        if gps_tracks.empty?
          [Report.new(path.to_s, title, images, species_lists)]
        else
          gps_tracks.zip(map_images.to_a).map do |gps_track, map_image|
            starting_station = PublicTransport.search_station(
              [gps_track.start_point.latitude, gps_track.start_point.longitude]
            )
            arrival_station = PublicTransport.search_station(
              [gps_track.end_point.latitude, gps_track.end_point.longitude]
            )
            Report.new(
              path.to_s,
              title,
              images.select { |image| !image.date_time || image.date_time.to_date == gps_track.date },
              species_lists.select { |species_list| !species_list.date || species_list.date == gps_track.date },
              gps_track: gps_track.round_effective_km!,
              map_image: map_image,
              starting_point: starting_station&.label,
              arrival_point: arrival_station&.label
            )
          end
        end
      end
    end

    include Asciinurse
  end
end
