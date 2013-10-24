#!/bin/bash
set -e

servicemix_version="4.5.2"

product="servicemix"
package_version="${servicemix_version}-0"

tar_url="http://archive.apache.org/dist/servicemix/servicemix-4/${servicemix_version}/apache-servicemix-${servicemix_version}.tar.gz"
md5_url="${tar_url}.md5"
tar_file="apache-servicemix-${servicemix_version}.tar.gz"
checksum_file="${tar_file}.md5"

cd "`dirname \"$0\"`"
pwd
target="target"
rm -rf $target
mkdir $target
cp -r debian $target

cd $target

#echo "Downloading Servicemix tar checksum"
wget ${md5_url}
echo "Downloading Servicemix tar from apache.org"
wget ${tar_url}
#cp ../$tar_file .
#cp ../$checksum_file .

# Build correct format checksum file
checksum="`cat ${checksum_file}`"
echo "$checksum  $tar_file" > $checksum_file

echo "Verifying download via MD5 checksum"
md5sum -c $checksum_file

mkdir debian/opt
cd debian/opt
echo "Extracting tar"
tar -xf ../../$tar_file
cd -

function buildPackage {
    altName=$1
    package="opensquare-${product}${altName}_${package_version}_all.deb"
    packageDir="package${altName}"

    cp -r debian $packageDir
    if [ ! -z $altName ]
    then
        mv ${packageDir}/opt/apache-servicemix-${servicemix_version} ${packageDir}/opt/apache-servicemix-${servicemix_version}${altName}
    fi

    # Inject values into package control files
    sed -i "s/\YEAR/`date +%Y`/g" $packageDir/DEBIAN/*
    sed -i "s/\PACKAGE_VERSION/${package_version}/g" $packageDir/DEBIAN/*
    sed -i "s/\SERVICEMIX_VERSION/${servicemix_version}/g" $packageDir/DEBIAN/*
    sed -i "s/\ALT/${altName}/g" $packageDir/DEBIAN/*

    chmod -R 0755 $packageDir/DEBIAN

    dpkg-deb --build $packageDir $package || { echo "Failed to build the debian package in $packageDir"; exit 1; }
}

buildPackage ""
buildPackage "-worker"
