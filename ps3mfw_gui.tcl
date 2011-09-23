#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

if { $::tcl_platform(os) == "Linux" } {
    ::ttk::setTheme "clam"
}

set icon32 [image create photo -file [file join ${::PS3MFW_DIR} images ps3mfw-icon-32.gif]]
set icon128 [image create photo -file [file join ${::PS3MFW_DIR} images ps3mfw-icon-128.gif]]
if { [catch {wm iconphoto . -default $icon128 $icon32} res] } {
    puts "error $res"
    catch {wm iconbitmap . -default [file join ${::PS3MFW_DIR} images ps3mfw-icon.ico]}
}

# This is a hack to use the window state 'zoomed' on Linux (X11).
if { [catch {tk windowingsystem} wsystem] == 0 && $wsystem  == "x11" && \
     [info commands ::tk::wm] == ""  && [info commands wm] == "wm" } {
    rename wm ::tk::wm
    proc ::wm {option window args} {
        if {$option == "state"} {
            if {[llength $args] == 0} {
                set state [::tk::wm state $window]
                if {$state == "normal"} {
                    if {[::tk::wm attributes $window -zoomed]} {
                        return "zoomed"
                    }
                }
                return $state
            } elseif {[llength $args] == 1} {
                set state [lindex $args 0]
                if {$state == "normal"} {
                    ::tk::wm attributes $window -zoomed 0
                    ::tk::wm state $window normal
                } elseif {$state == "zoomed"} {
                    ::tk::wm state $window normal
                    ::tk::wm attributes $window -zoomed 1
                } else {
                    if {[catch {::tk::wm state $window $state} err]} {
                        if {[string first $err "bad argument"] == 0} {
                            error "bad argument \"$state\": must be normal, iconic, withdrawn or zoomed"
                        } else {
                            return -code error $err
                        }
                    }
                }
            } else {
                error "wrong # args: should be \"wm state window ?state?\""
            }
        } else {
            eval [linsert $args 0 ::tk::wm $option $window]
        }
    }
}



namespace eval ::gui {
    variable tasks
    array set tasks {}
    variable padx 2
    variable pady 1
    variable theme  [set ::ttk::currentTheme]

    proc create_gui {arguments selected_tasks} {
        variable tasks

        wm title . "PS3MFW Builder v${::PS3MFW_VERSION}"
        create_menu

        if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
            bind . <Command-Shift-C> "console show"
        } else {
            bind . <Control-Shift-C> "console show"
        }

        hijack_logs

        if {[llength $arguments] > 2} {
            wm withdraw .
            tk_messageBox -default ok -message "Invalid arguments received" -icon warning
            wm state . normal
            set arguments [list]
        }

        set left [::ttk::frame .left]
        set middle [::ttk::frame .middle]
        set right [::ttk::frame .right]

