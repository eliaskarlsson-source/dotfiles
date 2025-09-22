for page in {1..10}; do
    curl -s "https://wallhaven.cc/api/v1/search?sorting=views&page=$page" \
    | jq -r '.data[].path' \
    | xargs -n 1 -P 4 wget -nc -P /home/elias/Pictures/Wallpapers
done