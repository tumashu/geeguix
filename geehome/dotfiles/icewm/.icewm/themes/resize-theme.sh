cd GeeIcewm
cp *.xpm ../GeeIcewm-Big
for f in max*.xpm min*.xpm restore*.xpm close*.xpm; do convert $f -resize 150% ../GeeIcewm-Big/$f; done