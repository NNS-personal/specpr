
set -x
cd /usr/src/cmd/specpr
if [ -d $1 ]
then
	cd $1
	if [ -f $2 ]
	then
		cp $2 /usr/spool/uucppublic/specpr.spool
		cd /usr/spool/uucppublic/specpr.spool
		chmod 777 $2
		uucp -nowensby -C -m $2 \
			uhpgvax!~uucp/specpr.updates/bgphp1/$1/$2
		rm $2
	else
		echo "bad file name"
		echo "usage: $0 specpr_directory source_file"
	fi
else
	echo "bad specpr directory name"
	echo "usage: $0 specpr_directory source_file"
fi
