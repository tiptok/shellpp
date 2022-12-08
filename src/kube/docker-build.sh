#!/bin/bash
#
# Usage: ./docker-build.sh </dir/to/dockerfile> <remote-registry-prefix> <version>
#
# Example: ./docker-build.sh node-agent-service 10.0.1.16:5000/inaetics

dir=$1
prefix=$2
version=$3

# remote registries should adhere to the pattern "<host>:<port>(</path>)?"
regex="^[[:graph:]]+\:[[:digit:]]+(/[[:graph:]]+)?/?$"

if [ "$dir" == "" ] ||
   [ ! -d "$dir" ] ||
   [ "$prefix" == "" ]   ; then #|| [[ $prefix =~ $regex ]]

    echo "Usage:
  $0 <docker-dir> <registry-prefix> [<tag name>]
where
    <docker-dir> is the directory containing the dockerfile to build;
    <registry-prefix> is the prefix of the *remote* docker registry, for example '10.0.1.1:5000' 'tiptok'
    <tag name> is optional and defaults to the directory name (the first argument).
"
        exit 1
fi   


echo "$dir $prefix $version"

app="$(basename $dir)"
repository=$(echo "$prefix/$app:$version" | sed -r 's#/+#/#g')
DOCKER_BUILD_ARGS="docker build"

found=$(docker images | grep $prefix | awk '{printf "%s:%s\n", $1, $2}' | grep $repository) 
echo "repository: $repository"
echo "local: $found"
if [ "$found" == "$repository" ] ;then
    echo "container exists exit 0"
    exit 0
fi

pushd "$dir"
    ${DOCKER_BUILD_ARGS}  -t "${repository}" -t "$prefix/$app:latest" .
popd
docker push $repository

# id=$(echo $(docker build --quiet=true $dir 2>/dev/null) | awk '{print $NF}')
# docker tag $id $dir
# docker tag $id "$remote_name"

