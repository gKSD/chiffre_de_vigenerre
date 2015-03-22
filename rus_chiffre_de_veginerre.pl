#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

use utf8;
use open qw(:std :utf8);

my @_alphabet = ('a', 'b', 'c', 'd', 'e', 'f','g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z');
my @_frequency = (8.2, 1.5, 2.8, 4.2, 12.7, 2.2, 2.0, 6.1, 7.0, 0.1, 0.8, 4.0, 2.4, 6.7, 7.5, 1.9, 0.1, 6.0, 6.3, 9.0, 2.8, 1.0, 2.4, 0.1, 2.0, 0.1);

my @rus_alphabet = ('а',    'б',   'в',   'г',   'д',   'е',   'ж',   'з',   'и',   'й',   'к',  'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ы', 'ъ', 'ь', 'э', 'ю', 'я');
my @rus_frequency = (0.062, 0.014, 0.038, 0.013, 0.025, 0.072, 0.007, 0.016, 0.062, 0.01, 0.028, 0.035, 0.026, 0.053, 0.09, 0.023, 0.04, 0.045, 0.053, 0.021, 0.002, 0.009, 0.004, 0.012, 0.006, 0.003, 0.014, 0.016, 0.014, 0.003, 0.006, 0.018);

my $_text = "xtxafslwpmccpjifvbdbsmccpjifvjpgxqycccxavpecxmpegwiyjfpjiwflthlxzphdmmvzjhmgkftcrlvrrcqxjmhveecgiowmvyitmkjriviovpnkskjrdtjhirjbildgvvxtebdhlxiqifebeqdtahvuwwgaemlgixdudsgndnpfiwngivphjqdtxavclwpeemigixdqd";
my $rus_text = "сиздфчаякбрнючччпюрнкобуекелецхмчмцнтзучщищуешоклукеглгнчбзорпиофнзлугоекчфннеубщвюч";


my $rus_mod = 32;

print "rus_alphabet => @rus_alphabet \n";
print "rus freq => ".Dumper(\@rus_frequency)."\n";
print "alp len ". $#rus_alphabet.",  freq len => ".$#rus_frequency."\n";
print "code a => ".ord('а').", г => ".ord('г').", наборот ".chr(1075)."\n";
print "rus text => ".$rus_text."\n";
#exit;

sub sort_alphabet_by_frequency {
    my ($alphabet, $frequency, $size) = @_;

    for( my $i = 0; $i < $size; $i++) {
        for( my $j = $size - 1; $j > $i; $j-- ) {
            if ( $frequency->[$j - 1] <  $frequency->[$j] ) {
                my $tmp = $frequency->[$j - 1];
                $frequency->[$j - 1] = $frequency->[$j];
                $frequency->[$j] = $tmp;

                my $tmp1 = $alphabet->[$j - 1];
                $alphabet->[$j - 1] = $alphabet->[$j];
                $alphabet->[$j] = $tmp1;
            }
        }
    }
}

