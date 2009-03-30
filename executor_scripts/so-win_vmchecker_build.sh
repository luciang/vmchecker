#!/bin/sh

#runs inside vm

home=$1
winbuildenv="\"C:\Program Files\Microsoft SDKs\Windows\v6.1\Bin\SetEnv.Cmd\""

cd $home

get_vm_ip()
{
	echo "Adresa IP a masinii virtuale este:"
	ipconfig |grep "IP Address"|cut -d ':' -f 2 |cut -d " " -f 2|head -n 1 2>&1
}


install_job()
{
	echo "unpacking ..."
	cp archive.zip file.zip 2>&1
	unzip -o file.zip 2>&1
	return $?
}

build_job()
{
	echo -e "\nchecker: building" 
    export TMP="c:\\cygwin\\tmp"
#	echo "fixing file dates ..."
#	/usr/bin/find . | xargs touch 2>&1
	echo $winbuildenv \&\& nmake build > __checker.bat; cmd /E:ON /V:ON /T:0E /C  __checker.bat  2>&1
	if [ "$?" != 0 ]; then
		echo "checker: building failed"
		return 1       
	fi

	echo "checker: building done"
	return 0
}

install_tests()
{
	unzip -o tests.zip 1>&2
	return $?	
}

build_tests()
{
	if [ -f NMakefile.checker ]; then echo $winbuildenv \&\& nmake build -f NMakefile.checker build-$1 > __checker.bat; cmd /E:ON /V:ON /T:0E /C /c __checker.bat;
       	elif [ -f Makefile.checker ]; then make -f Makefile.checker build-$1;
       	else echo dont know how to build tests;
       	fi  2>&1 
	
	return  0
}

check_job()
{
	get_vm_ip ;

	install_job; err=$?
	if [ $err != 0 ]; then
		return $err
	fi

	install_tests; err=$?
	if [ $err != 0 ]; then
		return $err
	fi

	build_tests "pre"; err=$?
	if [ $err != 0 ]; then
		return $err
	fi

	build_job; err=$?
	if [ $err != 0 ]; then
		return $err
	fi
   
	build_tests "post"; err=$?
	if [ $err != 0 ]; then
		return $err
	fi


	return 0
}

main()
{
    
	# test it
	touch job_build job_errors
	echo 'checker: building' >> job_build
	check_job > job_build 2>job_errors;  err=$?
     
	if [ $err -gt 1 ]; then
		echo "this looks like a checker system error, admins will be notified" >>job_output
	fi

	return $err
}
 
main 