        pack $left -side left -expand false -fill y -padx $::gui::padx -pady $::gui::pady
        pack $right -side right -expand false -fill y -padx $::gui::padx -pady $::gui::pady
        pack $middle -side left -expand true -fill both -padx $::gui::padx -pady $::gui::pady
        set files [::ttk::frame .left.files]
        set options_frame [::ttk::labelframe .left.options -text "Options"]
        set tasks_labelframe [::ttk::labelframe .left.tasks -text "Tasks"]
        set tasks_scrollframe [scrolledframe::scrolledframe .left.tasks.f \
              -yscrollcommand [list ::gui::set_scroll $tasks_labelframe.sy] \
              -xscrollcommand [list ::gui::set_scroll $tasks_labelframe.sx]]
        set tasks_frame [$tasks_scrollframe getframe]
        set tasks_sy [::ttk::scrollbar $tasks_labelframe.sy -orient vertical \
              -command [list $tasks_scrollframe yview]]
        set tasks_sx [::ttk::scrollbar $tasks_labelframe.sx -orient horizontal \
              -command [list $tasks_scrollframe xview]]
        grid $tasks_scrollframe -row 0 -column 0 -sticky nsew -padx $::gui::padx -pady $::gui::pady
        grid $tasks_sy -row 0 -column 1 -sticky ns -padx $::gui::padx -pady $::gui::pady
        grid $tasks_sx -row 1 -column 0 -sticky ew -padx $::gui::padx -pady $::gui::pady
        grid rowconfigure $tasks_labelframe 0 -weight 1
        grid columnconfigure $tasks_labelframe 0 -weight 1
        pack $files $options_frame -side top -expand false -fill x -padx $::gui::padx -pady $::gui::pady
        pack $tasks_labelframe -side top -expand true -fill both -padx $::gui::padx -pady $::gui::pady
        set input [::ttk::frame .left.files.input]
        set output [::ttk::frame .left.files.output]
        pack $input $output -side top -expand true -fill both -padx $::gui::padx -pady $::gui::pady
        set input_label [::ttk::label .left.files.input.label -text "Original Firmware :"]
        set input_entry [::ttk::entry .left.files.input.entry -textvariable ::IN_FILE]
        set input_button [::ttk::button .left.files.input.button -text "Browse" -command [list ::gui::browse open $input_entry [list { "PS3 Firmware Update" {*.PUP *.pup} }] ".PUP" "Choose the Official Firmware Update"]]
        pack $input_label $input_entry $input_button -side left -expand true -fill x -anchor nw -padx $::gui::padx -pady $::gui::pady
        set output_label [::ttk::label .left.files.output.label -text "Modified Firmware :"]
        set output_entry [::ttk::entry .left.files.output.entry -textvariable ::OUT_FILE]
        set output_button [::ttk::button .left.files.output.button -text "Browse" -command [list ::gui::browse save $output_entry [list { "PS3 Firmware Update" {*.PUP *.pup} }] ".PUP" "Choose the destination Modified Firmware"]]
        pack $output_label $output_entry $output_button -side left -expand true -fill x -anchor nw -padx $::gui::padx -pady $::gui::pady

        set ::IN_FILE [lindex $arguments 0]
        set ::OUT_FILE [lindex $arguments 1]

        set build [::ttk::button .right.build -text "Build MFW" -command ::gui::build_mfw]
        set exit [::ttk::button .right.exit -text "Quit" -command exit]
        set about [::ttk::frame .right.about]
        set themes [::ttk::labelframe .right.themes -text "Theme"]
        populate_themes $themes
        add_about_msg $about
        pack $about $build $exit -side top -expand false -fill both -padx $::gui::padx -pady $::gui::pady

        unset ::options(--gui)
        foreach opt [get_sorted_options [file normalize [info script]] [array names ::options]] {
            build_option $options_frame [file normalize [info script]] $opt ::options($opt)
        }

        foreach task [get_sorted_tasks] {
            if {[lsearch ${selected_tasks} $task] == -1} {
                set tasks($task) false
            } else {
                set tasks($task) true
            }
            build_task $tasks_frame $task [task_to_file $task]
        }
        wm state . zoomed

        # Force tasks window to have the right size
        update
        set tasks_height [winfo reqheight $tasks_frame]
        set tasks_width [winfo reqwidth $tasks_frame]
        $tasks_scrollframe configure -height $tasks_height -width $tasks_width

        task_selected $tasks_frame [lindex ${selected_tasks} 0]


