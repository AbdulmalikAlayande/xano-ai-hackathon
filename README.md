# Nigerian Government Fees API

A comprehensive REST API providing centralized access to official Nigerian government fees and public utility costs. This API consolidates fee information from multiple government agencies into a single, easy-to-use interface.

## 🚀 Quick Start

**New to the API?** Start here: [QUICK_START.md](./QUICK_START.md)

**Base URL:** `https://xmlb-8xh6-ww1h.n7e.xano.io/api:public`

## 📚 Documentation

### Main Documentation

- **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** - Complete API reference with all endpoints, parameters, examples, and error handling
- **[QUICK_START.md](./QUICK_START.md)** - Get up and running in 5 minutes with step-by-step examples
- **[DATA_SOURCES.md](./DATA_SOURCES.md)** - Reference for all official data sources and agencies

### Code Examples

Ready-to-use code examples in multiple languages:

- **[JavaScript Examples](./examples/javascript-example.js)** - Complete examples using Fetch API
- **[Python Examples](./examples/python-example.py)** - Complete examples using requests library
- **[cURL Examples](./examples/curl-examples.sh)** - Command-line examples for testing
- **[Postman Collection](./examples/nigerian-fees-api.postman_collection.json)** - Import into Postman for easy testing

## 🔑 Authentication

All endpoints require an API key passed as a query parameter except the `/api-key/generate` and `/docs` endpoints:

```
?api_key=nga_your_api_key_here
```

API keys follow the format: `nga_` + 32 random characters

**Rate Limit:** 100 requests per hour per API key

## 📡 Available Endpoints

1. **GET /fees** - List all fees with filtering, sorting, and pagination
2. **GET /fees/{id}** - Get a single fee by ID with all relationships
3. **GET /fees/search** - Search fees by name and description
4. **GET /categories** - Get all categories with fee counts
5. **GET /metadata** - Get API statistics and version information
6. **GET /docs** - Get documentation links (no authentication required)
7. **POST /api_key/generate** - Generate a new API key (no authentication required)

See [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) for complete endpoint details.

## 🏗️ Project Structure

```
xano-ai-app/
├── apis/
│   └── public/          # API endpoint definitions
├── functions/           # Reusable functions (auth, key generation)
├── tables/              # Database table schemas
├── data/seed/           # Seed data (CSV files)
├── examples/            # Code examples (JS, Python, cURL)
├── docs/                # XanoScript development guidelines
└── [Documentation files]
```

## 🛠️ Development

This project uses **XanoScript** for API development. For development guidelines, see the `docs/` directory.

### Key Files

- `NIGERIAN_FEES_API_CHECKLIST.md` - Development checklist and roadmap
- `AI_GENERATION_REPORT.md` - AI generation report and fixes
- `TESTING_GUIDE.md` - Testing guidelines

## 📊 Data Sources

All fee data is sourced from official government websites and documents:

- **NIMC** - National Identity Management Commission (NIN fees)
- **NIS** - Nigerian Immigration Service (Passport fees)
- **NECO** - National Examinations Council (Examination fees)
- **JAMB** - Joint Admissions and Matriculation Board (UTME fees)
- **NERC/EKEDC** - Electricity Regulatory Commission (Electricity tariffs)

See [DATA_SOURCES.md](./DATA_SOURCES.md) for complete source references.

## 🔄 API Version

**Current Version:** 1.0.0

Check the `/metadata` endpoint for the latest version information.

## 📝 License

[Add your license information here]

## 🤝 Contributing

[Add contribution guidelines here]

## 📧 Support

For issues, questions, or contributions, please refer to the project repository or contact the API maintainers.

---

**Last Updated:** December 2024

