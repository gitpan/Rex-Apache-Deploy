#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

=head1 NAME

Rex::Apache::Deploy - Deploy module for Rex

=head1 DESCRIPTION

This is a (R)?ex module to ease the deployments of Tomcat, Perl, Rails, PHP or other languages.

You can find examples and howtos on L<http://rexify.org/>

=head1 GETTING HELP

=over 4

=item * Web Site: L<http://rexify.org/>

=item * IRC: irc.freenode.net #rex

=back

=head1 DEPENDENCIES

=over 4

=item *

L<Rex>

=back

=head1 SYNOPSIS

 use Rex::Apache::Deploy Symlink;
   
 deploy_to "/var/deploy";
   
 document_root "/var/www/myhost/htdocs";
   
 generate_deploy_directory sub {
    my ($file) = @_;
    $file =~ m/-(\d+\.\d+\.\d+)\.tar\.gz$/;
    return $1;
 };
   
 desc "Deploy to Apache";
 task "deploy", group => "frontend", sub {
    deploy "mypkg-1.0.1.tar.gz";
 };


=head1 DEPLOY METHODS

=over 4

=item Symlink

This method will upload your package (*.tar.gz, *.tar.bz2 or *.zip) all you servers and extract it in the directory you specified with I<deploy_to> concatenated with the result of I<generate_deploy_directory>. After that it will create a symlink from I<document_root> to this new directory.

 deploy_to "/var/deploy";
 document_root "/var/www";
 generate_deploy_directory sub { return "1.0"; };

This will upload the file to I</var/deploy/1.0> and create a symlink from I</var/www> to I</var/deploy/1.0>.

=item Tomcat

This method is for Tomcat deployments. You need to have the Tomcat Manage application running on your Tomcat servers. It will upload your package to I</tmp/some-random-chars.war>, call the Tomcat Manager to undeploy the current context and deploy the new war archive. After that it will delete the uploaded temporary war file.

 context_path "/myapp";
     
 task "deploy", group => "middleware", sub {
     deploy "myapp.war",
         username    => "manager-user",
         password    => "manager-password",
         port        => 8080,
         manager_url =>  "/manager";
 };

This will deploy I<myapp.war> to the tomcat listening on port I<8080> with the manager application found under I<http://the-server:8080/manager>.

=back

=cut


package Rex::Apache::Deploy;

use strict;
use warnings;

use Data::Dumper;

our $VERSION = '0.5.0';

sub import {

   my ($call_class) = caller;

   die("Invalid input format") unless($_[1] =~ m/^[a-z0-9_]+$/i);

   eval "use $_[0]::$_[1] '$call_class';";

}

1;
