# build
docker build -t graphcodebert-embed:local .

# run
docker run --rm -p 8000:8000 graphcodebert-embed:local

# test (new terminal)
curl -s -X POST http://localhost:8000/embed \
  -H "content-type: application/json" \
  -d '{"texts": ["def add(a,b): return a+b", "public class A {}"]}' | jq .
