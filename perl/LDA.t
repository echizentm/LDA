#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok('LDA') };

test_01();
test_02();
test_03();
test_04();
test_05();

sub test_01 {
    note('check new()');

    my $lda = LDA->new();
    ok($lda, 'new()');
}

sub test_02 {
    note('check add()');

    my $lda = LDA->new();
    is($lda->add(), undef, 'add() with no params');
    ok($lda->add(
        data => [
            'apple',
            'orange',
        ]
    ), 'add() with valid data');
}

sub test_03 {
    note('check train()');

    my $lda = LDA->new();
    $lda->add(data => ['apple', 'orange', 'meron']);
    $lda->add(data => ['apple', 'iphone', 'mac']);
    ok($lda->train(), 'train()');
}

sub test_04 {
    note('check words_on_topic()');

    my $lda = LDA->new();
    is($lda->words_on_topic(), undef, 'words_on_topic() with no params');
    ok($lda->words_on_topic(topic => 0), 'words_on_topic() with valid data');
}

sub test_05 {
    note('check topics_on_document()');

    my $lda = LDA->new();
    is($lda->topics_on_document(), undef, 'topics_on_document() with no params');
    ok($lda->topics_on_document(document => 0), 'topics_on_document() with valid data');
}

done_testing();
