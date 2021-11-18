# expect ImageMagick

convert -size 25x11  canvas:red   -gravity center -fill white -draw "circle 012,005 012,010" -fill black -draw "text 0,0 LL" images/r1land.jpg
convert -size 90x45  canvas:blue  -gravity center -fill white -draw "circle 045,022 045,044" -fill black -draw "text 0,0 LM" images/b1land.jpg
convert -size 181x89 canvas:green -gravity center -fill white -draw "circle 090,044 090,088" -fill black -draw "text 0,0 LH" images/g1land.jpg
convert -size 11x25  canvas:red   -gravity center -fill white -draw "circle 005,012 010,012" -fill black -draw "text 0,0 PL" images/r1port.jpg
convert -size 44x89  canvas:green -gravity center -fill white -draw "circle 022,044 044,044" -fill black -draw "text 0,0 PM" images/g1port.jpg
convert -size 91x179 canvas:blue  -gravity center -fill white -draw "circle 045,089 090,089" -fill black -draw "text 0,0 PH" images/b1port.jpg
