#!/usr/bin/perl
use strict;
use warnings;
use JSON::XS;
use LDA;

use constant {
    SAMPLE_SIZE    => 10,
    DOCUMENT_TIMES => 100,
    MAX_WORDS      => 5,
};

my $topic_size = shift @ARGV;

my $lda = LDA->new();
$lda->sample_size(SAMPLE_SIZE);
$lda->topic_size($topic_size);

while (my $line = <STDIN>) {
    my $obj = decode_json($line);
    for (1 .. DOCUMENT_TIMES) { $lda->add(%$obj) };
}
$lda->train();

for my $topic (0 .. ($topic_size - 1)) {
    my $words_on_topic = $lda->words_on_topic(topic => $topic);
    splice(@$words_on_topic, MAX_WORDS);
    print join("\n", "topic[$topic]", map { "$_->{word}\t$_->{prob}"; } @$words_on_topic)."\n\n";
}
