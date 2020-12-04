require 'fileutils'
require 'pathname'
require 'webrick'
require 'concurrent'
require 'ferrum'
require 'uri'

module Natour
  class MapGeoAdmin
    def initialize(port: 0)
      @doc_root = Dir.mktmpdir
      FileUtils.cp_r("#{__dir__}/js", @doc_root)
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

    def save_image(filename, tracks: [], layers: [], size: [1200, 900])
      FileUtils.cp(tracks, @doc_root)
      FileUtils.mkdir_p(Pathname(filename).dirname)
      uri = URI("http://#{@server[:BindAddress]}:#{@server[:Port]}/map")
      uri.query = URI.encode_www_form(
        tracks: tracks.map { |track| Pathname(track).basename }.join(','),
        layers: layers.join(','),
        size: size.map { |dim| dim.is_a?(String) ? dim : "#{dim}px" }.join(',')
      )
      @browser.goto(uri)
      @browser.screenshot(
        path: filename,
        quality: 100,
        selector: '.map'
      )
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

        tracks = request.query.fetch('tracks', '').split(',')
        layers = request.query.fetch('layers', '').split(',')
        layers.unshift('ch.swisstopo.pixelkarte-farbe')

        width, height = request.query.fetch('size', '').split(',')
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
        doc << "    var tracks = [#{tracks.map { |track| "\"#{track}\"" }.join(', ')}]"
        doc << '    tracks = tracks.map(function(track) {'
        doc << '      return new ol.layer.Vector({'
        doc << '        source: new ol.source.Vector({'
        doc << '          format: new ol.format.GPX(),'
        doc << '          url: track'
        doc << '        }),'
        doc << '        style: new ol.style.Style({'
        doc << '          stroke: new ol.style.Stroke({'
        doc << '            color: "blueviolet",'
        doc << '            width: 3'
        doc << '          })'
        doc << '        })'
        doc << '      })'
        doc << '    })'
        doc << '    tracks.forEach(function(track) {'
        doc << '      map.addLayer(track)'
        doc << '      track.getSource().on("change", function(evt) {'
        doc << '        var extent = ol.extent.createEmpty()'
        doc << '        tracks.forEach(function(track) {'
        doc << '          ol.extent.extend(extent, track.getSource().getExtent())'
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
