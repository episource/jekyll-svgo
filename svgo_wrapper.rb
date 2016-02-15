require 'stringio'
require 'tempfile'
require 'yaml'

module SvgoWrapper

    class Error < StandardError; end

    # A thin wrapper around the svgo executable
    class Svgo
        attr_accessor :config

        def initialize(config={})
            @config = config
        end

        # Optimize SVG image data with svgo
        #   +io+ a svg image as string or open IO object
        #
        # Returns the optimized svg as string or yields an IO object to a block.
        def optimize(io)
            tempfileSvg = Tempfile.new('SvgoWrapper.Svg')
            if io.respond_to? :read
                while buffer = io.read(4096) do
                    tempfileSvg.write(buffer)
                end
            else
                tempfileSvg.write(io.to_s)
            end
            tempfileSvg.flush

            begin
                result = optimize_file(tempfileSvg.path)
            rescue Exception => e
                raise e
            ensure
                tempfileSvg.close!
            end

            yield(StringIO.new(result)) if block_given?
            result
        end

        # Optimize SVG image file with svgo
        #   +file+ path to a svg image file
        #
        # Returns the optimized svg as string or yields an IO object to a block.
        def optimize_file(file)
            tempfileConfig = Tempfile.new('SvgoWrapper.Config')
            tempfileConfig.write(@config.to_yaml)
            tempfileConfig.flush

            begin
                result = `svgo --input='#{file}' --output='-' --config='#{tempfileConfig.path}' 2>&1`
            rescue Exception => e
                raise Error, "svgo failed: #{e} :: #{result}"
            ensure
                tempfileConfig.close!
            end

            if (result.downcase().start_with?('error'))
                raise Error, "svgo failed: #{result}"
            end

            yield(StringIO.new(result)) if block_given?
            result
        end
    end
end
