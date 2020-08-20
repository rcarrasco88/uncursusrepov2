#!/usr/bin/env bash

echo "Updateting Repo..."

echo "Cleaning Up Prevouis Build..."
rm -rf tmpbingner
rm -rf dists
echo "Done"

mkdir tmpbingner

wget -q -O tmpbingner/Packages https://apt.bingner.com/dists/ios/1443.00/main/binary-iphoneos-arm/Packages

for deb in $(grep "com.ex.substitute_0.1.15_iphoneos-arm" tmpbingner/Packages | cut -c 11-); do
	wget -q -nc -P tmpbingner https://apt.bingner.com/${deb}
done
rm tmpbingner/Packages

for dist in iphoneos-arm64/uncursus; do
	arch=iphoneos-arm
	binary=binary-${arch}
	mkdir -p dists/${dist}/main/${binary} 
	rm -f dists/${dist}/{Release{,.gpg},main/${binary}/{Packages{,.xz,.zst},Release{,.gpg}}}
	cp -a CydiaIcon*.png dists/${dist}
	
	apt-ftparchive packages pool/main/iphoneos-arm64 > \
		dists/${dist}/main/${binary}/Packages 2>/dev/null

		apt-ftparchive packages ./tmpbingner >> \
			dists/${dist}/main/${binary}/Packages 2>/dev/null
	
	sed -i 's+./tmpbingner+https://apt.bingner.com/debs/1443.00/.+g' dists/${dist}/main/${binary}/Packages
    
    echo "Packing up The Package File..."
	xz -c9 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.xz
	zstd -q -c19 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.zst
    gzip -c9 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.gz
    bzip2 -c9 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.bz2
    echo "Done"

	apt-ftparchive release -c config/${arch}-basic.conf dists/${dist}/main/${binary} > \
		dists/${dist}/main/${binary}/Release 2>/dev/null
	apt-ftparchive release -c config/$(echo "${dist}" | cut -f1 -d '/').conf dists/${dist} > dists/${dist}/Release 2>/dev/null
	
    echo "Updateting GPGP Key..."
    
    gpg -abs -u 8A61B55ECE513045A1787EAEC07D48D85553E909 -o dists/${dist}/Release.gpg dists/${dist}/Release

    echo "All Done!"

done

#rm -rf tmp{bingner,odyssey,zebra,installer}/
