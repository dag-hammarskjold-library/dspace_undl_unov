#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';
use lib 'c:\drive\modules';

package main;
use Data::Dumper;
$Data::Dumper::Indent = 1;
use Getopt::Std;
use Get::DLS;

RUN: {
	MAIN(options());
}

sub options {
	my $opts = {
		'h' => 'help',
		'u:' => 'DLS username',
		'p:' => 'DLS password',
		'd:' => 'dspace file',
		'o:' => 'out file'
	};
	getopts ((join '',keys %$opts), \my %opts);
	if ($opts{h}) {
		say "$_ - $opts->{$_}" for keys %$opts;
		exit; 
	}
	return \%opts;
}

sub MAIN {
	my $opts = shift;
	
	my $get = Get::DLS->new;
	open my $dspace,'<',$opts->{d};
	my @results;
	while (<$dspace>) {
		chomp;
		my @row = split "\t";
		my @syms = split '\|\|', $row[1];
		my $id;
		for my $sym (@syms) {
			$get->iterate (
				'191__a' => $sym,
				callback => sub {
					my $record = shift;
					$id = $record->id;
				}
			);
			$id ||= 'NOT IN DLS';
			push @results, [$sym, $id];
		}
	}
	open my $out,'>',$opts->{o};
	say {$out} join "\t", @$_ for @results;
}

__END__