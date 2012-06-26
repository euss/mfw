#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
# Copyright (C) glevand (geoffrey.levand@mail.ru)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 300
# Description: Patch emergency init application

# Option --patch-pup-search-in-game-disc: Disable searching for update packages in GAME disc
# Option --patch-gameos-hdd-region-size: Create GameOS HDD region smaller than default

# Type --patch-pup-search-in-game-disc: boolean
# Type --patch-gameos-hdd-region-size: combobox {{1/eighth of drive} {1/quarter of drive} {1/half of drive} {22GB} {10GB} {20GB} {30GB} {40GB} {50GB} {60GB} {70GB} {80GB} {90GB} {100GB} {110GB} {120GB} {130GB} {140GB} {150GB} {160GB} {170GB} {180GB} {190GB} {200GB} {210GB} {220GB} {230GB} {240GB} {250GB} {260GB} {270GB} {280GB} {290GB} {300GB} {310GB} {320GB} {330GB} {340GB} {350GB} {360GB} {370GB} {380GB} {390GB} {400GB} {410GB} {420GB} {430GB} {440GB} {450GB} {460GB} {470GB} {480GB} {490GB} {500GB} {510GB} {520GB} {530GB} {540GB} {550GB} {560GB} {570GB} {580GB} {590GB} {600GB} {610GB} {620GB} {630GB} {640GB} {650GB} {660GB} {670GB} {680GB} {690GB} {700GB} {710GB} {720GB} {730GB} {740GB} {750GB} {760GB} {770GB} {780GB} {790GB} {800GB} {810GB} {820GB} {830GB} {840GB} {850GB} {860GB} {870GB} {880GB} {890GB} {900GB} {910GB} {920GB} {930GB} {940GB} {950GB} {960GB} {970GB} {980GB} {990GB} {1000GB}}

namespace eval ::patch_emer_init {

    array set ::patch_emer_init::options {
        --patch-pup-search-in-game-disc false
        --patch-gameos-hdd-region-size "1/quarter"
    }

    proc main {} {
        set self "emer_init.self"
      
        ::modify_coreos_file $self ::patch_emer_init::patch_self
    }

    proc patch_self {self} {
        ::modify_self_file $self ::patch_emer_init::patch_elf
    }

