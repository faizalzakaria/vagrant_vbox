
#
# Configs
# 

$gerrit_version = '2.5'
$gerrit_group = 'gerrit2'
$gerrit_gid = '515'
$gerrit_user = 'gerrit2'
$gerrit_groups = 'gerrit2'
$gerrit_home = '/home/gerrit2'
$gerrit_uid = '515'
$gerrit_site_name = 'review_site'
$gerrit_database_type = 'pgsql'
$gerrit_java = 'openjdk-7-jdk'
$canonical_web_url = "http://gerrittest.com:8080/"
$httpd_listen_url = "http://*:8080/"
$sshd_listen_address = "*:29468"
$download_mirror      = 'http://gerrit.googlecode.com/files'
#$download_mirror      = 'http://updates.sdesigns.com/gerrit'
$email_format         = '{0}@blabla.com'

# not used, need to hash this using sha1
# $1$OPeeLkJz$jfxWJ1rsyx6.Mr2fZYPMB/
$password             = 'gerrit2'
