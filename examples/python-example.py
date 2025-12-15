"""
Nigerian Government Fees API - Python Examples

This file contains complete examples for all 7 API endpoints using the requests library.
Replace 'nga_your_api_key_here' with your actual API key.

Installation:
    pip install requests
"""

import requests
from typing import Optional, Dict, List, Any
from datetime import datetime

BASE_URL = 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public'
API_KEY = 'nga_your_api_key_here'  # Replace with your actual API key


def handle_response(response: requests.Response) -> Dict[str, Any]:
    """
    Helper function to handle API responses and errors.
    
    Args:
        response: requests.Response object
        
    Returns:
        dict: Parsed JSON response
        
    Raises:
        requests.exceptions.HTTPError: For HTTP errors
        ValueError: For API-level errors
    """
    try:
        data = response.json()
    except ValueError:
        # If response is not JSON, raise HTTP error
        response.raise_for_status()
        return {}
    
    # Check for API-level errors
    if 'code' in data and data['code'].startswith('ERROR_CODE'):
        error_msg = data.get('message', 'Unknown API error')
        raise ValueError(f"{data['code']}: {error_msg}")
    
    # Check for HTTP errors
    response.raise_for_status()
    
    return data


def get_fees(
    category: Optional[str] = None,
    state: Optional[str] = None,
    search: Optional[str] = None,
    page: int = 1,
    per_page: int = 20
) -> Dict[str, Any]:
    """
    Example 1: GET /fees
    Retrieve a paginated list of fees with optional filters.
    
    Args:
        category: Filter by category name or slug
        state: Filter by state
        search: Search term to match against fee name and description
        page: Page number (default: 1)
        per_page: Number of results per page (default: 20, max: 100)
        
    Returns:
        dict: Response containing items and meta information
    """
    params = {
        'page': page,
        'per_page': per_page,
        'api_key': API_KEY
    }
    
    # Add optional filters
    if category:
        params['category'] = category
    if state:
        params['state'] = state
    if search:
        params['search'] = search
    
    try:
        response = requests.get(f'{BASE_URL}/fees', params=params)
        data = handle_response(response)
        
        print(f"Retrieved {len(data['items'])} fees (Page {data['meta']['page']} of {data['meta'].get('pageTotal', 1)})")
        print(f"Total: {data['meta']['total']} fees")
        
        return data
    except requests.exceptions.RequestException as e:
        print(f'Error fetching fees: {e}')
        raise


# Usage examples:
# get_fees()  # Get first page with default settings
# get_fees(category='identity', page=1, per_page=10)
# get_fees(search='NIN', page=1)


def get_fee_by_id(fee_id: int) -> Dict[str, Any]:
    """
    Example 2: GET /fees/{id}
    Retrieve a single fee by ID with all relationships.
    
    Args:
        fee_id: The fee ID
        
    Returns:
        dict: Fee object with nested relationships
    """
    params = {
        'api_key': API_KEY
    }
    
    try:
        response = requests.get(f'{BASE_URL}/fees/{fee_id}', params=params)
        
        # Handle 404 specifically
        if response.status_code == 404:
            error = response.json()
            raise ValueError(f"Fee not found: {error.get('message', 'Unknown error')}")
        
        data = handle_response(response)
        
        print(f"Fee: {data['name']}")
        print(f"Amount: {data['amount']} {data['currency']}")
        
        if 'subcategory' in data and data['subcategory']:
            subcat = data['subcategory']
            if 'category' in subcat and subcat['category']:
                print(f"Category: {subcat['category'].get('name', 'N/A')}")
            print(f"Subcategory: {subcat.get('name', 'N/A')}")
        
        if 'source' in data and data['source']:
            source = data['source']
            if 'agency' in source and source['agency']:
                print(f"Agency: {source['agency'].get('name', 'N/A')}")
        
        return data
    except requests.exceptions.RequestException as e:
        print(f'Error fetching fee: {e}')
        raise


# Usage example:
# get_fee_by_id(1)


def search_fees(query: str) -> List[Dict[str, Any]]:
    """
    Example 3: GET /fees/search
    Search fees by name and description.
    
    Args:
        query: Search query (minimum 2 characters)
        
    Returns:
        list: Array of fee objects matching the search
    """
    # Validate query length
    if not query or len(query.strip()) < 2:
        raise ValueError('Search query must be at least 2 characters long')
    
    params = {
        'q': query.strip(),
        'api_key': API_KEY
    }
    
    try:
        response = requests.get(f'{BASE_URL}/fees/search', params=params)
        data = handle_response(response)
        
        print(f"Found {len(data)} fees matching \"{query}\"")
        
        return data
    except requests.exceptions.RequestException as e:
        print(f'Error searching fees: {e}')
        raise


# Usage examples:
# search_fees('NIN')
# search_fees('passport')
# search_fees('JAMB')


def get_categories() -> List[Dict[str, Any]]:
    """
    Example 4: GET /categories
    Get all categories with fee counts.
    
    Returns:
        list: Array of category objects with fee_count
    """
    params = {
        'api_key': API_KEY
    }
    
    try:
        response = requests.get(f'{BASE_URL}/categories', params=params)
        data = handle_response(response)
        
        print(f"Found {len(data)} categories:")
        for category in data:
            print(f"  - {category['display_name']}: {category['fee_count']} fees")
        
        return data
    except requests.exceptions.RequestException as e:
        print(f'Error fetching categories: {e}')
        raise


# Usage example:
# get_categories()


