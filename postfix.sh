#!/bin/bash
# PostFix Auto Installer 
# Created by Teguh Aprianto
# https://bukancoder | https://teguh.co

IJO='\e[38;5;82m'
MAG='\e[35m'
RESET='\e[0m'

echo -e "$IJO                                                                                   $RESET"
echo -e "$IJO __________       __                    $MAG _________            .___             $RESET"
echo -e "$IJO \______   \__ __|  | _______    ____   $MAG \_   ___ \  ____   __| _/___________  $RESET"
echo -e "$IJO  |    |  _/  |  \  |/ /\__  \  /    \  $MAG /    \  \/ /  _ \ / __ |/ __ \_  __ \ $RESET"
echo -e "$IJO  |    |   \  |  /    <  / __ \|   |  \ $MAG \     \___(  <_> ) /_/ \  ___/|  | \/ $RESET"
echo -e "$IJO  |______  /____/|__|_ \(____  /___|  / $MAG  \______  /\____/\____ |\___  >__|    $RESET"
echo -e "$IJO        \/           \/     \/     \/   $MAG        \/            \/    \/         $RESET"
echo -e "$IJO ---------------------------------------------------------------------------       $RESET"
echo -e "$IJO |$MAG                        PostFix Auto Installer                           $IJO| $RESET"
echo -e "$IJO ---------------------------------------------------------------------------       $RESET"
echo -e "$IJO |$IJO                               Created by                                $IJO| $RESET"
echo -e "$IJO |$MAG                             Teguh Aprianto                              $IJO| $RESET"
echo -e "$IJO ---------------------------------------------------------------------------       $RESET"
echo ""

echo -e "$MAG--=[ To start install PostFix and Cyrus, press any key to continue ]=--$RESET"
read answer 

echo -e "$MAG--=[ Adding domain for mail server ]=--$IJO"
    domain="yourdomain.com"
	read -p "Domain for email : " domain
	if [ "$domain" = "" ]; then
		domain="yourdomain.com"
	fi
	echo "---------------------------"
	echo "Domain : $domain"
	echo "---------------------------" 
	
echo
echo

echo -e "$MAG--=[ Username for email ]=--$IJO"
    username="bukancoder"
    read -p "Domain for email : " username
    if [ "$username" = "" ]; then
        username="bukancoder.com"
    fi
    echo "---------------------------"
    echo "Email : $username@$domain"
    echo "---------------------------" 
    
echo
echo

echo -e "$MAG--=[ Installing PostFix and Cyrus ]=--$IJO"
yum -y install postfix
yum -y install cyrus-sasl
yum -y install cyrus-imapd
echo
echo
echo -e "$MAG--=[ Config PostFix for domain $IJO $domain $MAG]=--$IJO"
rm -rf /etc/postfix/main.cf
myhostname='$myhostname'
cat >/etc/postfix/main.cf<<eof
$alf
soft_bounce             = no
queue_directory         = /var/spool/postfix
command_directory       = /usr/sbin
daemon_directory        = /usr/libexec/postfix
mail_owner              = postfix

# The default_privs parameter specifies the default rights used by
# the local delivery agent for delivery to external file or command.
# These rights are used in the absence of a recipient user context.
# DO NOT SPECIFY A PRIVILEGED USER OR THE POSTFIX OWNER.
#
#default_privs = nobody

myhostname              = $domain 
mydomain                = $domain

mydestination           = $myhostname, localhost
unknown_local_recipient_reject_code = 550

mynetworks_style        = host
mailbox_transport       = lmtp:unix:/var/lib/imap/socket/lmtp
local_destination_recipient_limit       = 300
local_destination_concurrency_limit     = 5
recipient_delimiter=+

virtual_alias_maps      = hash:/etc/postfix/virtual

header_checks           = regexp:/etc/postfix/header_checks
mime_header_checks      = pcre:/etc/postfix/body_checks
smtpd_banner            = $myhostname

