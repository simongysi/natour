require 'csv'
require 'pathname'

module Natour
  class SpeciesList
    attr_reader :path
    attr_reader :date
    attr_reader :type
    attr_reader :name
    attr_reader :description

    def initialize(path, date, type, name, description, items)
      @path = path
      @date = date
      @type = type
      @name = name
      @description = description
      @items = items
    end

    def self.load_file(filename)
      block = IO.binread(filename, 32)
      header = if block.unpack('CC') == [0xff, 0xfe]
                 block[2..-1].force_encoding('utf-16le').encode('utf-8')
               elsif block.unpack('CCC') == [0xef, 0xbb, 0xbf]
                 block[3..-1].force_encoding('utf-8')
               else
                 block.force_encoding('utf-8')
               end

      case header
      when /^Primary/
        CSV.open(filename, 'r:windows-1252:utf-8', headers: true, liberal_parsing: true) do |csv|
          date = DateParser.parse(Pathname(filename).basename).compact.first
          items = csv.map { |row| Species.new(row[1], row[0]) }
                     .sort_by(&:name_de).uniq
          [SpeciesList.new(filename, date, :kosmos_vogelfuehrer, nil, nil, items)]
        end
      when /^Favoriten/
        CSV.open(filename, 'r:bom|utf-8', col_sep: ';', skip_blanks: true) do |csv|
          chunks = csv.reject { |row| row.count == 1 && row[0] != 'Favoriten' }
                      .reject { |row| row.count == 4 && row[0] == 'NUMMER_FLORA' }
                      .slice_before { |row| row.count == 1 || row.count == 3 }
                      .reject { |rows| rows.count == 1 }
          chunks.map do |rows|
            name, description = rows.shift
            date = DateParser.parse(name, Pathname(filename).basename).compact.first
            items = rows.map { |row| Species.new(row[1][/^(([^ ]+ [^ ]+)(( aggr\.)|( subsp\. [^ ]+))?)/, 1], row[2]) }
                        .sort_by(&:name).uniq
            SpeciesList.new(
              filename,
              date,
              :flora_helvetica,
              name&.gsub(/^(\d{4}-)?\d{2}-\d{2}( |_|-)?/, ''),
              description,
              items
            )
          end
        end
      when /^obs_id/
        CSV.open(filename, 'r:bom|utf-16le:utf-8', col_sep: "\t", headers: true) do |csv|
          date = DateParser.parse(Pathname(filename).basename).compact.first
          items = csv.select { |row| row[0] }
                     .map { |row| Species.new(row[11][/^(([^ ]+ [^ ]+)(( aggr\.)|( subsp\. [^ ]+))?)/, 1], nil) }
                     .sort_by(&:name).uniq
          [SpeciesList.new(filename, date, :info_flora, nil, nil, items)]
        end
      end
    end

    include Enumerable

    def each(&block)
      @items.each(&block)
    end
  end
end
