# OPNsense Base image

This repo contains Packer files for building OPNsense amd64 base image for QEMU/OpenStack and for VirtualBox/Vagrant using Gitlab CI/CD.

## Image for QEMU/OpenStack

There is one user account:

*  `freebsd` created by [cloud-init](https://cloudinit.readthedocs.io/en/latest/), enabled for SSH

## Image for VirtualBox/Vagrant

Has not been created yet.

## How to build

For information how to build this image see [wiki](https://gitlab.ics.muni.cz/muni-kypo-images/muni-kypo-images-wiki/-/wikis/How-to-build-an-image-locally).

## Known issues and requested features

* See [issues](https://gitlab.ics.muni.cz/muni-kypo-images/opnsense/-/issues).

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgements

<table>
  <tr>
    <td>![EU](figures/EU.jpg "EU emblem")</td>
    <td>
This software and accompanying documentation is part of a [project](https://cybersec4europe.eu) that has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement No. 830929.
</td>
  </tr>
  <tr>
      <td>![TACR](figures/TACR.png "TACR logo")</td>
      <td>This software was developed with the support of the Technology Agency of the Czech Republic (TA ČR) from the National Centres of Competence programme (project identification TN01000077 – [National Centre of Competence in Cybersecurity](https://nc3.cz/)). 
      </td>
  </tr>
 </table>

