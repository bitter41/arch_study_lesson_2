use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe '__convert_to_reverse_polish_notation: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[EXCEPTION] ' => sub {
        it 'should confess if arg is not string' => sub {
            trap { Calc::__convert_to_reverse_polish_notation( [] ) };

            like( $trap->die, qr/Argument must be string/ ) or diag( $trap->die );
        };

        it 'should confess if found not correct lexeme' => sub {

            Calc->expects('__has_any_wrong_lexemes')->returns(1)->once;

            trap { Calc::__convert_to_reverse_polish_notation( '2 + 3 xxxx' ) };

            like( $trap->die, qr/Found wrong lexeme in argument/ ) or diag( $trap->die );
        };
    };

    describe '[BRANCH] isolate check: ' => sub {

        it 'all input has not lexemes' => sub {
            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__split_expression')->returns(qw( x x x ))->once;
            Calc->expects('__is_lexeme')->returns(0)->exactly(3);
            Calc->expects('__unload_stack')->returns()->once;
            
            my @result = Calc::__convert_to_reverse_polish_notation( 'xxx' );

            cmp_deeply \@result, [];
        };

        it 'all input has only number lexemes' => sub {
            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__split_expression')->returns(qw( 3 3 3 ))->once;
            Calc->expects('__is_lexeme')->returns(1)->exactly(3);
            Calc->expects('__is_number')->returns(1)->exactly(3);
            Calc->expects('__unload_stack')->returns()->once;

            my @result = Calc::__convert_to_reverse_polish_notation( '333' );

            cmp_deeply \@result, [qw( 3 3 3 )];
        };

        it 'all input has only operator lexemes' => sub {
            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__split_expression')->returns(qw( + + + ))->once;
            Calc->expects('__is_lexeme')->returns(1)->exactly(3);
            Calc->expects('__is_number')->returns(0)->exactly(3);
            Calc->expects('__is_operator')->returns(1)->exactly(3);
            Calc->expects('__unload_operators')->returns('+')->exactly(3);
            Calc->expects('__push_to_stack')->with_deep('+')->exactly(3);
            Calc->expects('__unload_stack')->returns()->once;

            my @result = Calc::__convert_to_reverse_polish_notation( '+++' );

            cmp_deeply \@result, [qw( + + + )];
        };

        it 'all input has only open bracket lexemes' => sub {
            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__split_expression')->returns(qw| ( ( ( |)->once;
            Calc->expects('__is_lexeme')->returns(1)->exactly(3);
            Calc->expects('__is_number')->returns(0)->exactly(3);
            Calc->expects('__is_operator')->returns(0)->exactly(3);
            Calc->expects('__is_open_bracket')->returns(1)->exactly(3);
            Calc->expects('__push_to_stack')->with_deep('(')->exactly(3);
            Calc->expects('__unload_stack')->returns()->once;

            my @result = Calc::__convert_to_reverse_polish_notation( '(((' );

            cmp_deeply \@result, [];
        };

        it 'all input has only close bracket lexemes' => sub {
            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__split_expression')->returns(qw| ) ) ) |)->once;
            Calc->expects('__is_lexeme')->returns(1)->exactly(3);
            Calc->expects('__is_number')->returns(0)->exactly(3);
            Calc->expects('__is_operator')->returns(0)->exactly(3);
            Calc->expects('__is_open_bracket')->returns(0)->exactly(3);
            Calc->expects('__is_close_bracket')->returns(1)->exactly(3);
            Calc->expects('__unload_stack_to_open_bracket')->returns(')')->exactly(3);
            Calc->expects('__unload_stack')->returns()->once;

            my @result = Calc::__convert_to_reverse_polish_notation( ')))' );

            cmp_deeply \@result, [qw| ) ) ) |];
        };
    };

    describe '[SUCCESS] ' => sub {
        my @is_number_mock;
        my @is_operator_mock;
        my @is_open_bracket_mock;
        my @is_close_bracket_mock;
        my @stack;

        before each => sub {
            @is_number_mock        = (0,1,0,1,0,0,1,0,1);
            @is_operator_mock      = (0,  1,  0,1,  1  );
            @is_open_bracket_mock  = (1,      0,       );
            @is_close_bracket_mock = (        1,       );
            @stack = ();

            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__is_lexeme')->returns(1)->exactly(9);
            Calc->expects('__is_number')->returns(
                sub {
                    shift @is_number_mock;
                }
            )->exactly(9);
            Calc->expects('__is_operator')->returns(
                sub {
                    shift @is_operator_mock;
                }
            )->exactly(5);
            Calc->expects('__is_open_bracket')->returns(
                sub {
                    shift @is_open_bracket_mock;
                }                
            )->exactly(2);
            Calc->expects('__is_close_bracket')->returns(
                sub {
                    shift @is_close_bracket_mock;
                }   
            )->exactly(1);

            Calc->expects('__push_to_stack')->returns(sub { push @stack, $_[1]; })->exactly(4);
            Calc->expects('__unload_stack')->returns()->once;
        };


        it 'base check stack' => sub {
            Calc->expects('__split_expression')->returns(qw| ( 1 + 2 ) * 4 + 3 |)->once;
            Calc->expects('__unload_operators')->returns('<unload_operators_call>')->exactly(3);
            Calc->expects('__unload_stack_to_open_bracket')->returns('<some_unload_result>')->once;

            Calc::__convert_to_reverse_polish_notation( '(1 + 2) * 4 + 3' );

            cmp_deeply(\@stack, [qw/ ( + * + /]);
        };

        it 'base check operations in result' => sub {
            Calc->expects('__split_expression')->returns(qw| ( 1 + 2 ) * 4 + 3 |)->once;
            Calc->expects('__unload_operators')->returns('<unload_operators_call>')->exactly(3);
            Calc->expects('__unload_stack_to_open_bracket')->returns('<some_unload_stack_result>')->once;

            my @result = Calc::__convert_to_reverse_polish_notation( '(1 + 2) * 4 + 3' );

            cmp_deeply \@result, [
                1,
                '<unload_operators_call>',
                2,
                '<some_unload_stack_result>',
                '<unload_operators_call>',
                4,
                '<unload_operators_call>',
                3
            ];

        };

        it 'base check result' => sub {
            Calc->expects('__split_expression')->returns(qw| ( 1 + 2 ) * 4 + 3 |)->once;
            Calc->expects('__unload_operators')->returns(
                sub {
                    my @result = ();
                    while (@stack) {
                        last if $stack[-1] ne '*';

                        push @result, pop @stack;
                    }

                    return @result;
                }
            )->exactly(3);
            Calc->expects('__unload_stack_to_open_bracket')->returns(
                sub {
                    my @result = ();
                    while (@stack) {
                        my $lexeme = pop @stack;
                        last if $lexeme eq '(';
                        push @result, $lexeme;
                    }

                    return @result;
                }
            )->once;
            my @result = Calc::__convert_to_reverse_polish_notation( '(1 + 2) * 4 + 3' );

            cmp_deeply \@result, [qw( 1 2 + 4 * 3 )];
        };

    };
};

runtests();
