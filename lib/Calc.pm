package Calc;

use Data::Dumper;

use constant LEXEMES_ALLOW_REGEXP_LIST => ( '(', ')', ' ', '+', '-', '*', '/' );

=head2 C<convert_to_reverse_polish_notation>($expression)

Конвертировать выражение в обратную польскую запись

=cut

sub convert_to_reverse_polish_notation {
    my ($expression) = @_;

    my $result_in_rpn = '';

    die 'Argument must be string'                     if ref $expression;
    die "Found wrong lexeme in argument: $expression" if __has_any_wrong_lexemes($expression);

    my @stack = ();
    my @expression_array = split //, $expression;
    foreach my $lexeme (@expression_array) {
        next unless __is_lexeme($lexeme);

        if ( __is_number($lexeme) ) {
            $result_in_rpn .= $lexeme;
        }
        elsif ( __is_operator($lexeme) ) {
            $result_in_rpn .= __unload_operators(\@stack);
            __push_to_stack( \@stack, $lexeme );
        }
        elsif ( __is_open_bracket($lexeme) ) {
            __push_to_stack( \@stack, $lexeme );
        }
        elsif ( __is_close_bracket($lexeme) ) {
            my $u = __unload_stack( \@stack );
            #print Dumper($u);
            $result_in_rpn .= $u;
        }
    }
    $result_in_rpn .= $_ foreach (reverse @stack);

    #print Dumper(\@expression_array);

    return $result_in_rpn;
}

=head2 C<__has_any_wrong_lexemes>($expression)

Есть ли в выражении какие нибудь неправильные лексемы?

=cut

sub __has_any_wrong_lexemes {
    my ($expression) = @_; 

    # Вырежем лексемы по списку
    $expression =~ s|\Q$_||g foreach (LEXEMES_ALLOW_REGEXP_LIST);

    # Вырежем числовые лексемы
    $expression =~ s|\d+||g;

    return 0 unless $expression;

    print Dumper($expression);

    return 1;
}

1;