        if {![catch {tk windowingsystem} wsystem] && $wsystem == "x11"} {
            bind . <Button-4> {::gui::scrollWidget %W -1}
            bind . <Button-5> {::gui::scrollWidget %W 1}
        } else {
            bind . <MouseWheel> {
                if {%D >= 0} {
                    ::gui::scrollWidget %W -1
                } else {
                    ::gui::scrollWidget %W 1
                }
            }
        }
    }

    proc scrollWidget {w d} {
        if {[winfo class $w] == "Text"} {
            return
        }
        if {[winfo class $w] == "Canvas"} {
            $w yview scroll $d units
        } elseif {[winfo parent $w] != "" } {
            scrollWidget [winfo parent $w] $d
        }
    }

    proc create_menu {} {
        set menu .menu

        menu $menu -tearoff 0 -type menubar -borderwidth 0 -activeborderwidth -0

        # App menu, only on Mac OS X (see Mac Interface Guidelines)
        if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
            set appmenu $menu.apple
            $menu add cascade -label "PS3MFW Builder" -menu $appmenu
            menu $appmenu -tearoff 0 -type normal
            $appmenu add command -label "About PS3MFW Builder" \
              -command ::gui::about
            $appmenu add separator
        }

        set filemenu [menu $menu.file -tearoff 0 -type normal]
        $filemenu add command -label "Select Official firmware" \
          -command [list ::gui::browse open .left.files.input.entry [list { "PS3 Firmware Update" {*.PUP *.pup} }] ".PUP" "Choose the Official Firmware Update"]
        $filemenu add command -label "Select Destination MFW firmware" \
          -command [list ::gui::browse save .left.files.output.entry [list { "PS3 Firmware Update" {*.PUP *.pup} }] ".PUP" "Choose the destination Modified Firmware"]
        $filemenu add separator
        $filemenu add command -label "Build MFW" -command ::gui::build_mfw
        $filemenu add separator
        $filemenu add command -label "Exit" -command "exit"

        set thememenu [menu $menu.theme -tearoff 0 -type normal]
        set helpmenu [menu $menu.help -tearoff 0 -type normal]
        $helpmenu add command -label "About PS3MFW Builder" -command ::gui::about

        $menu add cascade -label "File" -menu $filemenu
        $menu add cascade -label "Theme" -menu $thememenu
        $menu add cascade -label "Help" -menu $helpmenu

        . configure -menu $menu
    }

    proc add_about_msg { about } {
        set icon128 [image create photo -file [file join ${::PS3MFW_DIR} images ps3mfw-icon-128.gif]]
        pack [::ttk::label $about.img -image $icon128 -anchor center] -expand false -fill both
        pack [::ttk::label $about.l1 -text "PS3MFW Builder v${::PS3MFW_VERSION}" -anchor center] -expand false -fill x
        pack [::ttk::label $about.l2 -text "" -anchor center] -expand false -fill x
        pack [::ttk::label $about.l3 -text "Developed by :" -anchor center] -expand false -fill x
        pack [::ttk::label $about.l4 -text "Anonymous Developers" -anchor center] -expand false -fill x
        pack [::ttk::label $about.l5 -text "" -anchor center] -expand false -fill x
    }

    proc about { } {
        destroy .about
        toplevel .about
        wm title .about "About PS3MFW Builder"

        ::ttk::frame .about.f
        pack .about.f -expand true -fill both
        add_about_msg .about.f

        regexp {=?(\d+)x(\d+)[+\-](-?\d+)[+\-](-?\d+)} [winfo geometry .] -> width height x y
        set middle_x [expr {$x + ($width / 2)}]
        set middle_y [expr {$y + ($height / 2)}]
        set w 350
        set h 350
        incr middle_x -[expr {int($w / 2)}]
        incr middle_y -[expr {int($h / 2)}]
        wm geometry .about ${w}x${h}+${middle_x}+${middle_y}
    }

    proc populate_themes {themes} {

        array set THEMES {
            alt        "Revitalized"
            aqua       "Aqua"
            classic    "Classic"
            default    "Default"
            winnative  "Windows native"
            xpnative   "XP Native"
        }

        # Add in any available loadable themes:
        foreach name [::ttk::themes] {
            if {![info exists THEMES($name)]} {
                set THEMES($name) [string totitle $name]
            }
        }

        foreach {theme name} [array get THEMES] {
            set b [::ttk::radiobutton $themes.s$theme \
                -text     $name \
                -variable ::gui::theme -value $theme \
                -command  [list ::ttk::setTheme $theme]]
            .menu.theme add radiobutton -label "$name" \
                -variable ::gui::theme -value $theme \
                -command  [list ::ttk::setTheme $theme]

            pack $b -side top -expand false -fill x -padx $::gui::padx -pady $::gui::pady

            if { [lsearch -exact [package names] ttk::theme::$theme] == -1} {
                .menu.theme entryconfigure end -state disabled
                $themes.s$theme state disabled
            }
        }
    }

    proc build_option {w file name option} {
        set description [get_option_description $file $name]
        if {$description == ""} {
            set description $name
        }
        set typeargs [get_option_type $file $name]
        debug "Option Type $name: $typeargs"
        set type [lindex $typeargs 0]
        switch -nocase $type {
            boolean {
                set widget [::ttk::checkbutton $w.$name -text $description -variable $option -onvalue true -offvalue false]
            }
            string {
                set widget [::ttk::frame $w.$name]
                set label [::ttk::label $w.$name.label -text "$description :"]
                set entry [::ttk::entry $w.$name.entry -textvariable $option]
                pack $label $entry -side left -expand true -fill x -padx $::gui::padx -pady $::gui::pady -anchor nw
            }
            label {
                set widget [::ttk::frame $w.$name]
                set desclabel [::ttk::label $w.$name.desclabel -text "$description :"]
                set optlabel [::ttk::label $w.$name.optlabel -text [set $option]]
                pack $desclabel $optlabel -side left -expand true -fill x -padx $::gui::padx -pady $::gui::pady -anchor nw
            }
            radio {
                set optionValues [lindex $typeargs 1]
                #debug "Option optionValues $name: $optionValues"
                set widget [::ttk::frame $w.$name]
                set label [::ttk::label $w.$name.label -text "$description :"]
                set idx 0
                foreach optionValue $optionValues {
                    set radiobutton [::ttk::radiobutton $w.$name.radio$idx -text $optionValue -variable $option -value $optionValue]
                    pack $label $radiobutton -side left -expand true -fill x -padx $::gui::padx -pady $::gui::pady -anchor nw
                    incr idx 1
                }
            }
            combobox {
                set optionValues [lindex $typeargs 1]
                #debug "Option optionValues $name: $optionValues"
                set widget [::ttk::frame $w.$name]
                set label [::ttk::label $w.$name.label -text "$description :"]
                set combobox [::ttk::combobox $w.$name.combobox -textvariable $option -values $optionValues]
                pack $label $combobox -side left -expand true -fill x -padx $::gui::padx -pady $::gui::pady -anchor nw
            }
            file {
                set action [lindex $typeargs 1]
                set typeDesc [lindex $typeargs 2 0]
                set fileType [lindex $typeargs 2 1]
                set fileTypes [list [list $typeDesc [list *.[string toupper $fileType] *.[string tolower $fileType]]]]
                #debug "Option action $name: $action"
                #debug "Option typeDesc $name: $typeDesc"
                #debug "Option Filetype $name: $fileType"
                #debug "Option Filetypes $name: $fileTypes"
                set widget [::ttk::frame $w.$name]
                set label [::ttk::label $w.$name.label -text "$description :"]
                set entry [::ttk::entry $w.$name.entry -textvariable $option]
                set button [::ttk::button $w.$name.button -text "Browse" \
                      -command [list ::gui::browse $action $entry "$fileTypes" ".${fileType}" "Choose $typeDesc File"]]
                pack $label $entry $button -side left -expand true -fill x -anchor nw -padx $::gui::padx -pady $::gui::pady
            }
            textarea {
                set widget [::ttk::frame $w.$name]
                set label [::ttk::label $w.$name.label -text "$description :"]
                set frame [::ttk::frame $w.$name.f]
                set text [::TracedText::TracedText $frame.text -textvariable $option -wrap none \
                      -yscrollcommand [list ::gui::set_scroll $frame.sy] \
                      -xscrollcommand [list ::gui::set_scroll $frame.sx]];
                set sy [::ttk::scrollbar $frame.sy -orient vertical -command [list $text yview]]
                set sx [::ttk::scrollbar $frame.sx -orient horizontal -command [list $text xview]]
    
                grid $text -row 0 -column 0 -sticky nsew -padx $::gui::padx -pady $::gui::pady
                grid $sy -row 0 -column 1 -sticky ns -padx $::gui::padx -pady $::gui::pady
                grid $sx -row 1 -column 0 -sticky ew -padx $::gui::padx -pady $::gui::pady
                grid rowconfigure $frame 0 -weight 1
                grid columnconfigure $frame 0 -weight 1
                pack $label $frame -side top -expand true -fill x -padx $::gui::padx -pady $::gui::pady
            }
            default {
                if {[string is boolean -strict [set $option]]} {
                    set widget [::ttk::checkbutton $w.$name -text $description -variable $option -onvalue true -offvalue false]
                } elseif {[string first "\n" [set $option]] == -1} {
                    set widget [::ttk::frame $w.$name]
                    set label [::ttk::label $w.$name.label -text "$description :"]
                    set entry [::ttk::entry $w.$name.entry -textvariable $option]
                    pack $label $entry -side left -expand true -fill x -padx $::gui::padx -pady $::gui::pady -anchor nw
                } else {
                    set widget [::ttk::frame $w.$name]
                    set label [::ttk::label $w.$name.label -text "$description :"]
                    set frame [::ttk::frame $w.$name.f]
                    set text [::TracedText::TracedText $frame.text -textvariable $option -wrap none \
                          -yscrollcommand [list ::gui::set_scroll $frame.sy] \
                          -xscrollcommand [list ::gui::set_scroll $frame.sx]];
                    set sy [::ttk::scrollbar $frame.sy -orient vertical -command [list $text yview]]
                    set sx [::ttk::scrollbar $frame.sx -orient horizontal -command [list $text xview]]
    
                    grid $text -row 0 -column 0 -sticky nsew -padx $::gui::padx -pady $::gui::pady
                    grid $sy -row 0 -column 1 -sticky ns -padx $::gui::padx -pady $::gui::pady
                    grid $sx -row 1 -column 0 -sticky ew -padx $::gui::padx -pady $::gui::pady
                    grid rowconfigure $frame 0 -weight 1
                    grid columnconfigure $frame 0 -weight 1
                    #pack $sy -side right -fill y -padx $::gui::padx -pady $::gui::pady
                    #pack $sx -side bottom -fill x -padx $::gui::padx -pady $::gui::pady
                    #pack $text -expand true -fill both -padx $::gui::padx -pady $::gui::pady -anchor nw
                    pack $label $frame -side top -expand true -fill x -padx $::gui::padx -pady $::gui::pady
                }
            }
        }
        pack $widget -side top -expand false -fill x -padx $::gui::padx -pady $::gui::pady -anchor nw
    }

    proc set_scroll {w min max} {

        $w set $min $max
        if {$min == 0.0 && $max == 1.0} {
            grid forget $w
        } elseif {[grid info $w] == ""} {
            if {[$w cget -orient] == "vertical"} {
                grid $w -row 0 -column 1 -sticky ns -padx $::gui::padx -pady $::gui::pady
            } else {
                grid $w -row 1 -column 0 -sticky ew -padx $::gui::padx -pady $::gui::pady
            }
        }
    }

    proc build_task {w task file} {
        variable tasks

        set frame [::ttk::frame $w.$task]
        set check [::ttk::checkbutton $w.$task.check -text [get_task_description $file] -variable ::gui::tasks($task) -onvalue true -offvalue false -command [list ::gui::task_selected $w $task]]
        set button [::ttk::button $w.$task.button -text "Configure >>" -command [list ::gui::task_selected $w $task]]
        pack $check -side left -expand true -fill x -padx $::gui::padx -pady $::gui::pady
        pack $button -side right -expand false -fill x -padx $::gui::padx -pady $::gui::pady
        pack $frame -side top -expand true -fill x -padx $::gui::padx -pady $::gui::pady -anchor nw

        variable task_${task}_options
        set file [file join ${::TASKS_DIR} $task.tcl]
        if {![info exists task_${task}_options] } {
            array set ts [array get ::${task}::options]
            catch {unset ::${task}::options}
            uplevel #0 [list source $file]
            array set task_${task}_options [array get ::${task}::options]
            array set ::${task}::options [array get ts]
            foreach opt [array names task_${task}_options] {
                set task_${task}_options($opt) [set ::${task}::options($opt)]
            }
        }
    }

    proc build_tasks_options { task } {
        variable task_${task}_options
        foreach child [winfo children .middle] {
            destroy $child
        }
        set labelframe [::ttk::labelframe .middle.task -text "Task Options"]
        pack $labelframe -expand true -fill both -padx $::gui::padx -pady $::gui::pady
        set scrollframe [scrolledframe::scrolledframe $labelframe.f \
              -yscrollcommand [list ::gui::set_scroll $labelframe.sy] \
              -xscrollcommand [list ::gui::set_scroll $labelframe.sx]]
        set frame [$scrollframe getframe]
        set sy [::ttk::scrollbar $labelframe.sy -orient vertical \
              -command [list $scrollframe yview]]
        set sx [::ttk::scrollbar $labelframe.sx -orient horizontal \
              -command [list $scrollframe xview]]
        grid $scrollframe -row 0 -column 0 -sticky nsew -padx $::gui::padx -pady $::gui::pady
        grid $sy -row 0 -column 1 -sticky ns -padx $::gui::padx -pady $::gui::pady
        grid $sx -row 1 -column 0 -sticky ew -padx $::gui::padx -pady $::gui::pady
        grid rowconfigure $labelframe 0 -weight 1
        grid columnconfigure $labelframe 0 -weight 1

        set file [file join ${::TASKS_DIR} $task.tcl]
        foreach opt [get_sorted_options $file [array names task_${task}_options]] {
            build_option $frame $file $opt ::gui::task_${task}_options($opt)
        }
        # Force tasks option window to have the right size
        update
        set tasks_height [winfo reqheight $frame]
        set tasks_width [winfo reqwidth $frame]
        $scrollframe configure -height $tasks_height -width $tasks_width
    }

    proc button_hovered { w } {
        if {[$w cget -state] == "active"} {
            after 0 [list $w configure -state active]
        }
    }

    proc task_selected {w task} {
        foreach child [winfo children $w] {
            if {[winfo exists $child.button] } {
                $child.button configure -state normal
                bind $child.button <Leave> ""
            }
        }
        $w.$task.button configure -state active
        bind $w.$task.button <Leave> [list ::gui::button_hovered $w.$task.button]
        build_tasks_options $task

    }

    proc browse { type path filetypes extension title } {
        append filetypes {
            { "All Files" {*.*} }
        }

        if {$type == "open" } {
            # taken in part from aMSN
            if { ![info exists initialfile] || $initialfile == "" } {
                set initialfile ${::IN_FILE}
            }

            if { ![file exists $initialfile] } {
                set initialfile ""
                set file [tk_getOpenFile -defaultextension $extension -filetypes $filetypes -multiple false -parent $path -title $title]
            } else {
                set file [tk_getOpenFile -defaultextension $extension -filetypes $filetypes -initialfile $initialfile -multiple false -parent $path -title $title]
            }
        } else {
            set file [tk_getSaveFile -defaultextension $extension -filetypes $filetypes -initialfile ${::OUT_FILE}  -parent $path -title $title]
        }
        if {$file != ""} {
            $path delete 0 end
            $path insert 0 $file
        }
    }

    proc set_gui_state { state } {
        .left.files.input.entry configure -state $state
        .left.files.input.button configure -state $state
        .left.files.output.entry configure -state $state
        .left.files.output.button configure -state $state
        .right.build configure -state $state

        foreach child [winfo children .left.options] {
            if {[winfo exists $child.entry] } {
                $child.entry configure -state $state
            } else {
                $child configure -state $state
            }
        }
        foreach child [winfo children [.left.tasks.f getframe]] {
            if {[winfo exists $child.button] } {
                $child.check configure -state $state
                $child.button configure -state $state
                if {$state == "normal" && [bind $child.button] == "<Leave>"} {
                    $child.button configure -state active
                }
            }
        }
    }

    proc enable_gui { } {
        variable tasks

        pack .left -side left -expand false -fill y -padx $::gui::padx -pady $::gui::pady -before .middle
        set_gui_state normal
    }

    proc disable_gui { } {
        set_gui_state disabled

        pack forget .left
        foreach child [winfo children .middle] {
            destroy $child
        }

        text .middle.log -wrap none -bg black -fg green -yscrollcommand [list ::gui::set_scroll .middle.sy] \
               -xscrollcommand [list ::gui::set_scroll .middle.sx]
        ::ttk::scrollbar .middle.sy -orient vertical -command ".middle.log yview"
        ::ttk::scrollbar .middle.sx -orient horizontal -command ".middle.log xview"

        .middle.log tag configure warning -foreground red
        .middle.log tag configure info -foreground blue
        grid .middle.log -row 0 -column 0 -sticky nsew -padx $::gui::padx -pady $::gui::pady
        grid .middle.sy -row 0 -column 1 -sticky ns -padx $::gui::padx -pady $::gui::pady
        grid .middle.sx -row 1 -column 0 -sticky ew -padx $::gui::padx -pady $::gui::pady
        grid rowconfigure .middle 0 -weight 1
        grid columnconfigure .middle 0 -weight 1
    }

    proc build_mfw { } {
        variable tasks

        disable_gui


        set cmdline "$::argv0 \"${::IN_FILE}\" \"${::OUT_FILE}\""
        foreach {opt val} [array get ::options] {
            append cmdline " $opt \"$val\""
        }

        set selected_tasks [list]
        foreach task [array names tasks] {
            catch {unset ::${task}::options}
            if {$tasks($task)} {
                lappend selected_tasks $task
                variable task_${task}_options
                array set ::${task}::options [array get task_${task}_options]
                append cmdline " --[string map {_ -} $task]"
                foreach {opt val} [array get task_${task}_options] {
                    append cmdline " $opt \"$val\""
                }
            }
        }
        append cmdline " --gui false"

        print_log "Command line to use to repeat this process : \n$cmdline\n\n" info

        if {[catch {::build_mfw ${::IN_FILE} ${::OUT_FILE} ${selected_tasks}} res]} {
            log "Error running script: $res" 1
            tk_messageBox -default ok -message "FATAL ERROR: $res" -icon error
        } else {
            tk_messageBox -default ok -message "Modified Firmware Built successfully!" -icon info
        }
        enable_gui
    }

    proc print_log {msg {tag {}}} {
        if {[winfo exists .middle.log]} {
            .middle.log configure -state normal
            .middle.log insert end "$msg\n" $tag
            .middle.log configure -state disabled
            .middle.log yview end
        }
    }

    proc hijack_logs { } {
        rename ::log  ::log_orig

        proc ::log {msg {force 0}} {
            if {$force} {
                ::gui::print_log $msg warning
            } else {
                ::gui::print_log $msg
            }
            ::log_orig $msg $force
            update
        }
        rename ::die  ::die_orig

        proc ::die {message} {
            log "FATAL ERROR: $message" 1
            ::gui::print_log "See ${::LOG_FILE} for more info" warning
            ::gui::print_log "Last lines of log : " warning
            ::gui::print_log "*****************" warning
            catch {::gui::print_log [tail ${::LOG_FILE}] warning}
            ::gui::print_log "*****************" warning
            error $message
        }
        rename ::debug  ::debug_orig

        proc ::debug {msg} {
            update
            ::debug_orig $msg
        }
    }
}
