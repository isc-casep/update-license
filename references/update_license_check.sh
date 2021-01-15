#!/bin/sh
licensekeydir=`dirname "$0"`
instancecontrolcmd=iris
instancesessioncmd=irissession
instanceowner=irisowner
licensekeyfilename=iris.key

update_license_generic() {
for i in `$instancecontrolcmd qlist | cut -d^ -f2` ; do
echo $i;
CustomerName=`sed -n '/^\[License\]/,/^\[/p' $i/mgr/$licensekeyfilename | grep "^CustomerName=" | cut -d'=' -f 2`;
OrderNumber=`sed -n '/^\[License\]/,/^\[/p' $i/mgr/$licensekeyfilename | grep "^OrderNumber=" | cut -d'=' -f 2`;
ExpirationDate=`sed -n '/^\[License\]/,/^\[/p' $i/mgr/$licensekeyfilename | grep "^ExpirationDate="| cut -d'=' -f 2`;
ExpDate=${ExpirationDate:6:4}${ExpirationDate:0:2}${ExpirationDate:3:2};


echo "Existing $licensekeyfilename";
sed -n '/^\[License\]/,/^\[/p' $i/mgr/$licensekeyfilename | head -n -1
echo "=======";
echo "CustomerName="$CustomerName;
echo "OrderNumber="$OrderNumber;
echo "ExpirationDate="$ExpirationDate;
if [ -f "$licensekeydir/$licensekeyfilename" ]; then
	newOrderNumber=`sed -n '/^\[License\]/,/^\[/p' $licensekeydir/$licensekeyfilename | grep "^OrderNumber=" | cut -d'=' -f 2`;
	newExpirationDate=`sed -n '/^\[License\]/,/^\[/p' $licensekeydir/$licensekeyfilename | grep "^ExpirationDate="| cut -d'=' -f 2`;
	newCustomerName=`sed -n '/^\[License\]/,/^\[/p' $licensekeydir/$licensekeyfilename | grep "^CustomerName="| cut -d'=' -f 2`;
	echo "Replace with";
	echo "OrderNumber="$newOrderNumber;
	echo "ExpirationDate="$newExpirationDate;
	echo "CustomerName="$newCustomerName;
fi
# OrderNumber check is only for ISC TrakCare Development OrderNumber=54321 comment out for other keys.
if [ "$OrderNumber" !=  "$newOrderNumber" ]; then
	echo "aborting: OrderNumber mismatch - $licensekeyfilename has NOT been updated for this instance";
	continue;
fi
if [ "$ExpirationDate" =  "$newExpirationDate" ]; then
	echo "aborting: ExpirationDate matches replacement - $licensekeyfilename has NOT been updated for this instance";
	continue;
fi
if [ "$CustomerName" !=  "$newCustomerName" ]; then
	echo "aborting: CustomerName mismatch - $licensekeyfilename has NOT been updated for this instance";
	continue;
fi

if [ -f "$i/mgr/"$licensekeyfilename"_SAVE_ExpirationDate_$ExpDate" ]; then
	sudo mv -v $i/mgr/"$licensekeyfilename"_SAVE_ExpirationDate_$ExpDate $i/mgr/"$licensekeyfilename"_SAVE_ExpirationDate_$ExpDate_$RANDOM;
fi
if [ -f "$licensekeydir/$licensekeyfilename" ]; then
	sudo cp -v $i/mgr/$licensekeyfilename $i/mgr/"$licensekeyfilename"_SAVE_ExpirationDate_$ExpDate;
	sudo cp -v $licensekeydir/$licensekeyfilename $i/mgr/$licensekeyfilename;
else
	echo "missing replacement license key : $licensekeydir/$licensekeyfilename"
	continue;
fi
done

echo "##Class(%SYSTEM.License).Upgrade()"
for i in `$instancecontrolcmd qlist | cut -d^ -f1` ; do echo $i; su - -c "$instancesessioncmd $i -U%SYS '##Class(%SYSTEM.License).Upgrade()'" $instanceowner; done
for i in `$instancecontrolcmd qlist | cut -d^ -f1` ; do echo $i; echo "su - -c \"$instancesessioncmd $i -U\"%SYS\"" $instanceowner;echo "zn \"%SYS\""; echo "d ##Class(%SYSTEM.License).Upgrade()";echo "h"; done

}

update_license_cache () {
licensekeydir=`dirname "$0"`
instancecontrolcmd=ccontrol
instancesessioncmd=csession
instanceowner=cachesys
licensekeyfilename=cache.key
if command -v $instancecontrolcmd &> /dev/null
then
update_license_generic
fi

}

update_license_IRIS () {
licensekeydir=`dirname "$0"`
instancecontrolcmd=iris
instancesessioncmd=irissession
instanceowner=irisowner
licensekeyfilename=iris.key
if command -v $instancecontrolcmd &> /dev/null
then
update_license_generic
fi
}



update_license_cache
update_license_IRIS
