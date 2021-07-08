version="6.0.0"

echo "Downloading version and release notes"
curl https://docs.confluent.io/$version/release-notes/index.html -O -J -L
curl https://docs.confluent.io/$version/release-notes/changelog.html -O -J -L
echo "Webpages and further documentation are available at: https://docs.confluent.io/$version/release-notes/index.html and https://docs.confluent.io/$version/release-notes/changelog.html" >> Links.txt
echo "Downloading targz of version"
wget -r -np -nH -R index.html -N https://packages.confluent.io/archive/${version:0:3}/

echo "Downloading rpms and debs"
wget -r -np -nH -R index.html -N https://packages.confluent.io/rpm/${version:0:3}/
wget -r -np -nH -R index.html -N https://packages.confluent.io/deb/${version:0:3}/


echo "Downloading connectors"
declare -a resourceURLs=()
declare -a downloadURLs=()
while IFS= read -r line; do
    resourceURLs+=( "$line" )
done < <(curl -s https://api.hub.confluent.io/api/plugins/ | jq -r .[].archive.url )

while IFS= read -r line; do
    resourceURLs+=( "$line" )
done < <(curl -s "https://api.hub.confluent.io/api/plugins/?page=2" | jq -r .[].archive.url )

for i in "${resourceURLs[@]}"
do
   wget -P connectors/ -N $i
done