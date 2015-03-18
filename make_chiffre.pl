#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;


sub encrypt_text {
    #function cuts off all the possible spaces and encrypts the result string (everything is lowercased)
    my ($text, $key) = @_;

    $text = lc $text;
    $key = lc $key;

    my @result_ar = ();
    $text =~ s/\s//g;
    print "Text without spaces: $text\n";

    my @key_ar = split(//, $key);
    my $key_len = length($key);
    my @text_ar = split(//, $text);
    
    my $i = 0;
    my $a_code = ord('a');
    foreach my $s (@text_ar) {
        if ($i == $key_len) {$i = 0;}
        push @result_ar, chr((ord($s) - $a_code + ord($key_ar[$i]) - $a_code)%26 + $a_code);
        $i++;
    }

    my $result = join("", @result_ar);
    return $result;
}


my ($text, $key) = @ARGV;
unless($text and $key) {
    print "Error, text and key have not been set \n";
    exit;
}

print "Opened text: $text\n";
print "The key: $key\n";
my $encrypted_text = encrypt_text($text, $key);
print "Encrypted text: $encrypted_text\n";
1;
