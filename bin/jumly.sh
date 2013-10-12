#!/usr/bin/env bash
script_path=$1
format=$2
encoding=$3

if [ -z "$script_path" ]; then
  cat<<EOF
usage: `basename $0` <script-path> [format] [encoding]
  script-path    ./meet-you.jm
  format         png|jpg
  encoding       image | base64 | html

ex)
  `basename $0` meet-you.jm jpg
  `basename $0` meet-you.jm png base64

EOF
  exit
fi

cwd=$(dirname `\ls -l $0 | awk '{if ($11) {print $11} else {print $9}}'`)/..
cd $cwd

npm_bin=$cwd/node_modules/.bin
$npm_bin/phantomjs \
  $cwd/lib/ext/img-conv/img-conv.coffee \
  $script_path \
  $format \
  $encoding
