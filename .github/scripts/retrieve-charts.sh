#!/bin/bash -x

curl https://api.github.com/repos/istio/istio/releases | jq '.[].tag_name' -r > versions-new
diff .versions versions-new | grep '>' | sed 's/> //g' > diff-versions

for version in $(cat diff-versions); do
  git clone --depth 1 --branch "$version" https://github.com/istio/istio "$version"
  for chart in $(cat .charts); do
    helm package "$version"/$chart -version $version
  done
done

rm diff-versions
mv versions-new .versions

helm repo index

