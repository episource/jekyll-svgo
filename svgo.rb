module Jekyll
    module Svgo

        class SvgoFile < Jekyll::StaticFile

            # Optimize SVG
            #   +dest+ is the String path to the destination dir
            #
            # Returns false if the file was not modified since last time (no-op).
            def write(dest)
                dest_path = File.join(dest, @dir, @name)

                return false if File.exist? dest and !modified?
                @@mtimes[path] = mtime

                FileUtils.mkdir_p(File.dirname(dest_path))
                begin
                    inConf = @site.config['svgo'] || {}
                    generatedConf = inConf.clone

                    if (generatedConf['multipass'] == 'safe')
                        generatedConf['multipass'] = true
                        generatedConf['floatPrecision'] = 6

                        content = SvgoWrapper::Svgo.new(generatedConf).optimize_file(path)

                        generatedConf['multipass'] = false
                        generatedConf['floatPrecision'] = inConf['floatPrecision']
                    else
                        content = File.read(path)
                    end

                    content = SvgoWrapper::Svgo.new(generatedConf).optimize(content)
                    File.open(dest_path, 'w') do |f|
                        f.write(content)
                    end
                rescue => e
                    STDERR.puts e.message
                end

                true
            end

        end

    end
end


Jekyll::Hooks.register(:site, :post_render) do |site|
    # Replace StaticFile instances representing svg files with SgoFile instances.
     site.static_files.clone.each do |sf|
        if sf.kind_of?(Jekyll::StaticFile) && sf.path =~ /\.svg$/ && !(sf.path =~ /\.min\.svg$/)
            site.static_files.delete(sf)
            name = File.basename(sf.path)
            dest = File.dirname(sf.path).sub(site.source, '')
            site.static_files << Jekyll::Svgo::SvgoFile.new(site, site.source, dest, name)
        end
    end
end