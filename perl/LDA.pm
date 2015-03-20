package LDA;
use strict;
use warnings;
use parent qw/Class::Accessor::Fast/;
use List::Util;
use constant {
    DEFAULT_SAMPLE_SIZE => 1000,
    DEFAULT_TOPIC_SIZE  => 2,
    DEFAULT_ALPHA       => 1,
    DEFAULT_BETA        => 1,

};

__PACKAGE__->mk_accessors(qw/sample_size/);
__PACKAGE__->mk_accessors(qw/topic_size/);
__PACKAGE__->mk_accessors(qw/alpha/);
__PACKAGE__->mk_accessors(qw/beta/);
__PACKAGE__->mk_accessors(qw/documents/);

sub new {
    my ($class) = @_;
    return $class->SUPER::new({
        sample_size        => DEFAULT_SAMPLE_SIZE,
        topic_size         => DEFAULT_TOPIC_SIZE,
        alpha              => DEFAULT_ALPHA,
        beta               => DEFAULT_BETA,
        documents          => [],

        document_topic_map => {},
        topic_word_map     => {},
        document_map       => {},
        topic_map          => {},
        word_map           => {},
    });
}

sub add {
    my ($self, %args) = @_;
    return unless (__is_valid_data($args{data}));

    my $document_id = @{$self->documents};
    my @data_list = map {
        { document => $document_id, topic => int(rand($self->topic_size)), word => $_ }
    } @{$args{data}};

    for my $data (@data_list) {
        $self->_increase_map($document_id, $data->{topic}, $data->{word});
    }

    push(@{$self->documents}, \@data_list);
    return 1;
}

sub train {
    my ($self, %args) = @_;

    for (1 .. $self->sample_size) {
        @{$self->documents} = List::Util::shuffle(@{$self->documents});
        for my $document (@{$self->documents}) {
            for my $data (@$document) {
                $self->_decrease_map($data->{document}, $data->{topic}, $data->{word});
                $data->{topic} = $self->_sample_topic($data->{document}, $data->{word});
                $self->_increase_map($data->{document}, $data->{topic}, $data->{word});
            }
        }
    }
    return 1
}

sub _sample_topic {
    my ($self, $document, $word) = @_;

    my @cum_dists;
    my $cum_dist = 0;
    my $word_size = keys %{$self->{word_map}};
    for my $topic (0 .. ($self->topic_size - 1)) {
        $self->{document_topic_map}{$document}{$topic} //= 0;
        $self->{topic_word_map}{$topic}{$word}         //= 0;

        $cum_dist += (
              ($self->{document_topic_map}{$document}{$topic} + $self->alpha)
            / ($self->{document_map}{$document} + $self->topic_size * $self->alpha)
            * ($self->{topic_word_map}{$topic}{$word} + $self->beta)
            / ($self->{topic_map}{$topic} + $word_size * $self->beta)
        );
        push(@cum_dists, $cum_dist);
    }

    my $sampled_dist = rand($cum_dist);
    for my $topic (0 .. ($self->topic_size - 1)) {
        return $topic if ($sampled_dist < $cum_dists[$topic]);
    }
    return ($self->topic_size - 1);
}

sub _increase_map {
    my ($self, $document, $topic, $word) = @_;

    $self->{document_topic_map}{$document}{$topic}++;
    $self->{topic_word_map}{$topic}{$word}++;
    $self->{document_map}{$document}++;
    $self->{topic_map}{$topic}++;
    $self->{word_map}{$word}++;
}

sub _decrease_map {
    my ($self, $document, $topic, $word) = @_;
    $self->{document_topic_map}{$document}{$topic}--;
    $self->{topic_word_map}{$topic}{$word}--;
    $self->{document_map}{$document}--;
    $self->{topic_map}{$topic}--;
    $self->{word_map}{$word}--;
}

sub __is_valid_data {
    my ($data) = @_;

    return unless ($data);
    return (ref($data) eq 'ARRAY') ? 1 : 0;
}

1;
