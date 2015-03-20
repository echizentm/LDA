#!/usr/bin/perl
use strict;
use warnings;
use JSON::XS;
use LDA;

my $lda = LDA->new();

while (my $line = <STDIN>) {
    my $obj = decode_json($line);

    $lda->add(%$obj);
    print "add: ".(encode_json($obj))."\n";
}
$lda->train();
my $result = encode_json($lda->{documents});
$result =~ s/\],\[/\]\n\[/g;
print "documents: $result\n";
