# /www/admin/file-manager/index.tcl

ad_page_contract {

    index page for file manager

    @author  Ron Henderson (ron@arsdigita.com)
    @created Tue May 30 22:15:57 2000
    @cvs-id  $Id$
} {
}

doc_return  200 text/html "
<html>
<head>
<title>File Manager</title>
</head>
<frameset cols=\"20%,*\">
<frame name=tree src=file-tree>
<frame name=list src=file-list>
</frameset>
</html>
"
