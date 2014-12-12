
Vagrant.configure(2) do |config|
  config.vm.define 'krikri' do |krikri|
    krikri.vm.box = 'hashicorp/precise64'
    krikri.vm.hostname = 'krikri'
    krikri.vm.network :private_network, ip: '192.168.50.20'
    krikri.vm.network "forwarded_port", guest: 8983, host: 8983
    krikri.vm.network "forwarded_port", guest: 3000, host: 3000
    krikri.vm.provider 'virtualbox' do |vb|
      vb.memory = 1024
    end
    krikri.vm.provision 'ansible' do |ansible|
      ansible.playbook = 'provisioning/provision.yml'
    end
  end
end
