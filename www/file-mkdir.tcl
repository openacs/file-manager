# /www/admin/file-manager/file-mkdir.tcl

ad_page_contract {

    Add a new directory

    @author  ron@arsdigita.com
    @creation-date Fri May 26 07:14:13 2000
    @cvs-id  $Id$
} {
    {path:trim}
}

fm_check_permission

doc_return  200 text/html "
[ad_admin_header "File Manager"]

<h2> File Manager </h2>

[fm_admin_context_bar]

<hr>

<h3> Add subdirectory to [fm_linked_path $path] </h3>

<form method=post action=file-mkdir-2>
[export_form_vars path]
<table>

<tr>
<th>Title:</th>
<td><input type=text name=subdir size=20></td>
</tr>

<tr>
<td></td>
<td><input type=submit value=Create></td>
</tr>
</table>
</form>

[ad_admin_footer]
"