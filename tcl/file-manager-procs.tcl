# /packages/file-manager/tcl/file-manager-procs.tcl

ad_library {

    Private tcl definitions for the file manager

    @author  Ron Henderson (ron@arsdigita.com)
    @creation-date Fri May 26 05:32:59 2000
    @cvs-id  $Id$
}

proc fm_pageroot_relative_path {path} {
    set match ""
    set local ""
    regexp "[ns_info pageroot](.+)" $path match local
    return $local
}

proc fm_acs_root_relative_path {path} {
    set match ""
    set relative ""
    regexp "[acs_root_dir](.+)" $path match relative
    return $relative
}

ad_proc fm_valid_filename_p { path } { 
    Returns 1 if $path is a valid file name (no spaces, & or leading /'s)
} {
    if [regexp {[ /&]} $path] {
	return 0
    } else {
	return 1
    }
}

ad_proc -private fm_check_permission {} { 
    Require that the user have sitewide admin
} { 
    permission::require_permission -object_id [site_node::get_element -url / -element package_id] -privilege admin
}


ad_proc fm_admin_context_bar {} {
    Returns a context bar that will break out of the frames
} {
    regsub -all "href" [ad_context_bar {File Manager}] "target=_top href" context_bar
    return $context_bar
}

ad_proc fm_options_list { args } {
    Returns an options list to be displayed in the upper-right part of the page
} {
    set choices [list]
    foreach arg $args {
	lappend choices "<a href=\"[lindex $arg 0]\">[lindex $arg 1]</a>"
    }

    if { [llength $choices] > 0 } {
	return "<table align=right><tr><td>[join $choices " | "]</td></tr></table>\n"
    } else {
	return ""
    }
}

proc fm_linked_path {path_full} {

    # Grab the path relative to the pageroot and create a linked list
    # of path components for the top of the directory listing

    set pageroot [ns_info pageroot]

    if [string equal -nocase $pageroot $path_full] {
        # we're at the top of the directory listing already
        return "Server Root"
    } else {
        # we're under the pageroot
        regexp "$pageroot/(.+)" $path_full match path

        set local ""
        set path_list   [list]
        set path_orig   [file split $path]
        set path_length [expr [llength $path_orig]-1]

        for { set i 0 } { $i < $path_length } { incr i } {
            set dir [lindex $path_orig $i]
            lappend path_list "$dir"
            set local [file join $local $dir]
        }
    }

    lappend path_list [file tail $path]
    return [join $path_list " / "]
}

# Checks for any function execution in an adp page

proc fm_adp_function_p {adp_page} {
    if {[ad_parameter BlockUserADPFunctionsP ADP 1] != 1} {
	return 0
    }
    if {[regexp {<%[^=](.*?)%>} $adp_page match function]} {
	set user_id [ad_get_user_id]
	ns_log warning "User: $user_id tried to include \n$function\nin an adp page"
	return 1
    } elseif {[regexp {<%=.*?(\[.*?)%>} $adp_page match function]} {
	set user_id [ad_get_user_id]
	ns_log warning "User: $user_id tried to include \n$function\nin an adp page"
	return 1
    } else {
	return 0
    }
}

ad_proc fm_managed_directories {} {

    Returns a list of directories relative to ROOT/www that will be
    accessible via file-manager.  All subdirectories are also managed
    (unless they're in the Ignore list).  This is a wrapper for the
    ManagedDirectories parameter that return a list of all directories
    if no explicit list is given.

} {
    set manage [ad_parameter "ManagedDirectories" "file-manager" ""]

    if ![empty_string_p $manage] {
	return [split $manage ","]
    } else {
	set files  [list]
	set ignore [split [ad_parameter Ignore file-manager "admin"] ","]
	foreach file [lsort [glob "[acs_root_dir]/www/*"]] {
	    set tail [file tail $file]
	    if {[lsearch $ignore $tail] != -1} {
		continue
	    }
	    if [file isdirectory $file] {
		lappend files $tail
	    }
	}
	return $files
    }
}