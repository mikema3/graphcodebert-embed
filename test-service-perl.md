# Perl Test Script for GraphCodeBERT Service

## Requirements

The script uses standard Perl modules that are usually included:
- `HTTP::Tiny` - HTTP client
- `JSON::PP` - JSON encoding/decoding
- `List::Util` - Utility functions

If any module is missing, install with:

```bash
# Using cpan
cpan HTTP::Tiny JSON::PP

# Or using cpanm (recommended)
cpanm HTTP::Tiny JSON::PP
```

## Usage

### Basic usage (default: http://localhost:8000):
```bash
perl test-service.pl
```

### Specify custom URL:
```bash
perl test-service.pl http://localhost:8080
```

### Run on WSL/Linux:
```bash
chmod +x test-service.pl
./test-service.pl
```

## Output

The script tests the GraphCodeBERT embedding service with:
1. Python functions (3 samples)
2. Java classes (2 samples)
3. JavaScript functions (2 samples)
4. Mixed languages (3 samples)
5. Single input (1 sample)

For each test, it shows:
- Success/failure status
- Number of embeddings generated
- Vector dimensions (should be 768 for GraphCodeBERT)
- Cosine similarity between first two embeddings (if applicable)

## Example Output

```
GraphCodeBERT Embedding Service Test Suite
Base URL: http://localhost:8000

=== Testing: Python Functions ===
✓ Success!
  Embeddings: 3
  Dimensions: 768
  Similarity (1st vs 2nd): 0.9504

=== Testing: Java Classes ===
✓ Success!
  Embeddings: 2
  Dimensions: 768
  Similarity (1st vs 2nd): 0.9633
```

## Notes

- The checkmark (✓) may appear garbled in Windows PowerShell due to UTF-8 encoding
- The script works on Windows, Linux, and macOS
- Default timeout is 30 seconds per request
- Similarity scores close to 1.0 indicate very similar code semantics
