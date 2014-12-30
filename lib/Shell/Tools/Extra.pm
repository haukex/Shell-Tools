#!perl
package Shell::Tools::Extra;
use warnings;
use strict;

our $VERSION = '0.01';

=head1 Name

Shell::Tools::Extra - Perl extension to reduce boilerplate in Perl shell scripts (Extra modules)

=head1 Synopsis

 use Shell::Tools::Extra;    # is the same as the following:
 
 use Shell::Tools; # turns on warnings and strict and exports many funcs
 use Try::Tiny qw/try catch finally/;
 use Path::Class qw/dir file/;
 use File::pushd 'pushd';
 use File::Find::Rule ();
 
 # and
 use Shell::Tools::Extra  Shell => [ IPC_RUN3_SHELL_ARGS ];
 # is the same as
 use IPC::Run3::Shell IPC_RUN3_SHELL_ARGS;

=head1 Description

This module exports a collection of functions from selected Perl modules
from CPAN, in addition to those from L<Shell::Tools|Shell::Tools>.

=head1 Version

This document describes version 0.01 of Shell::Tools::Extra.

=head1 Exports

This module exports the following modules and functions.

Like L<Shell::Tools|Shell::Tools>,
each module has an L<Exporter|Exporter> tag that is the same name as the module.

=cut

## no critic (ProhibitConstantPragma)

use Carp;

require Shell::Tools;
sub import {  ## no critic (RequireArgUnpacking)
	for (my $i=0;$i<@_;$i++) {
		if ( $_[$i] && $_[$i] eq 'Shell' ) {
			_import_Shell((caller)[0], $_[$i+1]);
			splice @_, $i, 2;  $i--;
		}
	}
	goto &Shell::Tools::import;
}


=head2 L<IPC::Run3::Shell|IPC::Run3::Shell>

 use Shell::Tools  Shell => [ qw/echo cat/ ];
 use Shell::Tools  Shell => 'who';

The argument(s) will be passed through as the arguments to
L<IPC::Run3::Shell|IPC::Run3::Shell>'s import.
Note that C<Shell> must be followed by exactly one argument, either
a single scalar or an arrayref.

This module is optional: If no C<Shell> arguments are present in C<use>,
this module will not be loaded and it does not need to be installed.

=cut

sub _import_Shell {
	my ($destpack, $args) = @_;
	croak "no arguments for Shell import specified" unless $args;
	croak "arguments for Shell import must be an array ref or a scalar"
		if ref $args && ref $args ne 'ARRAY';
	require IPC::Run3::Shell;  # CPAN
	IPC::Run3::Shell->VERSION('0.52'); # for import_into support
	IPC::Run3::Shell->import_into($destpack, ref $args ? @$args : $args);
	return;
}


# now switch to Shell::Tools package so "use" statements will export to there
package Shell::Tools;  ## no critic (ProhibitMultiplePackages)
our @EXPORT;
our %EXPORT_TAGS;


=head2 L<Try::Tiny|Try::Tiny>

 try { die "foo" }
 catch { warn "caught error: $_\n" }  # not $@
 finally { print "finally" };

=cut

use constant _EXP_TRY_TINY => qw/try catch finally/;
use Try::Tiny _EXP_TRY_TINY;  # CPAN
push @EXPORT, _EXP_TRY_TINY;
$EXPORT_TAGS{"Try::Tiny"} = [_EXP_TRY_TINY];


=head2 L<Path::Class|Path::Class>

 my $dir      = dir('foo', 'bar');        # Path::Class::Dir object
 my $file     = file('bob', 'file.txt');  # Path::Class::File object
 # interfaces to File::Spec's tempdir and tempfile
 my $tempdir  = Path::Class::tempdir(CLEANUP=>1);   # isa Path::Class::Dir
 my ($fh,$fn) = $tempdir->tempfile(UNLINK=>1);      # $fn is NOT an object

(Note that L<Path::Class|Path::Class> may not work properly with Perl before v5.8.0.)

=cut

use constant _EXP_PATH_CLASS => qw/dir file/;
use Path::Class _EXP_PATH_CLASS;  # CPAN
push @EXPORT, _EXP_PATH_CLASS;
$EXPORT_TAGS{"Path::Class"} = [_EXP_PATH_CLASS];


=head2 L<File::pushd|File::pushd>

 {
     my $dir = pushd('/tmp');
     # working directory changed to /tmp
 }
 # working directory has reverted to previous

=cut

use constant _EXP_FILE_PUSHD => qw/pushd/;
use File::pushd _EXP_FILE_PUSHD;  # CPAN
push @EXPORT, _EXP_FILE_PUSHD;
$EXPORT_TAGS{"File::pushd"} = [_EXP_FILE_PUSHD];


=head2 L<File::Find::Rule|File::Find::Rule>

 my @files = File::Find::Rule->file->name('*.pm')->in(@INC);

=cut

use File::Find::Rule ();


1;
__END__

=head1 Author, Copyright, and License

Copyright (c) 2014 Hauke Daempfling (haukex@zero-g.net).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl 5 itself.

For more information see the L<Perl Artistic License|perlartistic>,
which should have been distributed with your copy of Perl.
Try the command "C<perldoc perlartistic>" or see
L<http://perldoc.perl.org/perlartistic.html>.

=cut

