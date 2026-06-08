packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    external = {
      version = "> 0.0.2"
      source  = "github.com/joomcode/external"
    }
  }
}

data "external-raw" "opnsense_iso" {
  program = [
    "bash", "-c",
    "if [ ! -f opnsense.iso ]; then wget -nv https://mirror.dns-root.de/opnsense/releases/26.1/OPNsense-26.1-dvd-amd64.iso.bz2 -O opnsense.iso.bz2; bunzip2 opnsense.iso.bz2; fi"
  ]
}

source "qemu" "opnsense" {
  boot_command = [
    "root<enter>", # enter live system
    "opnsense<enter><wait10s>",
    "8<enter><wait2s>", # enter shell
    "dhclient vtnet0<enter><wait5s>",
    "telnet {{ .HTTPIP }} {{ .HTTPPort }} | sed '1,/^$/d' >/etc/opnsense-autoinstall-config.xml<wait><enter>",
    "GET /config.xml HTTP/1.0<enter><enter>",
    "telnet {{ .HTTPIP }} {{ .HTTPPort }} | sed '1,/^$/d' | /bin/sh<wait><enter>",
    "GET /autoinstall.sh HTTP/1.0<enter><enter>",
    "<wait1m>"
  ]
  boot_wait           = "2m"
  accelerator         = "kvm"
  disk_interface      = "virtio-scsi"
  disk_size           = "8192"
  format              = "qcow2"
  headless            = "true"
  http_directory      = "http"
  http_port_max       = "10089"
  http_port_min       = "10082"
  iso_checksum        = "51ca500465611a559f651eb10be6b3342c07efa0db18c78689dda4266b1ca9a8"
  iso_url             = "./opnsense.iso"
  net_device          = "virtio-net"
  output_directory    = "target-qemu"
  qemuargs            = [["-m", "4096m"], ["-smp", "cpus=4,maxcpus=16,cores=4"]]
  shutdown_command    = "shutdown -p now"
  ssh_password        = "installed"
  ssh_port            = "22"
  ssh_username        = "root"
  ssh_wait_timeout    = "20m"
  use_default_display = "true"
  vm_name             = "opnsense"
  vnc_bind_address    = "0.0.0.0"
  vnc_port_max        = "5900"
  vnc_port_min        = "5900"
}

build {
  sources = ["source.qemu.opnsense"]

  provisioner "file" {
    destination = "/tmp/cloud.cfg"
    source      = "cloud.cfg"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "scripts/cloud-init.sh",
      "scripts/fixes.sh",
      "scripts/disable-root-password.sh"
    ]
  }

}
