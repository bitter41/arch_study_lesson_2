use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe 'convert_to_reverse_polish_notation: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[SUCCESS] ' => sub {
        my @is_operator_mock;
        my @is_open_bracket_mock;
        my @is_close_bracket_mock;
        my @stack;

        before each => sub {
            @is_operator_mock      = (0,  0,1,0,  0,0,1,0,  0,1,0  );
            @is_open_bracket_mock  = (1,  0,  0,  0,0,  0,  0,  0  );
            @is_close_bracket_mock = (    0,  0,  1,0,  0,  0,  0  );
            @stack = ();

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

            is $result, '12+4*3';
        };

    };
};

runtests();
