#! /bin/sh


#sym=('🌕' '🌔' '🌓' '🌒' '🌑')
sym=('▁' '▂' '▃' '▄' '▅' '▆' '▇' '█')

br=`xbacklight -get`

len=${#sym[@]}
div=$((100/$len))
max=$(($div * $len))

if (($br >= $max)); then
  idx=$(($len - 1))
else
  idx=$(($br / ${div}))
fi

echo "🔆 ${sym[$idx]}"

