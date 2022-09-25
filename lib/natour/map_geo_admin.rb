require 'concurrent'
require 'ferrum'
require 'fileutils'
require 'pathname'
require 'uri'
require 'webrick'
require 'webrick/https'

module Natour
  class MapGeoAdmin
    def initialize(port: 0)
      @doc_root = Pathname(Dir.mktmpdir)
      FileUtils.cp_r("#{__dir__}/data/js", @doc_root)
      event = Concurrent::Event.new
      @server = StdoutUtils.suppress_output do
        WEBrick::HTTPServer.new(
          StartCallback: -> { event.set },
          Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
          AccessLog: [],
          DocumentRoot: @doc_root,
          BindAddress: 'localhost',
          Port: port,
          SSLEnable: true,
          SSLCertName: [%w[CN localhost]]
        )
      end
      @server.mount('/map', MapServlet)
      @thread = Thread.new { @server.start }
      event.wait
      @browser = Ferrum::Browser.new(
        slowmo: 2.0,
        timout: 30,
        window_size: [5000, 5000],
        browser_options: {
          'no-sandbox': nil,
          'ignore-certificate-errors': nil
        }
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
      uri = URI("https://#{@server[:BindAddress]}:#{@server[:Port]}/map")
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
        doc << '    let map = new ga.Map({'
        doc << '      controls: [],'
        doc << '      target: "map",'
        doc << '      view: new ol.View()'
        doc << '    })'
        doc << "    let layers = [#{layers.map { |layer| "\"#{layer}\"" }.join(', ')}]"
        doc << '    layers.forEach(function(layer) {'
        doc << '      map.addLayer(ga.layer.create(layer))'
        doc << '    })'
        doc << '    let styles = {'
        doc << '      "Point": new ol.style.Style({'
        doc << '        image: new ol.style.Circle({'
        doc << '          fill: new ol.style.Fill({'
        doc << '            color: function() {'
        doc << '              let color = "blueviolet"'
        doc << '              let [r, g, b, a] = ol.color.asArray(color)'
        doc << '              a = 0.3'
        doc << '              return ol.color.asString([r, g, b, a])'
        doc << '            }()'
        doc << '          }),'
        doc << '          radius: 6,'
        doc << '          stroke: new ol.style.Stroke({'
        doc << '            color: "blueviolet",'
        doc << '            width: 1.5'
        doc << '          })'
        doc << '        })'
        doc << '      }),'
        doc << '      "LineString": new ol.style.Style({'
        doc << '        stroke: new ol.style.Stroke({'
        doc << '          color: "blueviolet",'
        doc << '          width: 3'
        doc << '        })'
        doc << '      }),'
        doc << '      "MultiLineString": new ol.style.Style({'
        doc << '        stroke: new ol.style.Stroke({'
        doc << '          color: "blueviolet",'
        doc << '          width: 3'
        doc << '        })'
        doc << '      })'
        doc << '    }'
        doc << "    let files = [#{files.map { |file| "\"#{file}\"" }.join(', ')}]"
        doc << '    let vectors = files.map(function(file) {'
        doc << '      return new ol.layer.Vector({'
        doc << '        source: new ol.source.Vector({'
        doc << '          format: function() {'
        doc << '            if (file.endsWith(".gpx")) {'
        doc << '              return new ol.format.GPX()'
        doc << '            } else if (file.endsWith(".kml")) {'
        doc << '              return new ol.format.KML({'
        doc << '                extractStyles: false'
        doc << '              })'
        doc << '            } else {'
        doc << '              return null'
        doc << '            }'
        doc << '          }(),'
        doc << '          url: file'
        doc << '        }),'
        doc << '        style: function(feature) {'
        doc << '          return styles[feature.getGeometry().getType()]'
        doc << '        }'
        doc << '      })'
        doc << '    })'
        doc << '    vectors.forEach(function(vector) {'
        doc << '      map.addLayer(vector)'
        doc << '      vector.getSource().on("change", function(evt) {'
        doc << '        let extent = ol.extent.createEmpty()'
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
