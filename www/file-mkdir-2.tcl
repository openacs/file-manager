# /www/admin/file-manager/file-mkdir-2.tcl

ad_page_contract {

    Create a subdirectory

    @author  ron@arsdigita.com
    @creation-date Fri May 26 07:19:06 2000
    @cvs-id  $Id$
} {
    {path:trim,notnull}
    {subdir:trim,notnull}
}

set errcnt 0
set errmsg ""

if ![fm_valid_filename_p $subdir] {
    incr   errcnt
    append errmsg "<li>Invalid file name (no spaces or /'s)"
}

if [empty_string_p $path] {
    incr   errcnt
    append errmsg "<li>You must specify a directory to create"
}

if {$errcnt} {
    ad_return_complaint $errcnt $errmsg
    ad_script_abort
}

if [catch {

    set  path  [file join $path $subdir]
    file mkdir $path

    if [ad_parameter VersionControlP file-manager 0] {
	vc_add $path
    }
    
} errmsg] {
    ad_return_complaint 1 "<li> The follow error occured: <br> $errmsg"
    ad_script_abort
}

ad_returnredirect "file-list?path=[file dirname $path]"


