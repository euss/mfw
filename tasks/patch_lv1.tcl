#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 300
# Description: Patch LV1 hypervisor

# Option --patch-lv1-mmap: Allow mapping of any memory area (Needed for LV2 Poke)

# Type --patch-lv1: boolean

namespace eval ::patch_lv1 {

    array set ::patch_lv1::options {
        --patch-lv1-mmap true
    }

    proc main { } {
        set self "lv1.self"

        ::modify_coreos_file $self ::patch_lv1::patch_self
    }

    proc patch_self {self} {
        if {!$::patch_lv1::options(--patch-lv1-mmap)} {
            log "WARNING: Enabled task has no enabled option" 1
        } else {
            ::modify_self_file $self ::patch_lv1::patch_elf
        }
    }

    proc patch_elf {elf} {
        if {$::patch_lv1::options(--patch-lv1-mmap)} {
            log "Patching LV1 hypervisor to allow mapping of any memory area"

            set search  "\x39\x08\x05\x48\x39\x20\x00\x00\x38\x60\x00\x00\x4b\xff\xfc\x45"
            set replace "\x01"

            catch_die {::patch_elf $elf $search 7 $replace} \
                "Unable to patch self [file tail $elf]"
        }
    }
}
