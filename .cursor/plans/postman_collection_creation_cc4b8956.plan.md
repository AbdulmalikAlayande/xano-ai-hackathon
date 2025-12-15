---
name: Postman Collection Creation
overview: Create a comprehensive Postman collection JSON file for the Nigerian Government Fees API with all 5 endpoints, environment variables, example requests, and proper documentation.
todos:
  - id: read_endpoints
    content: Read all 5 endpoint files to extract exact parameters, response structures, and behavior
    status: completed
  - id: read_data_sources
    content: Read sources.csv, agencies.csv, and map CSV files to their agencies and categories
    status: completed
  - id: create_api_docs
    content: Create API_DOCUMENTATION.md with introduction, getting started, authentication, and all 5 endpoints documented
    status: completed
    dependencies:
      - read_endpoints
  - id: create_data_sources
    content: Create DATA_SOURCES.md organized by category with agency, URL, date, and data type for each source
    status: completed
    dependencies:
      - read_data_sources
  - id: create_quick_start
    content: Create QUICK_START.md with 5-minute setup, first API call walkthrough, common patterns, and troubleshooting
    status: completed
    dependencies:
      - create_api_docs
  - id: create_js_examples
    content: Create examples/javascript-example.js with all 5 endpoints, error handling, and comments
    status: completed
    dependencies:
      - create_api_docs
  - id: create_python_examples
    content: Create examples/python-example.py with all 5 endpoints, error handling, and comments
    status: completed
    dependencies:
      - create_api_docs
  - id: create_curl_examples
    content: Create examples/curl-examples.sh with all 5 endpoints as working cURL commands
    status: completed
    dependencies:
      - create_api_docs
---

# Postman Collection Creation Plan

## Overview

Create a Postman Collection v2.1 JSON file that includes all 5 API endpoints with proper authentication, query parameters, example requests, and environment variables for easy testing.

## Collection Structure

### File Location

- **File:** `examples/nigerian-fees-api.postman_collection.json`
- **Format:** Postman Collection v2.1 (JSON)

### Collection Metadata

- **Name:** "Nigerian Government Fees API"
- **Description:** Complete API collection for Nigerian Government Fees API with all endpoints, authentication, and examples
- **Schema:** `https://schema.getpostman.com/json/collection/v2.1.0/collection.json`

## Collection Contents

### 1. Environment Variables Template

Create a separate environment file: `examples/nigerian-fees-api.postman_environment.json`

**Variables:**

- `base_url`: `https://xmlb-8xh6-ww1h.n7e.xano.io/api:public`
- `api_key`: `nga_your_api_key_here` (placeholder)
- `fee_id`: `1` (example fee ID for testing)

### 2. Collection Items (5 Endpoints)

#### Item 1: GET /fees

- **Method:** GET
- **URL:** `{{base_url}}/fees`
- **Query Parameters:**
- `category` (optional, text) - Filter by category
- `state` (optional, text) - Filter by state
- `search` (optional, text) - Search term
- `page` (optional, int, default: 1) - Page number
- `per_page` (optional, int, default: 20, max: 100) - Items per page
- `api_key` (required, text) - API key for authentication
- **Example Requests:**
- Basic: Get first page
- With category filter: `?category=identity&api_key={{api_key}}`
- With search: `?search=NIN&api_key={{api_key}}`
- With pagination: `?page=1&per_page=10&api_key={{api_key}}`
- **Description:** Retrieve paginated list of government fees with optional filtering

#### Item 2: GET /fees/{id}

- **Method:** GET
- **URL:** `{{base_url}}/fees/{{fee_id}}`
- **Path Variables:**
- `fee_id` (required, int) - Fee ID
- **Query Parameters:**
- `api_key` (required, text) - API key for authentication
- **Example Requests:**
- Get fee by ID: `/fees/1?api_key={{api_key}}`
- Get fee by ID (using variable): `/fees/{{fee_id}}?api_key={{api_key}}`
- **Description:** Get a single fee by ID with all relationships

