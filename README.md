# GraphCodeBERT Embedding Service

FastAPI-based embedding service for GraphCodeBERT, providing code embeddings via REST API.

## Features

- 768-dimensional code embeddings
- Supports multiple programming languages
- FastAPI with automatic documentation
- Docker containerized
- Cloud-ready (Google Cloud Run, Azure Container Apps)

## Model

This service uses [Microsoft GraphCodeBERT](https://huggingface.co/microsoft/graphcodebert-base), a pre-trained model on programming languages.

**Model License:** MIT  
**Reference:** [GraphCodeBERT: Pre-training Code Representations with Data Flow](https://arxiv.org/abs/2009.08366)

## Quick Start

See [QUICKSTART.md](QUICKSTART.md) for local setup.

## Deployment

- [Google Cloud Run](deploy-google-cloudrun.md)
- [Azure Container Apps](deploy-azure-containerApps.md)

## API

- `GET /health` - Health check
- `POST /embed` - Generate embeddings
- `GET /docs` - Interactive API documentation

## License

MIT License - see [LICENSE](LICENSE) file for details.

This project uses Microsoft GraphCodeBERT which is also licensed under MIT.
