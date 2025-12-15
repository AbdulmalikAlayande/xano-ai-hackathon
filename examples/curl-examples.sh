#!/bin/bash

# Nigerian Government Fees API - cURL Examples
#
# This file contains working cURL commands for all 5 API endpoints.
# Replace 'nga_your_api_key_here' with your actual API key.
#
# Usage:
#   chmod +x curl-examples.sh
#   ./curl-examples.sh
#
# Or copy individual commands and run them in your terminal.

BASE_URL="https://xmlb-8xh6-ww1h.n7e.xano.io/api:public"
API_KEY="nga_your_api_key_here"  # Replace with your actual API key

echo "=========================================="
echo "Nigerian Government Fees API - cURL Examples"
echo "=========================================="
echo ""

# Example 1: GET /fees
# Retrieve a paginated list of fees with optional filters
echo "Example 1: GET /fees"
echo "Get first page of fees (default: 20 per page)"
curl -X 'GET' \
  "${BASE_URL}/fees?page=1&per_page=20" \
  -H 'accept: application/json'
echo ""
echo ""

echo "Get fees filtered by category"
curl -X 'GET' \
  "${BASE_URL}/fees?category=identity&page=1&per_page=10" \
  -H 'accept: application/json'
echo ""
echo ""

echo "Search fees by name/description"
curl -X 'GET' \
  "${BASE_URL}/fees?search=NIN&page=1&per_page=20" \
  -H 'accept: application/json'
echo ""
echo ""

echo "Get fees with multiple filters"
curl -X 'GET' \
  "${BASE_URL}/fees?category=identity&search=NIN&page=1&per_page=20" \
  -H 'accept: application/json'
echo ""
echo ""

# Example 2: GET /fees/{id}
# Retrieve a single fee by ID with all relationships
echo "Example 2: GET /fees/{id}"
echo "Get fee with ID 1"
curl -X 'GET' \
  "${BASE_URL}/fees/1?api_key=${API_KEY}" \
  -H 'accept: application/json'
echo ""
echo ""

echo "Get fee with ID 20"
curl -X 'GET' \
  "${BASE_URL}/fees/20?api_key=${API_KEY}" \
  -H 'accept: application/json'
echo ""
echo ""

# Example 3: GET /fees/search
# Search fees by name and description
echo "Example 3: GET /fees/search"
echo "Search for 'NIN'"
curl -X 'GET' \
  "${BASE_URL}/fees/search?q=NIN&api_key=${API_KEY}" \
  -H 'accept: application/json'
echo ""
echo ""

echo "Search for 'passport'"
curl -X 'GET' \
  "${BASE_URL}/fees/search?q=passport&api_key=${API_KEY}" \
  -H 'accept: application/json'
echo ""
echo ""

echo "Search for 'JAMB'"
curl -X 'GET' \
  "${BASE_URL}/fees/search?q=JAMB&api_key=${API_KEY}" \
  -H 'accept: application/json'
echo ""
echo ""

# Example 4: GET /categories
# Get all categories with fee counts
echo "Example 4: GET /categories"
echo "Get all categories"
curl -X 'GET' \
  "${BASE_URL}/categories?api_key=${API_KEY}" \
  -H 'accept: application/json'
echo ""
echo ""

# Example 5: GET /metadata
# Get API statistics and metadata
echo "Example 5: GET /metadata"
echo "Get API metadata"
curl -X 'GET' \
  "${BASE_URL}/metadata?api_key=${API_KEY}" \
  -H 'accept: application/json'
echo ""
echo ""

echo "=========================================="
echo "Examples Complete"
echo "=========================================="

# Individual command examples (commented out for easy copying)
# Uncomment and modify as needed:

# GET /fees - Basic
# curl -X 'GET' 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public/fees?page=1&per_page=20' -H 'accept: application/json'

# GET /fees - With category filter
# curl -X 'GET' 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public/fees?category=identity&page=1&per_page=20' -H 'accept: application/json'

# GET /fees - With search
# curl -X 'GET' 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public/fees?search=NIN&page=1&per_page=20' -H 'accept: application/json'

# GET /fees/{id}
# curl -X 'GET' 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public/fees/1?api_key=nga_your_api_key_here' -H 'accept: application/json'

# GET /fees/search
# curl -X 'GET' 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public/fees/search?q=NIN&api_key=nga_your_api_key_here' -H 'accept: application/json'

# GET /categories
# curl -X 'GET' 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public/categories?api_key=nga_your_api_key_here' -H 'accept: application/json'

# GET /metadata
# curl -X 'GET' 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public/metadata?api_key=nga_your_api_key_here' -H 'accept: application/json'

