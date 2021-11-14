version="6.2.1"

echo "Downloading version and release notes"
curl https://docs.confluent.io/$version/release-notes/index.html -O -J -L
curl https://docs.confluent.io/$version/release-notes/changelog.html -O -J -L
echo "Webpages and further documentation are available at: https://docs.confluent.io/$version/release-notes/index.html and https://docs.confluent.io/$version/release-notes/changelog.html" >> Links.txt
echo "Downloading targz of version"
wget -r -np -nH -R index.html -N https://packages.confluent.io/archive/${version:0:3}/confluent-${version:0:5}.tar.gz

echo "Downloading rpms and debs"
wget -r -np -nH -R index.html -N https://packages.confluent.io/rpm/${version:0:3}/
wget -r -np -nH -R index.html -N https://packages.confluent.io/deb/${version:0:3}/


echo "Downloading connectors"
declare -a resourceURLs=()

while IFS= read -r line; do
    resourceURLs+=( "$line" )
done < <(curl -s "https://api.hub.confluent.io/api/plugins/?page=5" | jq -r .[].archive.url )

for i in "${resourceURLs[@]}"
do
   wget -P connectors/ -N $i
done

echo "Pulling Jolokia and JMX"
curl http://search.maven.org/remotecontent?filepath=org/jolokia/jolokia-jvm/1.6.2/jolokia-jvm-1.6.2-agent.jar -OJL
curl https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.12.0/jmx_prometheus_javaagent-0.12.0.jar -OJL
mkdir monitoringJARs/
mv *.jar monitoringJARs/

echo "Pulling Monitoring Samples"
wget https://github.com/confluentinc/jmx-monitoring-stacks/archive/refs/heads/6.1.0-post.zip
unzip 6.1.0-post.zip
mv jmx-monitoring-stacks-6.1.0-post monitoringSamples
rm 6.1.0-post.zip
