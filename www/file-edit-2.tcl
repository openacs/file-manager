# /www/admin/file-manager/file-edit-2.tcl

ad_page_contract {

    Process a file edit

    @author  ron@arsdigita.com
    @creation-date Fri May 26 06:47:06 2000
    @cvs-id  $Id$
} {
    {file_content:allhtml}
    {path:trim}
    {message:trim}
}

if [empty_string_p $message] {
    ad_return_complaint 1 "<li> You must enter a log message"
    ad_script_abort
}

# check to see if this is an adp page

if {[regexp {\.adp} $path]} {
    # Check it for functions 
    if {[fm_adp_function_p $file_content]} {
	ad_return_error "Permission Denied" "
	<P> We're sorry, but files edited with the file manager cannot
	have functions in them for security reasons. Only HTML and 
	<%= \$variable %> style code may be used."
        ad_script_abort
    }
}

set text $file_content

# for Windows
regsub -all "\r\n" $text "\n" text

# for Mac
regsub -all "\r" $text "\n" text

if [catch {
    puts [set fd [open $path w]] $text
    close $fd

    if [ad_parameter VersionControlP file-manager 0] {

	# get the editor's name and email address for the log
	set user_id [ad_verify_and_get_user_id]

	db_1row user_info {
            select pe.first_names || ' ' || pe.last_name as name, 
                   pa.email 
            from persons pe, parties pa 
            where pe.person_id=:user_id and pa.party_id=pe.person_id
	}

	# add the file (just in case) and commit the change
	vc_add    $path
	vc_commit $path "$name ($email) - $message"
    }
} errmsg] {

  doc_return 200 text/html "
  
  <p>An error occurred while writing the file:</p>
  
  <pre>
    $errmsg
  </pre>
  "
  ad_script_abort
}

ad_returnredirect "file-list?path=[file dirname $path]"


