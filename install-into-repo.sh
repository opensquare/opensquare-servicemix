#!/bin/bash
set -e

deb="/usr/share/packages-dev"
rpm="/usr/share/redhat-packages-dev"

cd target
echo "Installing debian packages"
i386="dists/all/main/binary-i386"
amd64="dists/all/main/binary-amd64"
sudo cp *.deb ${deb}/${i386}
sudo cp *.deb ${deb}/${amd64}
cd ${deb}
apt-ftparchive packages ${i386} --db ${i386}/cache | gzip -9c | sudo tee ${i386}/Packages.gz 1>/dev/null
apt-ftparchive packages ${amd64} --db ${amd64}/cache | gzip -9c | sudo tee ${amd64}/Packages.gz 1>/dev/null
cd -


echo "Creating RPM packages"
file="what_owner.txt"
touch $file
owner=`ls -l $file | awk '{print $3":"$4}'`

for debpack in `ls *.deb`
do
    echo "To RPM: " $debpack
    sudo alien --to-rpm --scripts $debpack
    sudo chown -R $owner .
done

sudo cp noarch/*.rpm ${rpm}
cd ..
cd ${rpm}
sudo createrepo .
cd -

