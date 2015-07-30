#!/user/bin/perl

use Modern::Perl;

#use Data::Random::WordList;
use Data::Dumper;

use C4::Context;
use Koha::Database;

our $dbh    = C4::Context->dbh();
our $schema = Koha::Database->new()->schema();
my $rs = $schema->resultset('Borrower');

my @columns = $rs->result_source->columns;
@columns = grep( !/borrowernumber/, @columns );
@columns = grep( !/cardnumber/,     @columns );

say "Starting...";
while ( my $b = $rs->next() ) {
    map { $b->set_column( $_ => get_random($_) ) } @columns;
    $b->update();
    say "Updated borrower " . $b->borrowernumber();
}

sub get_random {
    my ($column) = @_;

    my $query = "SELECT $column FROM borrowers ORDER BY RAND() LIMIT 1";
    my $sth   = $dbh->prepare($query);
    $sth->execute();
    my $hr    = $sth->fetchrow_hashref();
    my $value = $hr->{$column};
    return $value;
}
