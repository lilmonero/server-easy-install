####################################################################
# Vars
####################################################################
echo "redhat functions were loaded"
apache_conf='/etc/httpd/conf/httpd.conf'

# Recommended to CENTOS 
userProfile='export PS1="\[\e[0;36m\]\u\[\e[1;35m\]@\H \[\033[0;36m\] \w\[\e[0m\]$ "'
rootProfile='export PS1="\[\e[1;31m\]\u\[\e[1;35m\]@\H \[\033[0;36m\] \w\[\e[0m\]$ "'

# Recommended to REDHAT
userProfile='export PS1="\[\e[0;36m\]\u\[\e[1;31m\]@\H \[\033[0;36m\] \w\[\e[0m\]$ "'
rootProfile='export PS1="\[\e[1;31m\]\u\[\e[1;31m\]@\H \[\033[0;36m\] \w\[\e[0m\]$ "'
####################################################################
# Create USER
####################################################################
createUser(){
	if [ ! `whoami` = "root" ]; then 
		echo -e "$red Error: You must to be ROOT user to run this script $endColor"
		return
	fi
	echo -e "$cyan============================ Creating a user $user... =============================$endColor"

	test_user=`id -u $user`;

	if [ "$test_user" = "550" ]; then 
		echo -e "$cyan##### REMOVING PREVIUOS USER ENTRY #####$endColor"
		userdel -r $user
	fi

	echo -e "$cyan##### Add user $user #####$endColor"
	adduser $user -d /home/$user -u 550 -G wheel
	echo "$passwd" | passwd --stdin $user

	echo -e "$cyan##### Add wheel group to sudo #####$endColor"
	sed '/^#.*%wheel\tALL=(ALL)\tALL.*/ s/^#//' /etc/sudoers > tmp
	cat tmp > /etc/sudoers
	echo -e "$cyan==================== User $user created successfully ====================$endColor"
}
####################################################################
# Profile USER
####################################################################
profileUser(){
	echo $userProfile > tmp
	cat tmp >> /home/$user/.bash_profile
	source /home/$user/.bash_profile
	echo -e "$cyan==================== Bash Profile to User $user created ====================$endColor"
	echo $rootProfile > tmp
	cat tmp >> /root/.bash_profile
	source /root/.bash_profile
	echo -e "$cyan==================== Bash Profile to User root created ====================$endColor"
}
####################################################################
# Update and Install Apache, PHP, MySQL, Django, Subversion, TRAC
####################################################################
updateInstall(){
	echo -e "$cyan======= Updating and Installing Apache, PHP, MySQL, Django, Subversion, TRAC ======$endColor"

	echo -e "$cyan##### Updating Operating System... #####$endColor" 
	yum clean all
	yum -y update
	echo -e "$cyan================ System Updated successfully ================$endColor"

	yum -y install httpd mod_ssl 
	yum -y install mysql mysql-server 
	yum -y install php php-cli php-common php-mysql php-mcrypt php-mhash php-mbstring php-gd
	yum -y install python-setuptools MySQL-python mod_python Django
	yum -y install subversion mod_dav_svn

	echo -e "$cyan#####    Starting apache & mysql at boot time   #####$endColor"
	sudo /sbin/chkconfig httpd on
	sudo /sbin/chkconfig mysqld on

	echo -e "$cyan##### Trac Install #####$endColor"  
	sudo easy_install Trac

	echo -e "$cyan##### Trac Plugins Install #####$endColor" 
	easy_install TracAccountManager TracProjectMenu
	svn co http://recurser.com/svn/ganttcalendar/trunk/ ganttcalendar
	cd ganttcalendar
	python setup.py bdist_egg
	easy_install dist/TracGanttCalendarPlugin-0.1-py2.4.egg
	echo -e "$cyan================ Packages Installed successfully ================$endColor"
}
####################################################################
# Create VirtualHosts
####################################################################
CreateVirtualHosts(){
	echo -e "$cyan============================= Creating VirtualHosts ================================$endColor"
	
	echo -e "$cyan#####    Reset Folders @ Apache  #####$endColor"
	rm -rf /var/www/svn /var/www/trac /var/www/html /var/www/logs
	rm -rf /etc/httpd/conf.d/0*
	mkdir -p /var/www/svn /var/www/trac /var/www/html /var/www/logs



	echo -e "$cyan=============================== Folders permission ==================================$endColor"
	chown -R apache:apache /var/www/trac/ /var/www/svn/ /var/www/html/ /var/www/logs/ /var/www/phpmyadmin/
	chmod -R 755 /var/www/trac/ /var/www/svn/ /var/www/html/ /var/www/logs/ /var/www/phpmyadmin/

	echo -e "$cyan=============================== HTTPD Restart ==================================$endColor"
	sudo /etc/init.d/httpd start 
}
