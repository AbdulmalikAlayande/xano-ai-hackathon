# Quick Start Guide

Get up and running with the Nigerian Government Fees API in 5 minutes.

---

## Prerequisites

- An API key (see "Getting Your API Key" below)
- A tool to make HTTP requests (cURL, Postman, or your preferred HTTP client)
- Basic knowledge of REST APIs

---

## Step 1: Get Your API Key

### Option 1: Generate a New API Key

You can generate a new API key using the API itself:

```bash
curl -X 'POST' \
  'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public/api_key/generate' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
    "user_email": "your-email@example.com"
  }'
```

The response will include your new API key:
```json
{
  "success": true,
  "api_key": "nga_b6cf98a60bda43ba8cf54af9dbd87260",
  "message": "API key generated successfully. Please save this key as it provides access to the API."
}
```

**Important:** Save this key immediately - you cannot retrieve it later!

### Option 2: Use Pre-generated Test Keys

API keys can also be generated using the `admin/generate_api_keys` function in Xano (for administrators).

**API Key Format:** `nga_` + 32 random characters

Example: `nga_b6cf98a60bda43ba8cf54af9dbd87260`

---

## Step 2: Make Your First API Call

Let's start with a simple request to get all categories:

### Using cURL

```bash
curl -X 'GET' \
  'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public/categories?api_key=nga_your_api_key_here' \
  -H 'accept: application/json'
```

### Using JavaScript (Browser or Node.js)

```javascript
const BASE_URL = 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public';
const API_KEY = 'nga_your_api_key_here';

async function getCategories() {
  try {
    const response = await fetch(`${BASE_URL}/categories?api_key=${API_KEY}`);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    console.log('Categories:', data);
    return data;
  } catch (error) {
    console.error('Error:', error);
  }
}

getCategories();
```

### Using Python

```python
import requests

BASE_URL = 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public'
API_KEY = 'nga_your_api_key_here'

try:
    response = requests.get(
        f'{BASE_URL}/categories',
        params={'api_key': API_KEY}
    )
    response.raise_for_status()
    data = response.json()
    print('Categories:', data)
except requests.exceptions.RequestException as e:
    print('Error:', e)
```

### Expected Response

```json
[
  {
    "id": 1,
    "display_name": "Identity & Management",
    "description": "Fees related to national identity systems such as NIN",
    "fee_count": 19
  },
  {
    "id": 2,
    "display_name": "Immigration",
    "description": "Passport and visa related fees",
    "fee_count": 10
  }
]
```

**Success!** You've made your first API call. 🎉

---

## Step 3: Search for Fees

Now let's search for specific fees. This example searches for "NIN" related fees:

### cURL

```bash
curl -X 'GET' \
  'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public/fees/search?q=NIN&api_key=nga_your_api_key_here' \
  -H 'accept: application/json'
```

### JavaScript

```javascript
const BASE_URL = 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public';
const API_KEY = 'nga_your_api_key_here';

async function searchFees(query) {
  try {
    const response = await fetch(
      `${BASE_URL}/fees/search?q=${encodeURIComponent(query)}&api_key=${API_KEY}`
    );
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || `HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    console.log(`Found ${data.length} fees matching "${query}"`);
    return data;
  } catch (error) {
    console.error('Error:', error);
  }
}

searchFees('NIN');
```

### Python

```python
import requests

BASE_URL = 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public'
API_KEY = 'nga_your_api_key_here'

def search_fees(query):
    try:
        response = requests.get(
            f'{BASE_URL}/fees/search',
            params={
                'q': query,
                'api_key': API_KEY
            }
        )
        response.raise_for_status()
        data = response.json()
        print(f'Found {len(data)} fees matching "{query}"')
        return data
    except requests.exceptions.RequestException as e:
        print('Error:', e)

search_fees('NIN')
```

---

## Common Integration Patterns

### Pattern 1: Filter Fees by Category

Get all fees in a specific category with pagination:

```javascript
async function getFeesByCategory(category, page = 1, perPage = 20) {
  const params = new URLSearchParams({
    category: category,
    page: page,
    per_page: perPage,
    api_key: API_KEY
  });
  
  const response = await fetch(`${BASE_URL}/fees?${params}`);
  const data = await response.json();
  
  console.log(`Page ${data.meta.page} of ${data.meta.pageTotal}`);
  console.log(`Total: ${data.meta.total} fees`);
  
  return data.items;
}

// Get identity-related fees
getFeesByCategory('identity');
```

### Pattern 2: Get Specific Fee Details

Retrieve complete information about a specific fee:

```javascript
async function getFeeById(feeId) {
  const response = await fetch(
    `${BASE_URL}/fees/${feeId}?api_key=${API_KEY}`
  );
  
  if (response.status === 404) {
    console.error('Fee not found');
    return null;
  }
  
  const data = await response.json();
  return data;
}

