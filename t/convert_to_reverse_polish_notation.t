use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe 'convert_to_reverse_polish_notation: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[EXCEPTION] ' => sub {
        it 'should confess if arg is not string' => sub {
            trap { Calc::convert_to_reverse_polish_notation( [] ) };

            like( $trap->die, qr/Argument must be string/ ) or diag( $trap->die );
        };

        it 'should confess if found not correct lexeme' => sub {

            Calc->expects('__has_any_wrong_lexemes')->returns(1)->once;

            trap { Calc::convert_to_reverse_polish_notation( '2 + 3 xxxx' ) };

            like( $trap->die, qr/Found wrong lexeme in argument/ ) or diag( $trap->die );
        };
    };

    describe '[BRANCH] isolate check: ' => sub {

        it 'all input has not lexemes' => sub {
            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__is_lexeme')->returns(0)->exactly(3);

            my $result = Calc::convert_to_reverse_polish_notation( 'xxx' );

            is $result, '';
        };

        it 'all input has only number lexemes' => sub {
            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__is_lexeme')->returns(1)->exactly(3);
            Calc->expects('__is_number')->returns(1)->exactly(3);

            my $result = Calc::convert_to_reverse_polish_notation( '333' );

            is $result, '3 3 3 ';
        };

        it 'all input has only operator lexemes' => sub {
            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__is_lexeme')->returns(1)->exactly(3);
            Calc->expects('__is_number')->returns(0)->exactly(3);
            Calc->expects('__is_operator')->returns(1)->exactly(3);
            Calc->expects('__unload_operators')->returns('-')->exactly(3);
            Calc->expects('__push_to_stack')->with_deep('+')->exactly(3);

            my $result = Calc::convert_to_reverse_polish_notation( '+++' );

            is $result, '---';
        };

        it 'all input has only open bracket lexemes' => sub {
            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__is_lexeme')->returns(1)->exactly(3);
            Calc->expects('__is_number')->returns(0)->exactly(3);
            Calc->expects('__is_operator')->returns(0)->exactly(3);
            Calc->expects('__is_open_bracket')->returns(1)->exactly(3);
            Calc->expects('__push_to_stack')->with_deep('(')->exactly(3);

            my $result = Calc::convert_to_reverse_polish_notation( '(((' );

            is $result, '';
        };

        it 'all input has only close bracket lexemes' => sub {
            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__is_lexeme')->returns(1)->exactly(3);
            Calc->expects('__is_number')->returns(0)->exactly(3);
            Calc->expects('__is_operator')->returns(0)->exactly(3);
            Calc->expects('__is_open_bracket')->returns(0)->exactly(3);
            Calc->expects('__is_close_bracket')->returns(1)->exactly(3);
            Calc->expects('__unload_stack')->returns(')')->exactly(3);

            my $result = Calc::convert_to_reverse_polish_notation( ')))' );

            is $result, ')))';
        };
    };

    describe '[SUCCESS] ' => sub {
        my @is_number_mock;
        my @is_operator_mock;
        my @is_open_bracket_mock;
        my @is_close_bracket_mock;
        my @stack;

        before each => sub {
            @is_number_mock        = (0,1,0,0,0,1,0,0,0,0,1,0,0,0,1);
            @is_operator_mock      = (0,  0,1,0,  0,0,1,0,  0,1,0  );
            @is_open_bracket_mock  = (1,  0,  0,  0,0,  0,  0,  0  );
            @is_close_bracket_mock = (    0,  0,  1,0,  0,  0,  0  );
            @stack = ();

            Calc->expects('__has_any_wrong_lexemes')->returns(0)->once;
            Calc->expects('__is_lexeme')->returns(1)->exactly(15);
            Calc->expects('__is_number')->returns(
                sub {
                    shift @is_number_mock;
                }
            )->exactly(15);
            Calc->expects('__is_operator')->returns(
                sub {
                    shift @is_operator_mock;
                }
            )->exactly(11);
            Calc->expects('__is_open_bracket')->returns(
                sub {
                    shift @is_open_bracket_mock;
                }                
            )->exactly(8);
            Calc->expects('__is_close_bracket')->returns(
                sub {
                    shift @is_close_bracket_mock;
                }   
            )->exactly(7);

            Calc->expects('__push_to_stack')->returns(sub { push @stack, $_[1]; })->exactly(4);
        };


        it 'base check stack' => sub {
            Calc->expects('__unload_operators')->returns('<unload_operators_call>')->exactly(3);
            Calc->expects('__unload_stack')->returns('<some_unload_result>')->once;

            my $result = Calc::convert_to_reverse_polish_notation( '(1 + 2) * 4 + 3' );

            cmp_deeply(\@stack, [qw/ ( + * + /]);
        };

        it 'base check operations in result' => sub {
            Calc->expects('__unload_operators')->returns('<unload_operators_call>')->exactly(3);
            Calc->expects('__unload_stack')->returns('<some_unload_stack_result>')->once;

            my $result = Calc::convert_to_reverse_polish_notation( '(1 + 2) * 4 + 3' );

            is $result, '1 <unload_operators_call>2 <some_unload_stack_result><unload_operators_call>4 <unload_operators_call>3 ';
        };

        it 'base check result' => sub {
            Calc->expects('__unload_operators')->returns(
                sub {
                    my $result = '';
                    while (@stack) {
                        last if $stack[-1] ne '*';

                        $result .= pop @stack;
                    }

                    return $result;
                }
            )->exactly(3);
            Calc->expects('__unload_stack')->returns(
                sub {
                    my $result = '';
                    while (@stack) {
                        my $lexeme = pop @stack;
                        last if $lexeme eq '(';
                        $result .= $lexeme;
                    }

                    return $result;
                }
            )->once;
            my $result = Calc::convert_to_reverse_polish_notation( '(1 + 2) * 4 + 3' );

            is $result, '1 2 +4 *3 ';
        };

    };
};

runtests();
