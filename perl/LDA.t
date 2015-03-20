#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok('LDA') };

test_01();
test_02();
test_03();

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

done_testing();
