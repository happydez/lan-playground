Vagrant.configure("2") do |config|

  config.vm.define "controlnode" do |controlnode|
    controlnode.vm.box = "ubuntu/jammy64"
    controlnode.vm.hostname = "controlnode"
    controlnode.vm.network "private_network", ip: "192.168.128.64"

    controlnode.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
    end

    controlnode.vm.synced_folder "./ansible", "/home/vagrant/ansible", create: true, mount_options: ["dmode=755,fmode=644"]

    controlnode.vm.provision "file", source: "files/id_rsa", destination: "/tmp/id_rsa"
    controlnode.vm.provision "file", source: "files/id_rsa.pub", destination: "/tmp/id_rsa.pub"

    controlnode.vm.provision "shell", inline: <<-SHELL
      set -eu
      tr -d '\r' < /tmp/id_rsa.pub > /tmp/id_rsa.pub.clean
      tr -d '\r' < /tmp/id_rsa > /tmp/id_rsa.clean

      install -d -m 700 -o vagrant -g vagrant /home/vagrant/.ssh
      install -m 600 -o vagrant -g vagrant /tmp/id_rsa.clean /home/vagrant/.ssh/id_rsa
      install -m 644 -o vagrant -g vagrant /tmp/id_rsa.pub.clean /home/vagrant/.ssh/id_rsa.pub

      grep -qF "$(cat /tmp/id_rsa.pub.clean)" /home/vagrant/.ssh/authorized_keys || \
        cat /tmp/id_rsa.pub.clean >> /home/vagrant/.ssh/authorized_keys
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get remove -y ansible || true
      apt-get install -y python3-pip
      pip3 install --upgrade ansible
    SHELL
  end

  config.vm.define "lan" do |lan|
    lan.vm.box = "ubuntu/jammy64"
    lan.vm.hostname = "lan"
    lan.vm.network "private_network", ip: "192.168.128.32"

    lan.vm.provider "virtualbox" do |v|
      v.memory = 8192
      v.cpus = 4
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
    end

    lan.vm.provision "file", source: "files/id_rsa.pub", destination: "/tmp/id_rsa.pub"

    lan.vm.provision "shell", inline: <<-SHELL
      set -eu
      tr -d '\r' < /tmp/id_rsa.pub > /tmp/id_rsa.pub.clean

      install -d -m 700 -o vagrant -g vagrant /home/vagrant/.ssh
      grep -qF "$(cat /tmp/id_rsa.pub.clean)" /home/vagrant/.ssh/authorized_keys || \
        cat /tmp/id_rsa.pub.clean >> /home/vagrant/.ssh/authorized_keys
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
    SHELL
  end

end
