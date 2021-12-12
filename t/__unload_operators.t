use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe '__unload_operators: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[EXCEPTION] ' => sub {
        it 'should confess if arg is not array' => sub {
            trap { Calc::__unload_operators( {}, '+' ) };

            like( $trap->die, qr/Argument must be array ref/ ) or diag( $trap->die );
        };

        it 'should confess if arg is not array' => sub {
            trap { Calc::__unload_operators( [], '<not_operator>' ) };

            like( $trap->die, qr/Argument must by operator lexeme/ ) or diag( $trap->die );
        };

    };

    describe '[BRANCH] ' => sub {

        it 'should not unload stack if not operator on top' => sub {
            my @stack = qw/ 4 4 4 4 /;

            my @result = Calc::__unload_operators( \@stack, '*' );

            cmp_deeply \@result, [];
            cmp_deeply \@stack, [qw/ 4 4 4 4 /];
        };

        it 'should not unload stack if operator in top, but priority of top lexeme less then priority of arg operator' => sub {
            my @stack = qw/ 4 4 4 - /;

            my @result = Calc::__unload_operators( \@stack, '*' );

            cmp_deeply \@result, [];
            cmp_deeply \@stack, [qw/ 4 4 4 - /];
        };

        it 'should unload operator from stack if operator in top, and priority of top lexeme more then priority of arg operator' => sub {
            my @stack = qw/ 4 4 4 * /;

            my @result = Calc::__unload_operators( \@stack, '-' );

            cmp_deeply \@result, ['*'];
            cmp_deeply \@stack, [qw/ 4 4 4 /];
        };

        it 'should unload operator from stack if operator in top, and priority of top lexeme same as priority of arg operator' => sub {
            my @stack = qw/ 4 4 4 - /;

            my @result = Calc::__unload_operators( \@stack, '+' );

            cmp_deeply \@result, ['-'];
            cmp_deeply \@stack, [qw/ 4 4 4 /];
        };

        it 'should unload more than one operator from stack if operator in top, and priority of top lexeme more then priority of arg operator' => sub {
            my @stack = qw| 4 / * * |;

            my @result = Calc::__unload_operators( \@stack, '-' );

            cmp_deeply \@result, [qw( * * / )];
            cmp_deeply \@stack, [qw/ 4 /];
        };

    };
};

runtests();
