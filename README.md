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