    proc patch_elf {elf} {
        variable options
        set size $options(--patch-gameos-hdd-region-size)
        set pup $options(--patch-pup-search-in-game-disc)

        if {$size != ""} {
            log "Patching [file tail $elf] to create GameOS HDD region of size $size of installed HDD"

            set search    "\xe9\x21\x00\xa0\x79\x4a\x00\x20\xe9\x1b\x00\x00\x38\x00\x00\x00"
            append search "\x7d\x26\x48\x50\x7d\x49\x03\xa6\x39\x40\x00\x00\x38\xe9\xff\xf8"
            set replace   "\x79\x27"

            if {[string equal ${size} "1/eighth of drive"] == 1} {
                append replace "\xe8\xc2"
            } elseif {[string equal ${size} "1/quarter of drive"] == 1} {
                append replace "\xf0\x82"
            } elseif {[string equal ${size} "1/half of drive"] == 1} {
                append replace "\xf8\x42"
            } elseif {[string equal ${size} "22GB"] == 1} {
                append replace "\xfd\x40"
            } elseif {[string equal ${size} "10GB"] == 1} {
                append replace "\xfe\xc0"
            } elseif {[string equal ${size} "20GB"] == 1} {
                append replace "\xfd\x80"
            } elseif {[string equal ${size} "30GB"] == 1} {
                append replace "\xfc\x40"
            } elseif {[string equal ${size} "40GB"] == 1} {
                append replace "\xfb\x00"
            } elseif {[string equal ${size} "50GB"] == 1} {
                append replace "\xf9\xc0"
            } elseif {[string equal ${size} "60GB"] == 1} {
                append replace "\xf8\x80"
            } elseif {[string equal ${size} "70GB"] == 1} {
                append replace "\xf7\x40"
            } elseif {[string equal ${size} "80GB"] == 1} {
                append replace "\xf6\x00"
            } elseif {[string equal ${size} "90GB"] == 1} {
                append replace "\xf4\xc0"
            } elseif {[string equal ${size} "100GB"] == 1} {
                append replace "\xf3\x80"
            } elseif {[string equal ${size} "110GB"] == 1} {
                append replace "\xf2\x40"
            } elseif {[string equal ${size} "120GB"] == 1} {
                append replace "\xf1\x00"
            } elseif {[string equal ${size} "130GB"] == 1} {
                append replace "\xef\xc0"
            } elseif {[string equal ${size} "140GB"] == 1} {
                append replace "\xee\x80"
            } elseif {[string equal ${size} "150GB"] == 1} {
                append replace "\xed\x40"
            } elseif {[string equal ${size} "160GB"] == 1} {
                append replace "\xec\x00"
            } elseif {[string equal ${size} "170GB"] == 1} {
                append replace "\xea\xc0"
            } elseif {[string equal ${size} "180GB"] == 1} {
                append replace "\xe9\x80"
            } elseif {[string equal ${size} "190GB"] == 1} {
                append replace "\xe8\x40"
            } elseif {[string equal ${size} "200GB"] == 1} {
                append replace "\xe7\x00"
            } elseif {[string equal ${size} "210GB"] == 1} {
                append replace "\xe5\xc0"
            } elseif {[string equal ${size} "220GB"] == 1} {
                append replace "\xe4\x80"
            } elseif {[string equal ${size} "230GB"] == 1} {
                append replace "\xe3\x40"
            } elseif {[string equal ${size} "240GB"] == 1} {
                append replace "\xe2\x00"
            } elseif {[string equal ${size} "250GB"] == 1} {
                append replace "\xe0\xc0"
            } elseif {[string equal ${size} "260GB"] == 1} {
                append replace "\xdf\x80"
            } elseif {[string equal ${size} "270GB"] == 1} {
                append replace "\xde\x40"
            } elseif {[string equal ${size} "280GB"] == 1} {
                append replace "\xdd\x00"
            } elseif {[string equal ${size} "290GB"] == 1} {
                append replace "\xdb\xc0"
            } elseif {[string equal ${size} "300GB"] == 1} {
                append replace "\xda\x80"
            } elseif {[string equal ${size} "310GB"] == 1} {
                append replace "\xd9\x40"
            } elseif {[string equal ${size} "320GB"] == 1} {
                append replace "\xd8\x00"
            } elseif {[string equal ${size} "330GB"] == 1} {
                append replace "\xd6\xc0"
            } elseif {[string equal ${size} "340GB"] == 1} {
                append replace "\xd5\x80"
            } elseif {[string equal ${size} "350GB"] == 1} {
                append replace "\xd4\x40"
            } elseif {[string equal ${size} "360GB"] == 1} {
                append replace "\xd3\x00"
            } elseif {[string equal ${size} "370GB"] == 1} {
                append replace "\xd1\xc0"
            } elseif {[string equal ${size} "380GB"] == 1} {
                append replace "\xd0\x80"
            } elseif {[string equal ${size} "390GB"] == 1} {
                append replace "\xcf\x40"
            } elseif {[string equal ${size} "400GB"] == 1} {
                append replace "\xce\x00"
            } elseif {[string equal ${size} "410GB"] == 1} {
                append replace "\xcc\xc0"
            } elseif {[string equal ${size} "420GB"] == 1} {
                append replace "\xcb\x80"
            } elseif {[string equal ${size} "430GB"] == 1} {
                append replace "\xca\x40"
            } elseif {[string equal ${size} "440GB"] == 1} {
                append replace "\xc9\x00"
            } elseif {[string equal ${size} "450GB"] == 1} {
                append replace "\xc7\xc0"
            } elseif {[string equal ${size} "460GB"] == 1} {
                append replace "\xc6\x80"
            } elseif {[string equal ${size} "470GB"] == 1} {
                append replace "\xc5\x40"
            } elseif {[string equal ${size} "480GB"] == 1} {
                append replace "\xc4\x00"
            } elseif {[string equal ${size} "490GB"] == 1} {
                append replace "\xc2\xc0"
            } elseif {[string equal ${size} "500GB"] == 1} {
                append replace "\xc1\x80"
            } elseif {[string equal ${size} "510GB"] == 1} {
                append replace "\xc0\x40"
            } elseif {[string equal ${size} "520GB"] == 1} {
                append replace "\xbf\x00"
            } elseif {[string equal ${size} "530GB"] == 1} {
                append replace "\xbd\xc0"
            } elseif {[string equal ${size} "540GB"] == 1} {
                append replace "\xbc\x80"
            } elseif {[string equal ${size} "550GB"] == 1} {
                append replace "\xbb\x40"
            } elseif {[string equal ${size} "560GB"] == 1} {
                append replace "\xba\x00"
            } elseif {[string equal ${size} "570GB"] == 1} {
                append replace "\xb8\xc0"
            } elseif {[string equal ${size} "580GB"] == 1} {
                append replace "\xb7\x80"
            } elseif {[string equal ${size} "590GB"] == 1} {
                append replace "\xb6\x40"
            } elseif {[string equal ${size} "600GB"] == 1} {
                append replace "\xb5\x00"
            } elseif {[string equal ${size} "610GB"] == 1} {
                append replace "\xb3\xc0"
            } elseif {[string equal ${size} "620GB"] == 1} {
                append replace "\xb2\x80"
            } elseif {[string equal ${size} "630GB"] == 1} {
                append replace "\xb1\x40"
            } elseif {[string equal ${size} "640GB"] == 1} {
                append replace "\xb0\x00"
            } elseif {[string equal ${size} "650GB"] == 1} {
                append replace "\xae\xc0"
            } elseif {[string equal ${size} "660GB"] == 1} {
                append replace "\xad\x80"
            } elseif {[string equal ${size} "670GB"] == 1} {
                append replace "\xac\x40"
            } elseif {[string equal ${size} "680GB"] == 1} {
                append replace "\xab\x00"
            } elseif {[string equal ${size} "690GB"] == 1} {
                append replace "\xa9\xc0"
            } elseif {[string equal ${size} "700GB"] == 1} {
                append replace "\xa8\x80"
            } elseif {[string equal ${size} "710GB"] == 1} {
                append replace "\xa7\x40"
            } elseif {[string equal ${size} "720GB"] == 1} {
                append replace "\xa6\x00"
            } elseif {[string equal ${size} "730GB"] == 1} {
                append replace "\xa4\xc0"
            } elseif {[string equal ${size} "740GB"] == 1} {
                append replace "\xa3\x80"
            } elseif {[string equal ${size} "750GB"] == 1} {
                append replace "\xa2\x40"
            } elseif {[string equal ${size} "760GB"] == 1} {
                append replace "\xa1\x00"
            } elseif {[string equal ${size} "770GB"] == 1} {
                append replace "\x9f\xc0"
            } elseif {[string equal ${size} "780GB"] == 1} {
                append replace "\x9e\x80"
            } elseif {[string equal ${size} "790GB"] == 1} {
                append replace "\x9d\x40"
            } elseif {[string equal ${size} "800GB"] == 1} {
                append replace "\x9c\x00"
            } elseif {[string equal ${size} "810GB"] == 1} {
                append replace "\x9a\xc0"
            } elseif {[string equal ${size} "820GB"] == 1} {
                append replace "\x99\x80"
            } elseif {[string equal ${size} "830GB"] == 1} {
                append replace "\x98\x40"
            } elseif {[string equal ${size} "840GB"] == 1} {
                append replace "\x97\x00"
            } elseif {[string equal ${size} "850GB"] == 1} {
                append replace "\x95\xc0"
            } elseif {[string equal ${size} "860GB"] == 1} {
                append replace "\x94\x80"
            } elseif {[string equal ${size} "870GB"] == 1} {
                append replace "\x93\x40"
            } elseif {[string equal ${size} "880GB"] == 1} {
                append replace "\x92\x00"
            } elseif {[string equal ${size} "890GB"] == 1} {
                append replace "\x90\xc0"
            } elseif {[string equal ${size} "900GB"] == 1} {
                append replace "\x8f\x80"
            } elseif {[string equal ${size} "910GB"] == 1} {
                append replace "\x8e\x40"
            } elseif {[string equal ${size} "920GB"] == 1} {
                append replace "\x8d\x00"
            } elseif {[string equal ${size} "930GB"] == 1} {
                append replace "\x8b\xc0"
            } elseif {[string equal ${size} "940GB"] == 1} {
                append replace "\x8a\x80"
            } elseif {[string equal ${size} "950GB"] == 1} {
                append replace "\x89\x40"
            } elseif {[string equal ${size} "960GB"] == 1} {
                append replace "\x88\x00"
            } elseif {[string equal ${size} "970GB"] == 1} {
                append replace "\x86\xc0"
            } elseif {[string equal ${size} "980GB"] == 1} {
                append replace "\x85\x80"
            } elseif {[string equal ${size} "990GB"] == 1} {
                append replace "\x84\x40"
            } elseif {[string equal ${size} "1000GB"] == 1} {
                append replace "\x83\x00"
            }

            catch_die {::patch_elf $elf $search 28 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$pup} {
            log "Patching [file tail $elf] to disable searching for update packages in GAME disc"

            set search  "\x80\x01\x00\x74\x2f\x80\x00\x00\x40\x9e\x00\x14\x7f\xa3\xeb\x78"
            set replace "\x38\x00\x00\x01"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
    }
}


