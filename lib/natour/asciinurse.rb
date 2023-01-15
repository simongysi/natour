require 'fileutils'
require 'ostruct'
require 'pathname'

module Natour
  module Asciinurse
    def save_adoc(filename, overwrite: false, author: nil)
      dir = Pathname(filename).dirname
      FileUtils.mkdir_p(dir)
      mode = File::WRONLY | File::CREAT | File::TRUNC
      mode |= File::EXCL unless overwrite
      File.open(filename, mode) do |file|
        file.write(to_adoc(
          doc_root: Pathname(path).realpath
                                  .relative_path_from(dir.realpath)
                                  .to_s.force_encoding('utf-8'),
          author: author
        ))
      end
    end

    def to_adoc(doc_root: '.', author: nil)
      distance = ->(gps_track) { "#{gps_track.distance / 1000} km" if gps_track&.distance }
      ascent = ->(gps_track) { "#{gps_track.ascent} m" if gps_track&.ascent }
      descent = ->(gps_track) { "#{gps_track.descent} m" if gps_track&.descent }

      title_image = images.find(&:landscape?)

      doc = []
      doc << "= #{title}"
      doc << author if author
      doc << ':revdate: {docdate}'
      doc << ':figure-caption!:'
      doc << ':table-caption!:'
      doc << ':pdf-page-mode: none'
      doc << ':title-page:'
      if title_image
        doc << ":title-image: #{Pathname(doc_root).join(title_image.path)}"
        doc << ':title-logo-image: image::{title-image}[top=0%]'
        doc << ''
        doc << 'ifndef::backend-pdf[]'
        doc << 'image::{title-image}[]'
        doc << 'endif::[]'
      end
      doc << ''
      doc << '<<<'
      doc << ''
      doc << '== Allgemein'
      doc << ''
      doc << '[cols="h,3"]'
      doc << '|==='
      doc << "|Datum      |#{gps_track&.date&.strftime('%d.%m.%Y')}"
      doc << "|Startzeit  |#{gps_track&.start_point&.time&.strftime('%H:%M Uhr')}"
      doc << "|Dauer      |#{gps_track&.duration&.strftime('%th:%M h')}"
      doc << "|Strecke    |#{distance.call(gps_track)}"
      doc << "|Aufstieg   |#{ascent.call(gps_track)}"
      doc << "|Abstieg    |#{descent.call(gps_track)}"
      doc << "|Ausgangsort|#{starting_point}"
      doc << "|Ankunftsort|#{arrival_point}"
      doc << '|Teilnehmer |'
      doc << '|==='
      doc << ''
      if map_image
        doc << "image::#{Pathname(doc_root).join(map_image.path)}[]"
        doc << ''
      end
      doc << '<<<'
      doc << ''
      doc << '== Beschreibung'
      doc << ''
      doc << ''
      doc << ''
      unless images.empty?
        doc << '<<<'
        doc << ''
        doc << '== Bilder'
        doc << ''
        images.each do |image|
          width = if image.landscape?
                    '80%'
                  else
                    '40%'
                  end
          doc << '.Abbildung {counter:image}'
          doc << "image::#{Pathname(doc_root).join(image.path)}[width=#{width}]"
          doc << ''
        end
      end
      unless species_lists.empty?
        doc << '<<<'
        doc << ''
        doc << '== Artenlisten'
        doc << ''
        index = 1
        groups = species_lists.group_by(&:group)
        [
          OpenStruct.new(
            group: :plants,
            title: 'Pflanzenarten',
            columns: [
              OpenStruct.new(header: 'Wissenschaftlicher Name', accessor: :name),
              OpenStruct.new(header: 'Deutscher Name', accessor: :name_de)
            ]
          ),
          OpenStruct.new(
            group: :birds,
            title: 'Vogelarten',
            columns: [
              OpenStruct.new(header: 'Deutscher Name', accessor: :name_de),
              OpenStruct.new(header: 'Wissenschaftlicher Name', accessor: :name)
            ]
          )
        ].each do |info|
          group = groups.fetch(info.group, [])
          next if group.empty?

          doc << "=== #{info.title}"
          doc << ''
          group.each do |species_list|
            caption = '.Tabelle {counter:species_lists}'
            caption << ": #{species_list.description}" if species_list.description
            columns = info.columns.select do |column|
              species_list.any? { |species| !species.public_send(column.accessor).nil? }
            end
            cols = [1] + [5 * info.columns.size / columns.size] * columns.size
            doc << caption
            doc << "[%breakable,cols=\"#{cols.join(',')}\",options=header]"
            doc << '|==='
            doc << "|Nr.|#{columns.map(&:header).join('|')}"
            species_list.each do |species|
              doc <<
                "|{counter:species_list#{index}}|#{columns.map { |column| species.public_send(column.accessor) }
                                                          .join('|')}"
            end
            doc << '|==='
            doc << ''
            index += 1
          end
        end
      end
      doc.join("\n")
    end
  end
end
