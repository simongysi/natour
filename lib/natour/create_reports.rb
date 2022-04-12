require 'pathname'

module Natour
  module_function

  def create_reports(dir, out_dir: nil, out_file: nil, overwrite: false,
                     track_formats: %i[gpx fit], create_map: true, map_layers: [], adoc_author: nil)
    out_dir = Pathname(out_dir || dir)
    out_file = Pathname(out_file || "#{Pathname(dir).realpath.basename}.adoc")
    reports = Report.load_directory(
      dir, track_formats: track_formats, create_map: create_map, overwrite_map: overwrite, map_layers: map_layers
    )
    reports.map.with_index(1) do |report, index|
      filename = if index < 2
                   out_dir.join(out_file)
                 else
                   out_dir.join("#{out_file.basename('.*')} (#{index})#{out_file.extname}")
                 end
      report.save_adoc(filename, overwrite: overwrite, author: adoc_author)
      filename.to_s
    end
  end
end
