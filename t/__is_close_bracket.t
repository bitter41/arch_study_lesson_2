use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe '__is_close_bracket: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[BRANCH] ' => sub {

        it 'should return 0 for wrong lexeme with undef arg' => sub {
            ok ! Calc::__is_close_bracket( undef );
        };

        it 'should return 0 for wrong lexeme with string length > 1' => sub {
            ok ! Calc::__is_close_bracket( '++++' );
        };

        it 'should return 0 for wrong lexeme with empty string' => sub {
            ok ! Calc::__is_close_bracket( '' );
        };

        it 'should return 0 for numeric lexeme' => sub {
            ok ! Calc::__is_close_bracket( '4' );
        };

        it 'should return 0 for bracket lexeme: (' => sub {
            ok ! Calc::__is_close_bracket( '(' );
        };

        it 'should return 1 for bracket lexeme: )' => sub {
            ok Calc::__is_close_bracket( ')' );
        };

        it 'should return 0 for right operator lexeme: *' => sub {
            ok ! Calc::__is_close_bracket( '*' );
        };

        it 'should return 0 for right operator lexeme: /' => sub {
            ok ! Calc::__is_close_bracket( '/' );
        };

        it 'should return 0 for right operator lexeme: +' => sub {
            ok ! Calc::__is_close_bracket( '+' );
        };

        it 'should return 0 for right operator lexeme: -' => sub {
            ok ! Calc::__is_close_bracket( '-' );
        };

        it 'should return 0 for not operator lexeme: <space>' => sub {
            ok ! Calc::__is_close_bracket( ' ' );
        };

        it 'should return 0 for not allowed lexeme: x' => sub {
            ok ! Calc::__is_close_bracket( 'x' );
        };
    };
};

runtests();
