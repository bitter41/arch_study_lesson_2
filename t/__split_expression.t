use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe '__split_expression: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[SUCCESS] ' => sub {

        it 'split: (1 + 2) * 4 + 3 = 15' => sub {
            my @result = Calc::__split_expression( '(1 + 2) * 4 + 3' );

            cmp_deeply \@result, [qw| ( 1 + 2 ) * 4 + 3 |];
        };

        it 'split for: 1 + 2 * 4 + 3 = 12' => sub {
            my @result = Calc::__split_expression( '1 + 2 * 4 + 3' );

            cmp_deeply \@result, [qw| 1 + 2 * 4 + 3 |];
        };

        it 'split for: ((1 + 2) * 4 + 6) / 3 = 12' => sub {
            my @result = Calc::__split_expression( '((1 + 2) * 4 + 6) / 3' );

            cmp_deeply \@result, [qw| ( ( 1 + 2 ) * 4 + 6 ) / 3 |];
        };

        it 'split for: (1+2) * 14 /6 +2 * (3+2) = ??' => sub {
            my @result = Calc::__split_expression( '(1+2) * 14 /6 +2 * (3+2)' );

            cmp_deeply \@result, [qw| ( 1 + 2 ) * 14 / 6 + 2 * ( 3 + 2 ) |];
        };

    };
};

runtests();
