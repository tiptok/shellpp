#!/bin/bash

# exculte follow example case
# ./build_push_update_images.sh 1.17.0 --prefix=istio
# ref: github.com/istio/samples/bookinfo

set -o errexit # 当命令返回一个非零退出状态(失败)时退出。读取初始化文件时不设置

display_usage() {
    echo
    echo "USAGE: ./build_push_update_images.sh <version> [-h|--help] [--prefix=value] [--scan-images] [--multiarch-images]"
    echo "	version: Version of the sample app images (Required)"
    echo "	-h|--help: Prints usage information"
    echo "	--prefix: Use the value as the prefix for image names. By default, 'istio' is used"
    echo -e "	--scan-images: Enable security vulnerability scans for docker images \n\t\t\trelated to bookinfo sample apps. By default, this feature \n\t\t\tis disabled."
    echo -e "   --multiarch-images : Enables building and pushing multiarch docker images \n\t\t\trelated to bookinfo sample apps. By default, this feature \n\t\t\tis disabled."
}

# Print usage information for help
if [[ "$1" == "-h" || "$1" == "--help" ]];then
        display_usage
        exit 0
fi        

if [[ -z "$1" ]] ; then
    echo "Missing version parameter"
          display_usage
          exit 1
else 
    VERSION="$1"
    shift # 每次执行 shift 时参数的数量都会减少，最终变为零
fi              

# Process the input arguments. By default, image scanning is disabled.
PREFIX=istio
ENABLE_IMAGE_SCAN=false
ENABLE_MULTIARCH_IMAGES=false

echo "$@ \$0 = $0"  # 参数列表
echo "$#"  # 参数数量

for i in "$@"
do
  case "$i" in
    --prefix=* )
       PREFIX="${i#--prefix=}" ;;
    --scan-images )
       ENABLE_IMAGE_SCAN=true ;;
    --multiarch-images )
       ENABLE_MULTIARCH_IMAGES=true ;;
    -h|--help )
	     echo
		   echo "Build the docker images for bookinfo sample apps, push them to docker hub and update the yaml files."
		   display_usage
		   exit 0 ;;  
    * )
       echo "Unknown argument: $i"
	     display_usage
	     exit 1 ;;              
  esac
done

ENABLE_MULTIARCH_IMAGES="${ENABLE_MULTIARCH_IMAGES}" ./build-services.sh  "aa"
echo "Version ${VERSION}"
echo "Prefix ${PREFIX}"
if [[ "$ENABLE_MULTIARCH_IMAGES" == "false" ]]; then
  for v in ${VERSION} "latest"
  do
    # docker images -f reference="istio/examples-bookinfo*:1.17.0"
    IMAGES+=$(docker images -f reference="${PREFIX}/examples-bookinfo*:$v" --format "{{.Repository}}:$v")
    IMAGES+=" "
  done

  if [[ "${IMAGES}" =~ ^\ +$  ]]  ; then # =~ 正则匹配
    echo "Found no images matching prefix \"${PREFIX}/examples-bookinfo\"."
    echo "Try running the script without specifying the image registry in --prefix (e.g. --prefix=/foo instead of --prefix=docker.io/foo)."
    exit 1
  fi
fi 

echo "${IMAGES}"


for IMAGE in ${IMAGES};
do
  if [[ "$ENABLE_MULTIARCH_IMAGES" == "false" ]]; then
    echo "Pusing: ${IMAGE}"
    # docker push "${IMAGE}"
  fi

done