#### Item 3: GET /fees/search

- **Method:** GET
- **URL:** `{{base_url}}/fees/search`
- **Query Parameters:**
- `q` (required, text, min: 2 chars) - Search query
- `api_key` (required, text) - API key for authentication
- **Example Requests:**
- Search for "NIN": `?q=NIN&api_key={{api_key}}`
- Search for "passport": `?q=passport&api_key={{api_key}}`
- Search for "JAMB": `?q=JAMB&api_key={{api_key}}`
- **Description:** Search fees by name and description

#### Item 4: GET /categories

- **Method:** GET
- **URL:** `{{base_url}}/categories`
- **Query Parameters:**
- `api_key` (required, text) - API key for authentication
- **Example Request:**
- Get all categories: `?api_key={{api_key}}`
- **Description:** Get all categories with fee counts

#### Item 5: GET /metadata

- **Method:** GET
- **URL:** `{{base_url}}/metadata`
- **Query Parameters:**
- `api_key` (required, text) - API key for authentication
- **Example Request:**
- Get API metadata: `?api_key={{api_key}}`
- **Description:** Get API statistics and version information

## Implementation Details

### Postman Collection v2.1 Structure

Each request will include:

- **Name:** Descriptive endpoint name
- **Request:**
- **Method:** HTTP method (GET)
- **Header:** `Accept: application/json`
- **URL:** With base URL variable and query parameters
- **Description:** Markdown description with parameter details
- **Response Examples:** Include example success responses (200 OK)
- **Tests:** Optional basic tests (check status code, response structure)

### Authentication Handling

Since authentication uses query parameters (`api_key`), each request will:

- Include `api_key` as a query parameter
- Use environment variable `{{api_key}}` for easy management
- Include note about API key format: `nga_` + 32 characters

### Error Response Examples

Include example error responses:

- **401 Unauthorized:** Missing/invalid API key
- **400 Bad Request:** Invalid parameters
- **404 Not Found:** Resource not found (for /fees/{id})
- **429 Rate Limit:** Rate limit exceeded (using accessdenied error type)

### Documentation

Each endpoint will have:

- **Description:** What the endpoint does
- **Parameters Table:** All query/path parameters with types and descriptions
- **Example Request:** cURL equivalent
- **Example Response:** Sample JSON response
- **Error Responses:** Common error scenarios

## Files to Create

1. **`examples/nigerian-fees-api.postman_collection.json`**

- Main Postman collection file
- Contains all 5 endpoints
- Includes descriptions, examples, and tests

2. **`examples/nigerian-fees-api.postman_environment.json`**

- Environment variables file
- Can be imported separately in Postman
- Includes base_url and api_key

3. **Update `README.md`**

- Add section about Postman collection
- Include download links
- Instructions for importing

4. **Update `API_DOCUMENTATION.md`**

- Add Postman collection section
- Include import instructions
- Link to collection file

## Collection Features

### Organization

- All endpoints in a single collection
- Logical grouping (all under "Nigerian Government Fees API")
- Clear naming convention

### Reusability

- Environment variables for easy configuration
- Pre-filled example values
- Multiple example requests per endpoint where applicable

### Testing

- Basic response validation tests
- Status code checks
- Response structure validation

### Documentation

- Inline descriptions for each endpoint
- Parameter documentation
- Example requests and responses
- Error handling examples

## Validation

After creation, verify:

- [ ] Collection imports successfully in Postman
- [ ] All environment variables work correctly
- [ ] All endpoints can be executed
- [ ] Example requests return expected responses
- [ ] Error scenarios are documented
- [ ] Documentation links work

## Notes

- Postman Collection v2.1 format is the current standard
- Use environment variables for all dynamic values
- Include both success and error response examples
- Make collection self-documenting with descriptions
- Ensure all 5 endpoints are included with proper authentication