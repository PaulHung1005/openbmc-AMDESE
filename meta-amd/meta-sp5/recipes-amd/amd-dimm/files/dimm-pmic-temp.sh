#!/bin/bash

# Read board_id from u-boot env
board_id=`/sbin/fw_printenv -n board_id`
I3C_TOOL="/usr/bin/i3ctransfer"
num_of_cpu=1

# If no board_id then set num of cpu to 2 socket
case "$board_id" in
    "40" | "41" | "42")
        echo " Onyx 1 CPU"
        num_of_cpu=1
        ;;
    "46" | "47" | "48")
        echo " Ruby 1 CPU"
        num_of_cpu=1
        ;;
    "43" | "44" | "45")
        echo " Quartz 2 CPU"
        num_of_cpu=2
        ;;
    "49" | "4A" |"4a" | "4B" | "4b")
        echo " Titanite 2 CPU "
        num_of_cpu=2
        ;;
    *)
        num_of_cpu=2
        ;;
esac

# assume BMC has access to I3C
i3cid=0
sock_id=0
channel=0

# read and process DIMM Temp
while [[ $sock_id < $num_of_cpu ]]
do
    for i3c_bus_per_soc in 1 2
    do
        # Check if at least one DIMM present on this BUS
        ls /dev/i3c-${i3cid}-* > /dev/null 2>&1
        if [[ $? -ne 0 ]]
        then
            # No DIMMs on this I3C bus
            (( i3cid += 1))
            (( channel += 6 ))
            continue
        fi

        for dimm in {0..5}
        do
            # Driver generated I3C name for this dimm
            pmic_name="/dev/i3c-${i3cid}-2040000000${dimm}"

            # Check if DIMM is present
            $I3C_TOOL -d ${pmic_name} -w 0x33 -r 0x1 > /dev/null 2>&1
            if [[ $? -ne 0 ]]
            then
                # DIMM not present
                continue
            fi

            echo "DIMM in Socket " ${sock_id} " Ch " ${i3cid} " slot " ${dimm} "is present"

            # DDR5 I3C DIMMs have 128 bytes of PMIC registers
            id=$(( channel + dimm ))
            reg="${LOG_DIR}/P${sock_id}_dimm${id}_pmic_temp"

            # Read DIMM Temp Register 0x33
            temp1="$($I3C_TOOL -d ${pmic_name} -w 0x33 -r 1 | grep 0x| cut -c 7-7)"
            temp="$(printf '%d' ${temp1})"
            if [[ $temp -eq 0 ]] || [[ $temp -eq 1 ]]
            then
                printf "DIMM Temp is less than 85 C (%s) \n" "${temp}"
            elif [[ $temp -eq 2 ]] || [[ $temp -eq 3 ]]
            then
                printf "DIMM Temp is 85 C (%s) \n" "${temp}"
            elif [[ $temp -eq 4 ]] || [[ $temp -eq 5 ]]
            then
                printf "DIMM Temp is 95 C (%s) \n" "${temp}"
            elif [[ $temp -eq 6 ]] || [[ $temp -eq 7 ]]
            then
                printf "DIMM Temp is 105 C (%s) \n" "${temp}"
            elif [[ $temp -eq 8 ]] || [[ $temp -eq 9 ]]
            then
                printf "DIMM Temp is 115 C (%s) \n" "${temp}"
            elif [[ $temp -eq a ]] || [[ $temp -eq b ]]
            then
                printf "DIMM Temp is 125 C (%s) \n" "${temp}"
            elif [[ $temp -eq c ]] || [[ $temp -eq d ]]
            then
                printf "DIMM Temp is 135 C (%s) \n" "${temp}"
            elif [[ $temp -eq e ]] || [[ $temp -eq f ]]
            then
                printf "DIMM Temp is greater than 140 C (%s) \n" "${temp}"
            fi

            # Read DIMM Warning Register 0x1B
            warn1="$($I3C_TOOL -d ${pmic_name} -w 0x1b -r 1 | grep 0x| cut -c 8-8)"
            warn="$(printf '%d' ${warn1})"
            if [[ $warn -eq d ]] || [[ $warn -eq 5 ]]
            then
                printf "DIMM Warning Temp is set to > 125 C (%s) \n" "${warn}"
            elif [[ $warn -eq 9 ]] || [[ $warn -eq 1 ]]
            then
                printf "DIMM Warning Temp is set to > 85 C (%s) \n" "${warn}"
            elif [[ $warn -eq a ]] || [[ $warn -eq 2 ]]
            then
                printf "DIMM Warning Temp is set to > 95 C (%s) \n" "${warn}"
            elif [[ $warn -eq b ]] || [[ $warn -eq 3 ]]
            then
                printf "DIMM Warning Temp is set to > 105 C (%s) \n" "${warn}"
            elif [[ $warn -eq c ]] || [[ $warn -eq 4 ]]
            then
                printf "DIMM Warning Temp is set to > 115 C (%s) \n" "${warn}"
            elif [[ $warn -eq e ]] || [[ $warn -eq 6 ]]
            then
                printf "DIMM Warning Temp is set to > 135 C (%s) \n" "${warn}"
            fi

            # Read DIMM Critical Temp Register 0x2E
            crit1="$($I3C_TOOL -d ${pmic_name} -w 0x2e -r 1 | grep 0x| cut -c 8-8)"
            crit="$(printf '%d' ${crit1})"
            if [[ $crit -eq 4 ]]
            then
                printf "DIMM Critical Temp is set to > 145 C (%s) \n" "${crit}"
            elif [[ $crit -eq 0 ]]
            then
                printf "DIMM Critical Temp is set to > 105 C (%s) \n" "${crit}"
            elif [[ $crit -eq 1 ]]
            then
                printf "DIMM Critical Temp is set to > 115 C (%s) \n" "${crit}"
            elif [[ $crit -eq 2 ]]
            then
                printf "DIMM Critical Temp is set to > 125 C (%s) \n" "${crit}"
            elif [[ $crit -eq 3 ]]
            then
                printf "DIMM Critical Temp is set to > 135 C (%s) \n" "${crit}"
            fi

        done # END of dimm loop

        (( channel += 6 ))
        (( i3cid += 1 ))

    done # END of i3c_bus_per_sock loop
    (( sock_id += 1 ))

done # END of num_of_cpu loop

# <TBD>
# If BMC set any GPIO for I3C access then
# release it here
# <TBD>
