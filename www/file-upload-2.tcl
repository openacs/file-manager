# /www/admin/file-manager/file-upload-2.tcl

ad_page_contract {

    Process a file upload

    @author  ron@arsdigita.com
    @creation-date Fri May 26 06:39:29 2000
    @cvs-id  $Id$
} {
    {path:trim,notnull}
    {message:trim,notnull}
    {title:trim,notnull}
}

fm_check_permission

set the_file [ns_queryget the_file.tmpfile]

# Make sure the incoming filename is valid

if ![fm_valid_filename_p $title] {
    ad_return_complaint "Error" "<li>Invalid file name (no spaces, & or /'s)"
    ad_script_abort
}

if {![empty_string_p $title] && [empty_string_p [file ext $title]]} {
    ad_return_complaint "Error" "
    <li>The title you supply must have one of the following extensions:<br>
    [ad_parameter Extensions file-manager]"
    ad_script_abort
}

# Done with error checking

set path [file join $path $title]

# Check the file type

set file_type [exec file $the_file] 

# If the file is text then read it, strip carriage returns,
# and write to the destination path

if {[regexp -nocase -- {\.adp} $path]} {
    if [catch {

	set fd [open $the_file r]
	set text [read $fd]
	close $fd
	
    } errmsg] {

	doc_return  200 text/html "
	
	<p>An error occurred with the file upload:</p>
	
	<pre>$errmsg</pre>
	"
        ad_script_abort
    }
    
    if {[fm_adp_function_p $text]} {
	ad_return_error "Permission Denied" "
	<P>We're sorry, but files edited with the file manager cannot
	have functions in them for security reasons. Only HTML and 
	<%= \$variable %> style code may be used."
        ad_script_abort
    }
} elseif [regexp {text} $file_type] {

    if [catch {

	set fd [open $the_file r]
	set text [read $fd]
	close $fd
	
    } errmsg] {

	doc_return 200 text/html "
	
	<p>An error occurred with the file upload:</p>
	
	<pre>$errmsg</pre>
	"
        ad_script_abort
    }
    
    # for Windows
    regsub -all "\r\n" $text "\n" text
    
    # for Mac
    regsub -all "\r" $text "\n" text
    
    set fd [open $path w]
    puts  $fd $text
    close $fd
    
} else {
    # if the file is binary just copy it
    ns_cp $the_file $path
}

# Register what we did with the version control system if necessary

if [ad_parameter VersionControlP file-manager 0] {

    # get the editor's name and email address for the log
    acs_user::get -user_id [ad_conn user_id] -array user_info

    # add the file (just in case) and commit the change
    vc_add    $path
    vc_commit $path "$user_info(name) ($user_info(email)) - $message"
}

ad_returnredirect "file-list?path=[file dirname $path]"

