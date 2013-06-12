#!/bin/bash
set -e

servicemix_version="4.5.0"

product="servicemix"
package_version="${servicemix_version}-0"
package="opensquare-${product}_${package_version}_all.deb"

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

echo "Downloading Servicemix tar checksum"
wget ${md5_url}
echo "Downloading Servicemix tar from apache.org"
wget ${tar_url}

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

rm -rf `find debian -name ".svn"`
sed -i "s/\YEAR/`date +%Y`/g" debian/DEBIAN/copyright
sed -i "s/\package_version/${package_version}/g" debian/DEBIAN/control
chmod -R 0755 debian/DEBIAN

dpkg-deb --build debian $package || { echo "Failed to build the debian package"; exit 1; } 
