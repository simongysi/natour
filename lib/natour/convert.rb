require 'fileutils'
require 'pathname'
require 'asciidoctor'
require 'asciidoctor-pdf'
require 'vips'

module Natour
  module_function

  def convert(filename, out_dir: nil, out_file: nil, overwrite: false,
              backend: 'pdf', draft: false, draft_backend: nil, image_maxdim: 16000)
    backend = if draft
                draft_backend || backend
              else
                backend
              end

    doc = Asciidoctor.load_file(
      filename,
      backend: backend,
      safe: :unsafe,
      standalone: true,
      attributes: {
        'pdf-theme' => 'natour',
        'pdf-themesdir' => "#{__dir__}/data/themes",
        'pdf-fontsdir' => "#{__dir__}/data/fonts"
      }
    )

    dir = Pathname(filename).dirname
    out_dir = Pathname(out_dir || dir)
    out_file = Pathname(
      out_file || "#{doc.attr('docname')}#{doc.attr('outfilesuffix')}"
    )

    if draft
      doc.find_by(context: :image).each do |node|
        target = node.attr('target')
        image = Image.load_file(dir.join(target).to_s)
        node.title = "#{node.title} [#{[target, image.date_time].compact.join('|')}]"
      end
    end

    if backend == 'pdf'
      Dir.mktmpdir do |tmp_dir|
        tmp_dir = Pathname(tmp_dir)

        title_logo_image = doc.attr('title-logo-image')
        if title_logo_image
          target = title_logo_image[/^image:{1,2}(.*?)\[(.*?)\]$/, 1]
          image = Image.load_file(dir.join(target).to_s).autorotate.shrink_to(image_maxdim)
          new_target = tmp_dir.join("title_logo_image_#{Pathname(target).basename}").to_s
          image.save_as(new_target)
          doc.set_attr('title-logo-image', title_logo_image.gsub(target, new_target))
        end

        doc.find_by(context: :image).each.with_index do |node, index|
          target = node.attr('target')
          image = Image.load_file(dir.join(target).to_s).autorotate.shrink_to(image_maxdim)
          new_target = tmp_dir.join("image#{index}_#{Pathname(target).basename}").to_s
          image.save_as(new_target)
          node.set_attr('target', new_target)
        end

        FileUtils.mkdir_p(out_dir)
        mode = File::WRONLY | File::CREAT | File::TRUNC | File::BINARY
        mode |= File::EXCL unless overwrite
        File.open(out_dir.join(out_file), mode) do |file|
          doc.write(doc.convert, file)
        end
      end
    else
      FileUtils.mkdir_p(out_dir)
      mode = File::WRONLY | File::CREAT | File::TRUNC
      mode |= File::EXCL unless overwrite
      File.open(out_dir.join(out_file), mode) do |file|
        doc.write(doc.convert, file)
      end
    end
  end
end