sub extract_bigramms {
    my ($text, $bigramms) = @_;

    my @text_array = split(//, $text);
    my %res = ();
    my $len = length($text);

    for (my $i = 0; $i < $len - 2; $i++) {
       my $bg = $text_array[$i].$text_array[$i + 1];
       #warn "bigramm => $bg";
       if (exists($res{$bg})) {
           $res{$bg}++;
        }
       else {
           $res{$bg} = 1;
       }
    }
    return %res;
}

sub get_distances {
    my ($bgs, $text) = @_;

    my $text_len = length($text);
    my @text_ar =  split(//, $text);
    my @res = ();

    foreach my $bg (keys %{$bgs}) {
        if ($bgs->{$bg} > 1) {
            my @ar = ();
            my $d = 0;
            my $is_first = 1;
            for (my $i = 0; $i < $text_len - 1; $i++) {
                if ($bg eq ($text_ar[$i].$text_ar[$i + 1])) {
                    if ($is_first == 0) {
                        push @ar, $d;
                        $d = 0;
                    }
                    else {
                        $is_first = 0;
                    }
                }
                elsif ($is_first == 0) {
                    $d++;
                }
            }
            my $tmp = uc $bg;
            print $tmp." => (@ar)\n";
            @res = (@res, @ar);
        }
    }
    return @res;
}


sub NOD {
    return  $_[0] != 0  ?  NOD ( ( $_[1] % $_[0] ), $_[0] )  :  $_[1];
}

sub get_alpha_num {
}

sub decode_key_word {
    #here is decoding each symbol of key word
    my ($nod, $text, $alphabet, $frequency, $alphabet_symbols_amount) = @_;

    if ($alphabet_symbols_amount > 26) {$$alphabet_symbols_amount = 26;}
    elsif ($alphabet_symbols_amount <= 0) {$alphabet_symbols_amount = 1;}

    my @text_ar = split(//, $text);
    my $text_len = length($text);

    my @key_word_ar = ();
    my @key_word_variants = ();

    for (my $i = 0; $i < $nod; $i++) {
        my %t_symbols = (); #symbols of the text according to $i position
        for (my $j = $i; $j < $text_len; $j += $nod) {
            if (exists($t_symbols{$text_ar[$j]})) {
                $t_symbols{$text_ar[$j]}++;
            }
            else {
                $t_symbols{$text_ar[$j]} = 1;
            }
        }
        my @t_symbols_sorted = sort { $t_symbols{$b} <=> $t_symbols{$a} } keys(%t_symbols);

        {
            my %possible_key_symbols = ();
            foreach my $t_symbol (@t_symbols_sorted) {
                my $t_symbol_code = ord($t_symbol) - ord('а');
                foreach my $j (0..($alphabet_symbols_amount - 1)) {
                    my $key_symbol = (26 - (ord($alphabet->[$j]) - ord('а')) + $t_symbol_code)%($rus_mod);
                    if (exists $possible_key_symbols{$key_symbol}) {
                        $possible_key_symbols{$key_symbol}++;
                    }
                    else {
                        $possible_key_symbols{$key_symbol} = 1;
                    }
                }
            }
            my @possible_key_symbols_sorted = sort {$possible_key_symbols{$b} <=> $possible_key_symbols{$a}} keys(%possible_key_symbols);
            my @possible_key_symbols_freq_sorted = @possible_key_symbols{@possible_key_symbols_sorted};

            if ($possible_key_symbols_freq_sorted[0] != $possible_key_symbols_freq_sorted[1]) {
                $key_word_ar[$i] = chr($possible_key_symbols_sorted[0] + ord('а'));
                push @key_word_variants, [$key_word_ar[$i]];
            }
            else {
                $key_word_ar[$i] = ' ';
                my @ar = ();
                my $j = 0;
                while ($possible_key_symbols_freq_sorted[$j] == $possible_key_symbols_freq_sorted[0]) {
                    push @ar, chr($possible_key_symbols_sorted[$j] + ord('а'));
                    $j++;
                }
                push @key_word_variants, \@ar;
            }
        }
    }

    my $key_word = join("", @key_word_ar);
    my %res = ('key_word' => $key_word, 'variants' => [@key_word_variants]);
    return %res;
}

sub decode_text {
    my ($cipher, $key, $nod) = @_;

    my @cipher_ar = split(//, $cipher);
    my @key_ar = split(//, $key);
    my @decoded_text_ar = ();

    my $cipher_len = scalar(@cipher_ar) - 1;

    my $i = 0;
    foreach my $s (@cipher_ar) {
        if ($i == $nod) {$i = 0;}
        push @decoded_text_ar, chr((ord($s) - ord('а') - (ord($key_ar[$i]) - ord('а')) + 26)%($rus_mod) +ord('а'));
        $i++;
    }
   
    my $decoded_text = join("", @decoded_text_ar);
    return $decoded_text;
}

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#unless ($ARGV[0]) {
#    print "Error, cipher has not been set\n";
#    exit;
#}
#TODO lc all the sub pararms
my $cipher = lc $rus_text;#$ARGV[0]; #$_text; #это передаем везде в качестве текста

sort_alphabet_by_frequency(\@rus_alphabet, \@rus_frequency, 26);
print "sorted alphabet @rus_alphabet, \n and frequency => @rus_frequency\n";
my %bigramms = extract_bigramms($cipher);

print " ********************** Bigramms:  ********************\n";
print map {"$_ => $bigramms{$_}\n"} keys %bigramms;

my @distances = get_distances(\%bigramms, $cipher);
print " ********************** Distances: ********************\n @distances\n";

print "Enter the NOD: ";
chomp (my $nod = <STDIN>);
print "NOD => $nod\n";
my %key_word_hash = decode_key_word($nod, $cipher, \@rus_alphabet, \@rus_frequency, 2);#scalar(@rus_alphabet)/2);
print "Supposing key word: \"".$key_word_hash{'key_word'}."\"\n";
print "Possible variants for each symbol position: ".Dumper($key_word_hash{'variants'})."\n";
print "Enter the key_word: ";
chomp (my $key_word = <STDIN>);
my $decoded_text = decode_text($cipher, $key_word, $nod);
print "Result: $decoded_text\n";


1;
