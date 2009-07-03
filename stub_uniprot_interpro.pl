#!/usr/bin/perl

use strict;
use warnings;

use Bio::SeqIO;
use Data::Dumper;
use DBI;

my $file = 'load_seqdb_test.txt'; 
my $inseq = Bio::SeqIO->new(-file   => "<$file", -format => "swiss");

my $dbh = DBI->connect( "dbi:mysql:biosql:localhost:3306", 'root', 'root') or die "Could not connect.";

while ( my $seq = $inseq->next_seq ) {
	my $protein_ids = {
		uniprot_number => $seq->accession_number,
		uniprot_id	   => $seq->id,
	};

	# Pull the dblink annotations
	my @annotations_dblink = $seq->annotation->get_Annotations( q{dblink} );

	foreach my $annotation ( @annotations_dblink ) {
		my @dblinks = $annotation->hash_tree();

		foreach my $dblink ( @dblinks ) {
			if ( $dblink->{database} eq 'InterPro' ) {
				$protein_ids->{interpro_entry} = $dblink->{primary_id};
				$protein_ids->{interpro_domain} = $dblink->{optional_id};
			}
    	}
	}
	
	print Dumper $protein_ids;
}

exit;
