# jekyll-svgo

A Jekyll plugin that automatically optimizes/minifies svg images using [svgo](https://github.com/svg/svgo).

## Setup

    cd YOUR_JEKYLL_DIR/_plugins && git submodule add https://github.com/episource/jekyll-svgo.git

## Configure

Configure svgo by adding a svgo node to your _config.yml. All configuration options valid inside a [svgo configuration file](https://github.com/svg/svgo/blob/master/docs/how-it-works/en.md) are supported.

    svgo:
      multipass: false
      floatPrecision: 2 
      plugins:
        - cleanupIDs: false

In addition to svgo's default options, the jekyll plugin adds `multipass: safe`: In safe multipass mode, every image will
be processed twice. The first time with `multipass: true` and a reasonably high `floatPrecision` (currently 6). The
second time with `multipass: false` and the `floatPrecision` configured in _config.yml. This prevents visible artifacts
due to repeated rounding.

### File specific configuration

The configuration can also be adjusted on a file to file basis. The global configuration is then merged with the file
specific configuration: The final configuration consists of all (top-level) configuration entries of the global
configuration plus all (top-level) configuration entries of the file specific configuration with all (top-level) entries
defined twice overwritten by the file specific configuration.

    svgo:
      multipass: false
      floatPrecision: 2 
      plugins:
        - cleanupIDs: false
      my_file.svg:
        floatPrecision: 1
        plugins:
          - removeRasterImages: true
      
      # effective configuration for my_file.svg:
      #   multipass: false
      #   floatPrecision: 1
      #   plugins:
      #     - removeRasterImages:true