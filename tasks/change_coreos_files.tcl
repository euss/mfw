#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
 
# Priority: 2900
# Description: Change a specific file in CORE_OS_PACKAGE manually


namespace eval change_coreos_files {

	array set ::change_coreos_files::options {
        --change_coreos_files true
    }

    proc main {} {
	
		set self "appldr"

        ::modify_coreos_file $self ::change_coreos_files::change_file
    }

    proc change_file {$self} {
        
        if {[package provide Tk] != "" } {
           tk_messageBox -default ok -message "Change the file or files you need in '.../Temp/PS3MFW-MFW/CORE_OS_PACKAGE' then press ok to continue" -icon warning
        } else {
           puts "Press \[RETURN\] or \[ENTER\] to continue"
           gets stdin
        }
    }
}
