use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe '__push_to_stack: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[EXCEPTION] ' => sub {
        it 'should confess if arg is not array' => sub {
            trap { Calc::__push_to_stack( {} ) };

            like( $trap->die, qr/Argument must be array ref/ ) or diag( $trap->die );
        };
    };

    describe '[BRANCH] ' => sub {

        it 'should push lexeme to stack' => sub {
            my @stack = ();

            Calc::__push_to_stack( \@stack, 'some_lexeme' );

            cmp_deeply(\@stack, ['some_lexeme']);
        };

        it 'should push lexemes to stack in right order' => sub {
            my @stack = ();

            Calc::__push_to_stack( \@stack, 'some_lexeme' );
            Calc::__push_to_stack( \@stack, 'some_lexeme1' );
            Calc::__push_to_stack( \@stack, 'some_lexeme2' );

            cmp_deeply(\@stack, ['some_lexeme', 'some_lexeme1', 'some_lexeme2']);
        };

    };
};

runtests();
