#!/bin/sh
# Resize all PNG images from large/ and extracts/ into small/,
# preserving 8-bit density
#
# Requires: convert (from ImageMagick)
#
cd "$(dirname "$0")"

resize()
{
  for folder in ??-*
  do
    echo "Create folder small/$folder..."
    mkdir -p "../small/$folder"
  done

  for file in ??-*/*.png
  do
    echo "Create file small/$file..."
    convert "$file" -resize 50% -depth 8 "../small/$file"
  done
}

cd large/
resize

cd ../extracts
resize

echo "Done."
