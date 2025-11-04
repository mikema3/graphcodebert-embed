#!/usr/bin/env perl
use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;
use List::Util qw(sum);

# Configuration
my $base_url = $ARGV[0] || 'http://localhost:8000';
my $http = HTTP::Tiny->new(timeout => 30);
my $json = JSON::PP->new->utf8->pretty;

# Color codes for terminal output
my %colors = (
    cyan   => "\e[36m",
    green  => "\e[32m",
    yellow => "\e[33m",
    red    => "\e[31m",
    reset  => "\e[0m",
);

sub colorize {
    my ($text, $color) = @_;
    return $colors{$color} . $text . $colors{reset};
}

sub calculate_cosine_similarity {
    my ($vec1, $vec2) = @_;
    
    # Vectors are already normalized in the API response
    # So cosine similarity is just the dot product
    my $dot = 0;
    for my $i (0 .. $#{$vec1}) {
        $dot += $vec1->[$i] * $vec2->[$i];
    }
    return $dot;
}

sub test_endpoint {
    my ($name, $texts) = @_;
    
    print "\n" . colorize("=== Testing: $name ===", 'cyan') . "\n";
    
    my $request_body = $json->encode({ texts => $texts });
    
    my $response = $http->request('POST', "$base_url/embed", {
        headers => {
            'Content-Type' => 'application/json',
        },
        content => $request_body,
    });
    
    if ($response->{success}) {
        my $data = $json->decode($response->{content});
        
        print colorize("✓ Success!", 'green') . "\n";
        print colorize("  Embeddings: " . scalar(@{$data->{vectors}}), 'yellow') . "\n";
        print colorize("  Dimensions: " . scalar(@{$data->{vectors}[0]}), 'yellow') . "\n";
        
        # Calculate similarity between first two if we have at least 2
        if (@{$data->{vectors}} >= 2) {
            my $similarity = calculate_cosine_similarity(
                $data->{vectors}[0],
                $data->{vectors}[1]
            );
            printf colorize("  Similarity (1st vs 2nd): %.4f", 'yellow') . "\n", $similarity;
        }
    } else {
        print colorize("✗ Failed!", 'red') . "\n";
        print colorize("  Status: $response->{status} $response->{reason}", 'red') . "\n";
        print colorize("  $response->{content}", 'red') . "\n" if $response->{content};
    }
}

# Main test suite
print colorize("GraphCodeBERT Embedding Service Test Suite", 'cyan') . "\n";
print colorize("Base URL: $base_url", 'yellow') . "\n";

# Test 1: Python functions
test_endpoint('Python Functions', [
    'def add(a, b): return a + b',
    'def sum(x, y): return x + y',
    'def multiply(a, b): return a * b',
]);

# Test 2: Java classes
test_endpoint('Java Classes', [
    'public class Calculator { public int add(int a, int b) { return a + b; } }',
    'public class MathUtil { public static int sum(int x, int y) { return x + y; } }',
]);

# Test 3: JavaScript functions
test_endpoint('JavaScript Functions', [
    'function add(a, b) { return a + b; }',
    'const multiply = (a, b) => a * b;',
]);

# Test 4: Mixed languages
test_endpoint('Mixed Languages', [
    'def hello(): print(\'Hello from Python\')',
    'console.log(\'Hello from JavaScript\')',
    'System.out.println("Hello from Java");',
]);

# Test 5: Single input
test_endpoint('Single Input', [
    '// This is a comment',
]);

print "\n" . colorize("=== All Tests Complete ===", 'green') . "\n";
