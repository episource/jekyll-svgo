module Jekyll
    module Svgo

        class SvgoFile < Jekyll::StaticFile
            @@mtimes = {}

            # Returns a new hash with the file specific svgo configuration.
            def configure()
                origConfig = @site.config['svgo'] || {}
                generatedConfig = origConfig.clone
                generatedConfig.delete_if {|k, v| k.end_with?('.svg')}

                if origConfig.key?(@name)
                    generatedConfig.merge!(origConfig[@name])
                end

                generatedConfig
            end

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
                    config = configure()

                    if (config['multipass'] == 'safe')
                        precision = config['floatPrecision']
                        config['multipass'] = true
                        config['floatPrecision'] = 6

                        content = SvgoWrapper::Svgo.new(config).optimize_file(path)

                        config['multipass'] = false
                        config['floatPrecision'] = precision
                    else
                        content = File.read(path)
                    end

                    content = SvgoWrapper::Svgo.new(config).optimize(content)
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