def get_metadata() -> Dict[str, Any]:
    """
    Example 5: GET /metadata
    Get API statistics and metadata.
    
    Returns:
        dict: Metadata object with statistics and version information
    """
    params = {
        'api_key': API_KEY
    }
    
    try:
        response = requests.get(f'{BASE_URL}/metadata', params=params)
        data = handle_response(response)
        
        print('API Metadata:')
        print(f"  Version: {data['api_version']}")
        print(f"  Total Fees: {data['statistics']['total_fees']}")
        print(f"  Total Categories: {data['statistics']['total_categories']}")
        print(f"  Total Agencies: {data['statistics']['total_agencies']}")
        
        # Convert timestamp to readable date
        last_update = datetime.fromtimestamp(data['last_database_update'] / 1000)
        print(f"  Last Update: {last_update.isoformat()}")
        
        return data
    except requests.exceptions.RequestException as e:
        print(f'Error fetching metadata: {e}')
        raise


# Usage example:
# get_metadata()


def get_all_fees(options: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
    """
    Advanced Example: Get all fees with pagination.
    
    Args:
        options: Optional dictionary with category, state, search filters
        
    Returns:
        list: All fees matching the filters
    """
    if options is None:
        options = {}
    
    all_fees = []
    page = 1
    has_more = True
    
    while has_more:
        result = get_fees(
            category=options.get('category'),
            state=options.get('state'),
            search=options.get('search'),
            page=page,
            per_page=100  # Maximum per page
        )
        
        all_fees.extend(result['items'])
        
        # Check if there are more pages
        total_pages = result['meta'].get('pageTotal', 1)
        has_more = page < total_pages
        page += 1
        
        # Add a small delay to avoid rate limiting (when implemented)
        if has_more:
            import time
            time.sleep(0.1)
    
    print(f"Retrieved all {len(all_fees)} fees")
    return all_fees


# Usage example:
# get_all_fees({'category': 'identity'})


def get_fees_by_category(category_slug: str) -> Dict[str, Any]:
    """
    Advanced Example: Get fees by category with error handling.
    
    Args:
        category_slug: Category name or slug
        
    Returns:
        dict: Dictionary with category info and fees
    """
    try:
        # First, get all categories to validate
        categories = get_categories()
        category = next(
            (cat for cat in categories if 
             cat['display_name'].lower() == category_slug.lower() or
             str(cat['id']) == category_slug),
            None
        )
        
        if not category:
            raise ValueError(f'Category "{category_slug}" not found')
        
        print(f"Fetching fees for category: {category['display_name']}")
        
        # Get fees for this category
        result = get_fees(category=category_slug, per_page=100)
        
        return {
            'category': category,
            'fees': result['items'],
            'total': result['meta']['total']
        }
    except Exception as e:
        print(f'Error fetching fees by category: {e}')
        raise


# Usage example:
# get_fees_by_category('identity')


def complete_workflow():
    """
    Example: Complete workflow - Search, filter, and get details.
    """
    try:
        print('=== Nigerian Government Fees API - Complete Workflow ===\n')
        
        # Step 1: Get API metadata
        print('Step 1: Getting API metadata...')
        metadata = get_metadata()
        print()
        
        # Step 2: Get all categories
        print('Step 2: Getting all categories...')
        categories = get_categories()
        print()
        
        # Step 3: Search for specific fees
        print('Step 3: Searching for "NIN" fees...')
        search_results = search_fees('NIN')
        print()
        
        # Step 4: Get details of first result
        if search_results:
            print('Step 4: Getting details of first result...')
            fee_details = get_fee_by_id(search_results[0]['id'])
            print()
        
        # Step 5: Get fees by category
        print('Step 5: Getting fees by category "identity"...')
        category_fees = get_fees(category='identity', per_page=5)
        print()
        
        print('=== Workflow Complete ===')
    except Exception as e:
        print(f'Workflow failed: {e}')


# Run the complete workflow
def get_docs():
    """
    Example 6: GET /docs
    Get documentation links (no authentication required).
    
    Returns:
        dict: Documentation links object
    """
    try:
        response = requests.get(f'{BASE_URL}/docs')
        response.raise_for_status()
        data = response.json()
        
        print('Documentation Links:')
        print('Repository:', data['repository'])
        print('API Reference:', data['main_documentation']['api_reference'])
        print('Quick Start:', data['main_documentation']['quick_start'])
        
        return data
    except requests.exceptions.RequestException as e:
        print(f'Error fetching docs: {e}')
        raise


# Usage example:
# get_docs()


def generate_api_key(user_email=None):
    """
    Example 7: POST /api_key/generate
    Generate a new API key.
    
    Args:
        user_email: Optional email address to associate with the API key
        
    Returns:
        dict: Response containing the generated API key
    """
    try:
        body = {}
        if user_email:
            body['user_email'] = user_email
        
        response = requests.post(
            f'{BASE_URL}/api_key/generate',
            json=body,
            headers={'Accept': 'application/json'}
        )
        response.raise_for_status()
        data = response.json()
        
        print('API Key Generated Successfully!')
        print('API Key:', data['api_key'])
        print('Message:', data['message'])
        print('⚠️  IMPORTANT: Save this key immediately - you cannot retrieve it later!')
        
        return data
    except requests.exceptions.RequestException as e:
        print(f'Error generating API key: {e}')
        raise


# Usage examples:
# generate_api_key()  # Generate without email
# generate_api_key('user@example.com')  # Generate with email


if __name__ == '__main__':
    # Uncomment to run examples:
    # complete_workflow()
    
    # Or run individual examples:
    # get_categories()
    # search_fees('NIN')
    # get_fee_by_id(1)
    # get_fees(category='identity', per_page=5)
    # get_metadata()
    # get_docs()
    # generate_api_key('user@example.com')
    pass

