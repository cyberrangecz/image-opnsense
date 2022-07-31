#!/bin/sh

xml edit --inplace -u '/opnsense/system/user[name="root"]/password' -v '*' /conf/config.xml
