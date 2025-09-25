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
    "if [ ! -f opnsense.iso ]; then wget -nv https://mirror.dns-root.de/opnsense/releases/25.7/OPNsense-25.7-dvd-amd64.iso.bz2 -O opnsense.iso.bz2; bunzip2 opnsense.iso.bz2; fi"
  ]
}

source "qemu" "opnsense" {
  boot_command = [
    "<wait1m30s>",
    "installer<enter>",
    "opnsense<enter><wait10s>",
    "<enter><wait5s>",
    "<down><enter><wait5s>",
    "<down><enter><wait5s>",
    "<left><enter><wait5s>",
    "<wait5m>",
    "<down><enter><wait5s>",
    "<enter><wait5s>",
    "<wait1m30s>",
    "root<enter>",
    "opnsense<enter><wait>",
    "8<enter><wait2s>",
    "dhclient vtnet0<enter><wait5s>",
    "telnet {{ .HTTPIP }} {{ .HTTPPort }} | sed '1,/^$/d' >/conf/config.xml<wait><enter>",
    "GET /config.xml HTTP/1.0<enter><enter>",
    "reboot<enter><wait30s>"
  ]
  boot_wait           = "2s"
  disk_interface      = "virtio-scsi"
  disk_size           = "8192"
  format              = "qcow2"
  headless            = "true"
  http_directory      = "http"
  http_port_max       = "10089"
  http_port_min       = "10082"
  iso_checksum        = "36ec856ad34d1a497e9edd19183ac2b63aa3f9bb9ff7e7ff7cdc93d319a3ec2c"
  iso_url             = "./opnsense.iso"
  net_device          = "virtio-net"
  output_directory    = "target-qemu"
  qemuargs            = [["-m", "4096m"], ["-smp", "cpus=4,maxcpus=16,cores=4"]]
  shutdown_command    = "shutdown -p now"
  ssh_password        = "opnsense"
  ssh_port            = "22"
  ssh_username        = "root"
  ssh_wait_timeout    = "5m"
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
