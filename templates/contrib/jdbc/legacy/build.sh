#!/bin/bash

set -ueo pipefail

if [ -n "${DEBUG:-}" ] ; then
    set -x
fi

function print_help() {
    echo "----------------------------------------------------------"
    echo "Builds and pushes JDBC Driver images to a docker registry. This has to be executed from a folder containing a Dockerfile"
    echo ""
    echo "Usage: "
    echo "   ../build.sh [--registry=myregistry.example.com:5000] [--namespace=mynamespace] [--artifact-repo=https://myrepo.example.com/maven/public]"
    echo "Options:"
    echo "   Available driver images to build: db2, mariadb, mssql, mysql, oracle, postgresql, sybase"
    echo "   --registry         Specifies the docker registry to use for tagging and pushing. Defaults to docker-registry.default.svc:5000"
    echo "   --namespace        Specifies the docker namespace to use for tagging and pushing. Defaults to openshift"
    echo "   --artifact-repo    Specifies the Maven repository where the jdbc drivers are available. Oracle does not have a default value"
    echo "   --image-tag        Specifies the tag to use when building the image. Defaults to 1.0"
}

while (($#))
do
    case $1 in
        --registry=*)
            registry=${1#*=}
        ;;
        --namespace=*)
            namespace=${1#*=}
        ;;
        --artifact-repo=*)
            artifact_repo=${1#*=}
        ;;
        --image-tag=*)
            image_tag=${1#*=}
        ;;
        -h)
            print_help
            exit 0
        ;;
        --help)
            print_help
            exit 0
        ;;
    esac
shift
done

if [[ ! -f Dockerfile ]]
then
    echo "Error: No Dockerfile found"
    print_help
    exit 1
fi

current_dir=${PWD##*/}
driver=$(echo $current_dir | cut -d '-' -f 1)
image_tag=${image_tag:-1.0}

registry=${registry:-docker-registry.default.svc:5000}/${namespace:-openshift}

function build() {
    local driver=$1
    local tag=$2
    local artifact_repo=${3:-}
    echo Building $driver
    if [[ -n $artifact_repo ]]
    then
        docker build -f $current_dir/Dockerfile . -t $tag --build-arg ARTIFACT_MVN_REPO=$artifact_repo
    else
        docker build -f $current_dir/Dockerfile . -t $tag
    fi
    echo Finished bulding $tag
}

function push() {
    local tag=$1
    echo Pushing $tag
    docker push $tag
    echo Pushed $tag
}

function create_build() {
    local driver=$1
    local version=$2
    oc new-build \
        --name rhpam-kieserver-$driver-openshift \
        --image-stream=openshift/rhpam73-kieserver-openshift:$image_tag \
        --source-image=$registry/$driver-driver-image:$version \
        --source-image-path=/extensions:$driver-driver/ \
        --to=rhpam-kieserver-$driver-openshift:$image_tag \
        -e CUSTOM_INSTALL_DIRECTORIES=$driver-driver/extensions
}

# docker_login

pushd ..

image_name=$driver-driver-image
version=$(grep version $current_dir/Dockerfile | awk -F"=" '{print $2}' | sed 's/"//g')
tag=$registry/$image_name:$version
build $image_name $tag ${artifact_repo:-}
push $tag
create_build $driver $version

popd
