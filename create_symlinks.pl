#!/usr/bin/perl -w
# create_symlinks.pl --- This script scans the git directory, creates directory tree and symlinks to all useful files.
# Author: Andrei Protasovitski <andrei.protasovitski@gmail.com>
# Created: 21 Dec 2008
# Version: 0.01

use warnings;
use strict;

use Getopt::Std;
use Symbol qw(qualify_to_ref);

# List of folders to skip (regexes)
my @skip_dirs = ( '^\.', '^samples$', '^t$' );

# List of files to skip (regexes)
my @skip_files =
  ( '^\.', '.*\.spec$', '.*\.PL$', '^MANIFEST', 'README', '^META\..*', '~$' );

my %opt = ();
getopts( 's:t:', \%opt );

my $source = $opt{s} || "Modules";
my $target = $opt{t} || "lib";

my $pwd = `pwd`;
chomp $pwd;

$source = "$pwd/$source" if $source !~ /^\//;
$target = "$pwd/$target" if $target !~ /^\//;

my $me = __FILE__;

#print $me, "\n$source\n$target\n$pwd";
#<>;

# add_file: adds files
sub add_files {

    my $source_dir = shift;
    my $file       = shift;
    my $omit       = shift;

    my $target_dir = $source_dir;
    $target_dir =~ s/^$source\/$omit/$target/;
    my $symlink     = "$target_dir/$file"; # symlink or directory to create
    my $source_file = "$source_dir/$file"; # file to link to or source directory

    # Check source file if it satisfy @skip_files regexes
    if ( -f $source_file ) {
        for my $f (@skip_files) {

            print "   ... Comparing file $file =~ /$f/ ... ";
            if ( $file =~ /$f/ ) {

                print "Skipped $source_file\n";
                return;
            }

            print "Passed $source_file\n";
        }
    }

    # Check source dir if it satisfy @skip_dirs regexes
    elsif ( -d $source_file ) {
        for my $d (@skip_dirs) {

            print "   ... Comparing dir $file =~ /$d/ ... ";
            if ( $file =~ /$d/ ) {

                print "Skipped $source_file)\n";
                return;
            }

            print "Passed $source_file\n";
        }
    }

    print "Adding: $symlink\n";
    print "  Creating $symlink\n";

    # If it's a directory
    if ( -d $source_file ) {

        # If target directory does not exist yet, create it
        unless ( -e $symlink ) {
            mkdir $symlink;
        }
        &scan_tree( $source_file, \&add_files, $omit );
    }

    # If it's a file
    elsif ( -f $source_file ) {

        # If target file does not exist, create the symlink
        unless ( -e $symlink ) {
            my $ln = `ln -s $source_file $symlink`;
        }

        # Otherwise "thow exception". :)
        else {
            die
"!!! Cannot create the symlink to $symlink from $source_file, because $symlink already exists!";
        }
    }

}

#}}}

#{{{  delete_file: delete file or directory
sub delete_files {

    my $dir  = shift;
    my $file = shift;

    return if $me =~ /(\/|\\)$file/;

    my $del = "$dir/$file";
    if ( -f $del || -l $del ) {
        print "Deleting file $del...";
        unlink $del;
        print " done.\n";
    }
    elsif ( -d $del ) {
        print "Deleting dir $file...";
        &scan_tree( $del, \&delete_files );
        rmdir $del;
        print " done.\n";
    }

}

# scan_tree: scans the directory, apply action to any file in the directory
sub scan_tree {

    my $dir    = shift;
    my $action = shift;
    my @other  = @_;

    local *DIR;

    print "Scanning $dir\n";
    opendir( DIR, $dir ) or die "Cannot open directory $dir: $!";

    my $file;
    while ( $file = readdir DIR ) {
        if ( $file =~ /^\.+$/ ) {
            print "(Skipping $dir/$file)\n";
            next;
        }
        $action->( $dir, $file, @other );
    }

    closedir DIR;
}

#  do_all: Does all
sub do_all {

    # Empty workin directory
    &scan_tree( $target, \&delete_files );

    # Adding files
    opendir( SOURCE, $source ) or die "Cannot open directory $source: $!";
    while ( my $sd = readdir SOURCE ) {
        next if $sd =~ /^\./;
        my $source_dir = "$source/$sd";
        next unless -d $source_dir;
        opendir( SD, $source_dir )
          or die "Cannot open directory $source_dir: $!";
        while ( my $sd1 = readdir SD ) {
            next if $sd1 =~ /^\./;
            my $source_dir1 = "$source_dir/$sd1";
            next unless -d $source_dir1;
            next unless $sd1 eq "lib";
            print "Processing folder : $source_dir1\n";
            &scan_tree( $source_dir1, \&add_files, "$sd/$sd1" );
        }
    }
    close SOURCE;
}

&do_all();

1;


__END__

=head1 NAME

create_symlinks.pl - Describe the usage of script briefly

=head1 SYNOPSIS

create_symlinks.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for create_symlinks.pl, 

=head1 AUTHOR

Andrei Protasovitski, E<lt>andrei.protasovitski@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Andrei Protasovitski

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
