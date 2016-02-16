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