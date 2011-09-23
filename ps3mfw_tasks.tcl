#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

proc ego {} {
	puts "PS3MFW Creator v0.1"
	puts "    Copyright (C) 2011 Project PS3MFW"
	puts "    This program comes with ABSOLUTELY NO WARRANTY;"
	puts "    This is free software, and you are welcome to redistribute it"
	puts "    under certain conditions; see COPYING for details."
	puts ""
	puts "    Developed By :"
	puts "    Anonymous Developers"
	puts ""
}

proc ego_gui {} {
	log "PS3MFW Creator v0.1"
	log "    Copyright (C) 2011 Project PS3MFW"
	log "    This program comes with ABSOLUTELY NO WARRANTY;"
	log "    This is free software, and you are welcome to redistribute it"
	log "    under certain conditions; see COPYING for details."
	log ""
	log "    Developed By :"
	log "    Anonymous Developers"
	log ""
}

proc clean_up {  } {
	log "Deleting output files"
	catch_die {file delete -force -- $::CUSTOM_PUP_DIR $::ORIGINAL_PUP_DIR $::OUT_FILE} \
	    "Could not cleanup output files"
}

proc unpack_source_pup {pup dest} {
	log "Unpacking source PUP [file tail $pup]"
	catch_die {pup_extract $pup $dest} "Error extracting PUP file [file tail $pup]"

	# Check for license.txt for people using older version of ps3tools
	set license_txt [file join $::CUSTOM_UPDATE_DIR license.txt]
	if {![file exists $::CUSTOM_LICENSE_XML] && [file exists $license_txt]} {
		set ::CUSTOM_LICENSE_XML $license_txt
	}
}

proc pack_custom_pup {dir pup} {
	global options

	set build $options(--custom-pup-version)
	if {$build == "" || ![string is integer $build]} {
		log "Getting build version from [file tail $::IN_FILE]"
		set build [get_build_version $::IN_FILE]
		incr build
		log "Found build version: $build"
	}
	# create pup
	log "Packing Modified PUP [file tail $pup]"
	catch_die {pup_create $dir $pup $build} "Error packing PUP file [file tail $pup]"
}

proc change_version {prefix suffix {clear 0}} {
	global options

	if {$clear} {
		set version ""
	} else {
		set fd [open [file join $::CUSTOM_VERSION_TXT] r]
		set version [string trim [read $fd]]
		close $fd
	}

	set fd [open [file join $::CUSTOM_VERSION_TXT] w]
	puts $fd "${prefix}${version}${suffix}"
	close $fd
}


proc build_mfw {input output tasks} {
	global options

	set ::selected_tasks $tasks

	# print out ego info
	ego_gui

	if {$input == "" || $output == ""} {
		die "Must specify an input and output file"
	}
	if {![file exists $input]} {
		die "Input file does not exist"
	}

	log "Selected tasks : $tasks"
	debug "HOME=[set ::env(HOME)]\nPATH=[set ::env(PATH)]\n"

	clean_up

	# PREPARE PS3UPDAT.PUP for modification
	unpack_source_pup $input $::CUSTOM_PUP_DIR

	extract_tar $::CUSTOM_UPDATE_TAR $::CUSTOM_UPDATE_DIR

	# copy original PUP to working dir
	copy_file $::CUSTOM_PUP_DIR $::ORIGINAL_PUP_DIR

	log "Unpacking all dev_flash files"
	unpkg_devflash_all $::CUSTOM_DEVFLASH_DIR

	# Execute tasks
	foreach task $tasks {
	    log "******** Running task $task **********"
	    eval [string map {- _} ${task}::main]
	}

	# RECREATE PS3UPDAT.PUP
	file delete -force $::CUSTOM_DEVFLASH_DIR
	set files [lsort [glob -nocomplain -tails -directory $::CUSTOM_UPDATE_DIR *.pkg]]
	eval lappend files [lsort [glob -nocomplain -tails -directory $::CUSTOM_UPDATE_DIR *.img]]
	eval lappend files [lsort [glob -nocomplain -tails -directory $::CUSTOM_UPDATE_DIR dev_flash3_*]]
	eval lappend files [lsort [glob -nocomplain -tails -directory $::CUSTOM_UPDATE_DIR dev_flash_*]]
 	create_tar $::CUSTOM_UPDATE_TAR  $::CUSTOM_UPDATE_DIR $files

	# Change version.txt value
	if {$options(--custom-version-string) != ""} {
		change_version $options(--custom-version-string) "" 1
	} else {
		change_version $options(--version-prefix) $options(--version-suffix)
	}

	pack_custom_pup $::CUSTOM_PUP_DIR $::OUT_FILE
}
