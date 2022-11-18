FILESEXTRAPATHS_prepend := "${THISDIR}/phosphor-dbus-interfaces:"

S = "${WORKDIR}/git"

SRC_URI += "file://0001-recipes-phosphor-dbus-Add-enumeration-SCM_FPGA-for-v.patch \
            file://0002-recipes-phosphor-dbus-Add-enumeration-HPM_FPGA-for.patch \
            file://0003-recipe-phosphor-dbus-interfaces-Adding-VR-Support.patch \
            file://0004-add-retimer-fw-update-support.patch \
            file://0005-New-DBus-property-has-been-added-for-CPU-info.patch \
            file://0006-recipes-phosphor-dbus-Add-DIMM-Info-param.patch \
            file://0007-recipe-phosphor-dbus-Added-processor-DBus-property.patch \
            file://0008-phosphor-dbus-interfaces-Added-PPIN-entry.patch \
            "
