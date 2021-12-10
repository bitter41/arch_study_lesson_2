use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe 'convert_to_reverse_polish_notation: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[SUCCESS] ' => sub {
        my @stack;

        before each => sub {
            @stack = ();

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
