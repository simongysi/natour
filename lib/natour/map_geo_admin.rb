require 'concurrent'
require 'ferrum'
require 'fileutils'
require 'pathname'
require 'uri'
require 'webrick'

module Natour
  class MapGeoAdmin
    def initialize(port: 0)
      @doc_root = Pathname(Dir.mktmpdir)
      FileUtils.cp_r("#{__dir__}/data/js", @doc_root)
      event = Concurrent::Event.new
      @server = WEBrick::HTTPServer.new(
        StartCallback: -> { event.set },
        Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
        AccessLog: [],
        DocumentRoot: @doc_root,
        BindAddress: 'localhost',
        Port: port
      )
      @server.mount('/map', MapServlet)
      @thread = Thread.new { @server.start }
      event.wait
      @browser = Ferrum::Browser.new(
        slowmo: 2.0,
        window_size: [5000, 5000],
        browser_options: { 'no-sandbox': nil }
      )
    end

    def close
      @browser.quit
      @server.shutdown
      @thread.join
      FileUtils.remove_entry(@doc_root)
    end

    def save_image(filename, overwrite: false, gps_files: [], map_layers: [], image_size: [1200, 900])
      FileUtils.cp(gps_files, @doc_root)
      uri = URI("http://#{@server[:BindAddress]}:#{@server[:Port]}/map")
      uri.query = URI.encode_www_form(
        'gps-files': gps_files.map { |gps_file| Pathname(gps_file).basename }.join(','),
        'map-layers': map_layers.join(','),
        'map-size': image_size.map { |dim| dim.is_a?(String) ? dim : "#{dim}px" }.join(',')
      )
      @browser.goto(uri)
      tmp_filename = @doc_root.join(Pathname(filename).basename)
      @browser.screenshot(
        path: tmp_filename,
        quality: 100,
        selector: '.map'
      )
      FileUtils.mkdir_p(Pathname(filename).dirname)
      mode = File::WRONLY | File::CREAT | File::TRUNC | File::BINARY
      mode |= File::EXCL unless overwrite
      File.open(filename, mode) do |file|
        file.write(File.read(tmp_filename, mode: 'rb'))
      end
    end

    def self.open(*args)
      map = MapGeoAdmin.new(*args)
      return map unless block_given?

      yield(map)
    ensure
      map&.close
    end

    class MapServlet < WEBrick::HTTPServlet::AbstractServlet
      def do_GET(request, response) # rubocop:disable Naming/MethodName
        raise WEBrick::HTTPStatus::NotFound unless request.path == '/map'

        files = request.query.fetch('gps-files', '').split(',')
        layers = request.query.fetch('map-layers', '').split(',')
        layers.unshift('ch.swisstopo.pixelkarte-farbe')

        width, height = request.query.fetch('map-size', '').split(',')
        raise WEBrick::HTTPStatus::BadRequest unless width && height

        doc = []
        doc << '<html><head>'
        doc << '<link rel="icon" href="data:;base64,iVBORw0KGgo=">'
        doc << '<script src="js/jquery-3.5.1.slim.min.js"></script>'
        doc << '<script src="js/bootstrap.min.js"></script>'
        doc << '<script src="js/loader.js"></script>'
        doc << '<script type="text/javascript">'
        doc << '  $(function() {'
        doc << '    var map = new ga.Map({'
        doc << '      controls: [],'
        doc << '      target: "map",'
        doc << '      view: new ol.View()'
        doc << '    })'
        doc << "    var layers = [#{layers.map { |layer| "\"#{layer}\"" }.join(', ')}]"
        doc << '    layers.forEach(function(layer) {'
        doc << '      map.addLayer(ga.layer.create(layer))'
        doc << '    })'
        doc << "    var files = [#{files.map { |file| "\"#{file}\"" }.join(', ')}]"
        doc << '    var vectors = files.map(function(file) {'
        doc << '      return new ol.layer.Vector({'
        doc << '        source: new ol.source.Vector({'
        doc << '          format: new ol.format.GPX(),'
        doc << '          url: file'
        doc << '        }),'
        doc << '        style: new ol.style.Style({'
        doc << '          stroke: new ol.style.Stroke({'
        doc << '            color: "blueviolet",'
        doc << '            width: 3'
        doc << '          })'
        doc << '        })'
        doc << '      })'
        doc << '    })'
        doc << '    vectors.forEach(function(vector) {'
        doc << '      map.addLayer(vector)'
        doc << '      vector.getSource().on("change", function(evt) {'
        doc << '        var extent = ol.extent.createEmpty()'
        doc << '        vectors.forEach(function(vector) {'
        doc << '          ol.extent.extend(extent, vector.getSource().getExtent())'
        doc << '        })'
        doc << '        map.getView().fit(extent, map.getSize())'
        doc << '      })'
        doc << '    })'
        doc << '  })'
        doc << '</script>'
        doc << '<style type="text/css">'
        doc << '  .map {'
        doc << "    width: #{width};"
        doc << "    height: #{height};"
        doc << '  }'
        doc << '</style>'
        doc << '</head><body><div id="map" class="map"></div></body></html>'
        response.body = doc.join("\n")
        response['Content-Type'] = 'text/html'
      end
    end
  end
end
