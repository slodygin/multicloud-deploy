#sudo apt-get install -y python3-lxml virt-manager qemu-kvm libvirt-daemon libvirt-daemon-system-systemd libvirt-daemon-system dnsmasq-base qemu-utils libguestfs-tools mkisofs
#virsh pool-define /dev/stdin <<EOF
#<pool type='dir'>
#  <name>default</name>
#  <target>
#    <path>/var/lib/libvirt/images</path>
#  </target>
#</pool>
#EOF
#virsh pool-start default
#virsh pool-autostart default
#virsh net-undefine default
#virsh net-destroy undefine
#cat <<EOF > network.xml
#<network>
#  <name>default</name>
#  <forward mode='nat'>
#    <nat>
#      <port start='1024' end='65535'/>
#    </nat>
#  </forward>
#  <bridge name='virbr0' stp='on' delay='0'/>
#  <ip address='10.5.5.1' netmask='255.255.255.0'>
#    <dhcp>
#      <range start='10.5.5.2' end='10.5.5.254'/>
#    </dhcp>
#  </ip>
#</network>
#EOF
#virsh net-define --file network.xml
#sudo virsh net-start default
#sudo virsh net-autostart --network default
#virsh net-dumpxml default
#virsh net-list --all
terraform {
  backend "http" {
  }
}
terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

provider "libvirt" {
#  uri = "qemu:///system"
#  uri = "qemu+ssh://root@192.168.0.1/system?keyfile=/home/lodygin/.ssh/id_rsa222&sshauth=privkey&no_verify=1"
  uri = "qemu+ssh://root@192.168.0.1/system?keyfile=/root/.ssh/id_rsa&sshauth=privkey&no_verify=1"
}


# variables that can be overriden
variable "hostname" {
  type    = list(string)
  default = ["kube1","kube2","kube3"]
}
#variable "hostname" { default = "vm_u20" }
variable "domain" { default = "local" }
variable "memoryMB" { default = 1024*8 }
variable "cpu" { default = 3 }


# fetch the latest ubuntu release image from their mirrors.
#when ising cloud image- now allowed to increase disk-size
#only on localy downloaded image with command:
#qemu-img resize images/focal-server-cloudimg-amd64-disk-kvm.img 10G
resource "libvirt_volume" "os_image" {
  count = length(var.hostname)
  name = "os_image.${var.hostname[count.index]}"
  pool = "default"
  #source = "https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2" #original but small image
  source = "/artifacts/debian-11-genericcloud-amd64.qcow2"
  format = "qcow2"
}

# Use CloudInit ISO to add ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
          count = length(var.hostname)
          name = "${var.hostname[count.index]}-commoninit.iso"
          #name = "${var.hostname}-commoninit.iso"
          # pool = "default"
          user_data = data.template_file.user_data[count.index].rendered
          network_config = data.template_file.network_config.rendered
}



data "template_file" "user_data" {
  count = length(var.hostname)
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = element(var.hostname, count.index)
    fqdn = "${var.hostname[count.index]}.${var.domain}"
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config_dhcp.cfg")
}

# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  count = length(var.hostname)
  name = "${var.hostname[count.index]}"
  memory = var.memoryMB
  vcpu = var.cpu
  cpu {
    mode = "host-passthrough"
  }
  disk {
       volume_id = element(libvirt_volume.os_image.*.id, count.index)
  }

  network_interface {
       network_name = "default"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

terraform {
  required_version = ">= 0.12"
}

output "ips" {
  # show IP, run 'terraform refresh' if not populated
  value = libvirt_domain.domain-ubuntu.*.network_interface.0.addresses
}