// Get fee with ID 1
getFeeById(1);
```

### Pattern 3: Pagination

Handle paginated results:

```javascript
async function getAllFees(category = null) {
  let allFees = [];
  let page = 1;
  let hasMore = true;
  
  while (hasMore) {
    const params = new URLSearchParams({
      page: page,
      per_page: 100, // Maximum per page
      api_key: API_KEY
    });
    
    if (category) {
      params.append('category', category);
    }
    
    const response = await fetch(`${BASE_URL}/fees?${params}`);
    const data = await response.json();
    
    allFees = allFees.concat(data.items);
    
    // Check if there are more pages
    hasMore = page < data.meta.pageTotal;
    page++;
  }
  
  return allFees;
}
```

### Pattern 4: Error Handling

Comprehensive error handling:

```javascript
async function apiCall(endpoint, params = {}) {
  try {
    // Add API key to params
    const queryParams = new URLSearchParams({
      ...params,
      api_key: API_KEY
    });
    
    const response = await fetch(`${BASE_URL}${endpoint}?${queryParams}`);
    const data = await response.json();
    
    // Check for API errors
    if (data.code && data.code.startsWith('ERROR_CODE')) {
      throw new Error(data.message || 'API Error');
    }
    
    // Handle HTTP errors
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${data.message || response.statusText}`);
    }
    
    return data;
  } catch (error) {
    console.error('API Call Failed:', error.message);
    throw error;
  }
}

// Usage
apiCall('/fees/search', { q: 'passport' })
  .then(data => console.log('Success:', data))
  .catch(error => console.error('Failed:', error));
```

---

## Troubleshooting

### Issue: "Missing API Key" Error

**Problem:**
```json
{
  "code": "ERROR_CODE_ACCESS_DENIED",
  "message": "Missing API Key. Please provide api_key query parameter."
}
```

**Solution:**
- Ensure you're including `api_key` as a query parameter
- Check that your API key is correct (starts with `nga_` and is 36 characters total)
- Verify the API key is active in the database

**Correct:**
```
?api_key=nga_b6cf98a60bda43ba8cf54af9dbd87260
```

**Incorrect:**
```
Authorization: Bearer nga_b6cf98a60bda43ba8cf54af9dbd87260  // Headers not supported
```

### Issue: "Invalid or inactive API Key" Error

**Problem:**
```json
{
  "code": "ERROR_CODE_ACCESS_DENIED",
  "message": "Invalid or inactive API Key."
}
```

**Solution:**
- Verify your API key exists in the `api_keys` table
- Check that `is_active` is set to `true` for your key
- Ensure there are no extra spaces or characters in the key
- Contact API administrator to verify key status

### Issue: "Search query 'q' must be at least 2 characters long"

**Problem:**
```json
{
  "code": "ERROR_CODE_INPUT_ERROR",
  "message": "Search query 'q' must be at least 2 characters long"
}
```

**Solution:**
- Ensure your search query is at least 2 characters
- Trim any whitespace from the query
- Validate input before making the API call

### Issue: "Category not found"

**Problem:**
```json
{
  "code": "ERROR_CODE_INPUT_ERROR",
  "message": "Category not found"
}
```

**Solution:**
- First, call `/categories` to get a list of valid category names and slugs
- Use either the category name or slug (both are accepted)
- Check spelling and case sensitivity (category matching is case-insensitive)

### Issue: Empty Results

**Problem:** API call succeeds but returns empty results

**Possible Causes:**
- No fees match your search/filter criteria
- Category name doesn't match exactly
- Search term doesn't match any fee names or descriptions

**Solution:**
- Try a broader search term
- Check available categories using `/categories`
- Verify your filters aren't too restrictive
- Try calling `/fees` without filters to see all available fees

### Issue: Network/Connection Errors

**Problem:** Cannot connect to API

**Solution:**
- Verify the base URL is correct: `https://xmlb-8xh6-ww1h.n7e.xano.io/api:public`
- Check your internet connection
- Verify there are no firewall restrictions
- Try the request in a browser or Postman first

---

## Next Steps

1. **Explore the API:** Try different endpoints and parameters
2. **Read Full Documentation:** See [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) for complete endpoint details
3. **Check Data Sources:** Review [DATA_SOURCES.md](./DATA_SOURCES.md) to understand where data comes from
4. **Review Code Examples:** See the `examples/` directory for complete integration examples

---

## Additional Resources

- **Full API Documentation:** [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)
- **Data Sources:** [DATA_SOURCES.md](./DATA_SOURCES.md)
- **Code Examples:** See `examples/` directory
- **Postman Collection:** [View and Import Online](https://www.postman.com/nigerian-government-public-utilities-fees-api/nigerian-government-public-utilities-fees-api/request/59lkmbo/nigerian-government-fees-api?action=share&creator=27138464&ctx=documentation&active-environment=27138464-797a6ea6-1b25-4670-9850-669bb0a8ed79)

---

**Need Help?** If you encounter issues not covered here, check the full API documentation or contact the API maintainers.