debug_peer_level        = 2
debugger_command =
         PATH=/bin:/usr/bin:/usr/bin:/usr/X11R6/bin
         xxgdb $daemon_directory/$process_name $process_id & sleep 5

sendmail_path           = /usr/sbin/sendmail.postfix
newaliases_path         = /usr/bin/newaliases.postfix
mailq_path              = /usr/bin/mailq.postfix
setgid_group            = postdrop
html_directory          = no
manpage_directory       = /usr/share/man
sample_directory        = /usr/share/doc/postfix-2.3.3/samples
readme_directory        = /usr/share/doc/postfix-2.3.3/README_FILES

smtpd_sasl_auth_enable          = yes
smtpd_sasl_application_name     = smtpd
smtpd_recipient_restrictions    = permit_sasl_authenticated,
                                  permit_mynetworks,
                                  reject_unauth_destination,
                                  reject_invalid_hostname,
                                  reject_non_fqdn_hostname,
                                  reject_non_fqdn_sender,
                                  reject_non_fqdn_recipient,
                                  reject_unknown_sender_domain,
                                  reject_unknown_recipient_domain,
                                  reject_unauth_pipelining,
                                  reject_rbl_client zen.spamhaus.org,
                                  reject_rbl_client bl.spamcop.net,
                                  reject_rbl_client dnsbl.njabl.org,
                                  reject_rbl_client dnsbl.sorbs.net,
                                  permit

smtpd_sasl_security_options     = noanonymous
smtpd_sasl_local_domain         = 
broken_sasl_auth_clients        = yes

smtpd_helo_required             = yes 


eof
echo
echo

echo -e "$MAG--=[ Configure virtual PostFix for domain $IJO $domain $MAG ]=--$IJO"
rm -rf /etc/postfix/virtual
cat >/etc/postfix/virtual<<eof
$alf
$username@$domain   $username\@$domain

eof
postmap /etc/postfix/virtual 
touch /etc/postfix/body_checks 
echo
echo

echo -e "$MAG--=[ Configure Cyrus ]=--$IJO"
rm -rf /etc/sasl2/smtpd.conf
cat >/etc/sasl2/smtpd.conf<<eof
$alf
pwcheck_method: auxprop
auxprop_plugin: sasldb
mech_list: PLAIN LOGIN CRAM-MD5 DIGEST-MD5 

eof
echo
echo

echo -e "$MAG--=[ Configure the Cyrus file ]=--$IJO"
rm -rf /etc/imapd.conf
cat >/etc/imapd.conf<<eof
$alf
virtdomains:        userid
defaultdomain:      $domain
servername:         $domain
configdirectory:    /var/lib/imap
partition-default:  /var/spool/imap
admins:         cyrus
sievedir:       /var/lib/imap/sieve
sendmail:       /usr/sbin/sendmail.postfix
hashimapspool:      true
allowanonymouslogin:    no
allowplaintext:     yes
sasl_pwcheck_method:    auxprop
sasl_mech_list:     CRAM-MD5 DIGEST-MD5 PLAIN
tls_cert_file:      /etc/pki/cyrus-imapd/cyrus-imapd.pem
tls_key_file:       /etc/pki/cyrus-imapd/cyrus-imapd.pem
tls_ca_file:        /etc/pki/tls/certs/ca-bundle.crt

autocreatequota:        -1
createonpost:           yes
autocreateinboxfolders:     spam
autosubscribeinboxfolders:  spam 

eof
echo
echo


echo -e "$MAG--=[ Install Mail Client ]=--$IJO"
yum -y install mailx
echo
echo


echo -e "$MAG--=[ Test to send email ]=--$IJO"
read -p "Test send email to? Paste your email : " email
    echo "---------------------------"
    echo "Email : $email"
    echo "---------------------------"

mail -s "Test Send Email" $email <<< "Just test bro"
echo -e "$MAG Test email has been sent to email $IJO $email $MAG please check your inbox or your spam folder $IJO"


echo
echo -e "$MAG--=[Done! Postfix for domain $IJO http://$domain $MAG has been installed on your server $MAG]=--$IJO"

