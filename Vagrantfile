# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# https://dev.windows.com/en-us/microsoft-edge/tools/vms/mac/
#
Vagrant.configure(2) do |config|
  config.vm.box = "win7"
  #config.vm.box = "win10"
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
  end
  config.vm.boot_timeout = 1
  config.vm.synced_folder ".", "shared"
end
