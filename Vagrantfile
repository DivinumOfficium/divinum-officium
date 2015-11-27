# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get -y update
    sudo apt-get -y install apache2 libapache2-mod-perl2 php5
    sudo a2enmod cgi
    sudo rm /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-available/000-default.conf
    sudo cp /vagrant/divinum-officium.conf /etc/apache2/sites-available/
    sudo ln -s /etc/apache2/sites-available/divinum-officium.conf /etc/apache2/sites-enabled/
	sudo service apache2 restart
  SHELL
end