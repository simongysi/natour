require 'csv'
require 'nokogiri'
require 'pathname'

module Natour
  class SpeciesList
    attr_reader :path
    attr_reader :date
    attr_reader :type
    attr_reader :group
    attr_reader :title
    attr_reader :description

    def initialize(path, date, type, group, title, description, items)
      @path = path
      @date = date
      @type = type
      @group = group
      @title = title
      @description = description
      @items = items
    end

    def self.load_file(filename)
      block = IO.binread(filename, 128)
      header = if block.unpack('CC') == [0xff, 0xfe]
                 block[2..].force_encoding('utf-16le').encode('utf-8')
               elsif block.unpack('CCC') == [0xef, 0xbb, 0xbf]
                 block[3..].force_encoding('utf-8')
               else
                 block
               end

      case header
      when /^Primary/
        CSV.open(filename, 'r:windows-1252:utf-8', headers: true, liberal_parsing: true) do |csv|
          date = DateUtils.parse(Pathname(filename).basename).compact.first
          items = csv.map { |row| Species.new(row[1], row[0]) }
                     .sort_by(&:name_de).uniq
          [SpeciesList.new(filename, date, :kosmos_vogelfuehrer, :birds, nil, nil, items)]
        end
      when /^Name/
        CSV.open(filename, 'r:bom|utf-8', headers: true) do |csv|
          date = DateUtils.parse(Pathname(filename).basename).compact.first
          items = csv.map { |row| Species.new(row[1], row[0]) }
                     .sort_by(&:name_de).uniq
          [SpeciesList.new(filename, date, :birdlife_vogelfuehrer, :birds, nil, nil, items)]
        end
      when /^<\?xml.*?www\.ornitho\.ch/m
        date = DateUtils.parse(Pathname(filename).basename).compact.first
        doc = Nokogiri.XML(File.read(filename, mode: 'r:utf-8'))
        folder = doc.at('/xmlns:kml/xmlns:Document/xmlns:Folder/xmlns:Folder/xmlns:Folder')
        name = folder.at('./xmlns:name').text
        items = folder.xpath('./xmlns:Placemark/xmlns:description')
                      .map(&:text)
                      .map { |description| Species.new(*description.scan(/&gt;([^&(]+)&lt;/).flatten.reverse) }
                      .sort_by(&:name_de).uniq
        [SpeciesList.new(filename, date, :ornitho_ch, :birds, name, nil, items)]
      when /^(Favoriten|NUMMER_FLORA)/
        CSV.open(filename, 'r:bom|utf-8', col_sep: ';', skip_blanks: true) do |csv|
          chunks = csv.reject { |row| row.count == 1 }
                      .map { |row| row[0] == 'NUMMER_FLORA' ? ['Favoriten'] : row }
                      .slice_before { |row| row.count == 1 || row.count == 3 }
                      .reject { |rows| rows.count == 1 }
          chunks.map do |rows|
            name, description = rows.shift
            date = DateUtils.parse(name, Pathname(filename).basename).compact.first
            items = rows.map { |row| Species.new(BotanicalNameUtils.parse(row[1]), row[2]) }
                        .sort_by(&:name).uniq
            SpeciesList.new(
              filename,
              date,
              :flora_helvetica,
              :plants,
              name&.gsub(/^(\d{4}-)?\d{2}-\d{2}( |_|-)?/, ''),
              description,
              items
            )
          end
        end
      when /^obs_id/
        CSV.open(filename, 'r:bom|utf-16le:utf-8', col_sep: "\t", headers: true) do |csv|
          date = DateUtils.parse(Pathname(filename).basename).compact.first
          items = csv.select { |row| row[0] }
                     .map { |row| Species.new(BotanicalNameUtils.parse(row[11]), nil) }
                     .sort_by(&:name).uniq
          [SpeciesList.new(filename, date, :info_flora, :plants, nil, nil, items)]
        end
      else
        []
      end
    end

    include Enumerable

    def each(&block)
      @items.each(&block)
    end
  end
end
