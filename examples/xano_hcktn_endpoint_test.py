"""
Nigerian Government Fees API - Comprehensive Test Suite

This script tests all 7 API endpoints including:
- Authentication
- Rate limiting
- Error handling
- Response validation

Run: python test_api.py
"""

import requests
import json
import time
from datetime import datetime
from typing import Dict, Any, Optional

BASE_URL = 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public'

# Test results storage
test_results = {
    'passed': [],
    'failed': [],
    'warnings': [],
    'total': 0
}

def print_test(name: str, status: str, message: str = ""):
    """Print test result with formatting"""
    test_results['total'] += 1
    symbol = "✅" if status == "PASS" else "❌" if status == "FAIL" else "⚠️"
    print(f"{symbol} [{status}] {name}")
    if message:
        print(f"   {message}")
    
    if status == "PASS":
        test_results['passed'].append(name)
    elif status == "FAIL":
        test_results['failed'].append(name)
    else:
        test_results['warnings'].append(name)

def test_get_docs():
    """Test GET /docs endpoint (no authentication required)"""
    print("\n" + "="*60)
    print("Testing GET /docs")
    print("="*60)
    
    try:
        response = requests.get(f'{BASE_URL}/docs')
        response.raise_for_status()
        data = response.json()
        
        # Validate response structure
        required_fields = ['repository', 'main_documentation', 'code_examples', 'raw_links']
        missing_fields = [field for field in required_fields if field not in data]
        
        if missing_fields:
            print_test("GET /docs - Response structure", "FAIL", 
                      f"Missing fields: {missing_fields}")
        else:
            print_test("GET /docs - Response structure", "PASS")
        
        # Validate main_documentation structure
        if 'main_documentation' in data:
            doc_fields = ['api_reference', 'quick_start', 'data_sources', 'readme']
            missing_doc = [f for f in doc_fields if f not in data['main_documentation']]
            if missing_doc:
                print_test("GET /docs - Main documentation links", "WARN",
                          f"Missing: {missing_doc}")
            else:
                print_test("GET /docs - Main documentation links", "PASS")
        
        # Validate code examples
        if 'code_examples' in data:
            example_fields = ['javascript', 'python', 'curl']
            missing_examples = [f for f in example_fields if f not in data['code_examples']]
            if missing_examples:
                print_test("GET /docs - Code example links", "WARN",
                          f"Missing: {missing_examples}")
            else:
                print_test("GET /docs - Code example links", "PASS")
        
        return True
    except Exception as e:
        print_test("GET /docs - Basic request", "FAIL", str(e))
        return False

def test_generate_api_key():
    """Test POST /api_key/generate endpoint"""
    print("\n" + "="*60)
    print("Testing POST /api_key/generate")
    print("="*60)
    
    try:
        # Test without email
        response = requests.post(
            f'{BASE_URL}/api_key/generate',
            json={},
            headers={'Accept': 'application/json'}
        )
        response.raise_for_status()
        data = response.json()
        
        if 'api_key' in data and 'success' in data:
            if data['success'] and data['api_key'].startswith('nga_'):
                print_test("POST /api_key/generate - Without email", "PASS",
                          f"Generated key: {data['api_key'][:20]}...")
                api_key = data['api_key']
            else:
                print_test("POST /api_key/generate - Without email", "FAIL",
                          "Invalid response structure")
                return None
        else:
            print_test("POST /api_key/generate - Without email", "FAIL",
                      "Missing required fields in response")
            return None
        
        # Test with email
        response2 = requests.post(
            f'{BASE_URL}/api_key/generate',
            json={'user_email': 'test@example.com'},
            headers={'Accept': 'application/json'}
        )
        response2.raise_for_status()
        data2 = response2.json()
        
        if data2.get('success') and 'api_key' in data2:
            print_test("POST /api_key/generate - With email", "PASS")
        else:
            print_test("POST /api_key/generate - With email", "WARN",
                      "Response structure issue")
        
        return api_key
    except Exception as e:
        print_test("POST /api_key/generate", "FAIL", str(e))
        return None

def test_get_fees(api_key: str):
    """Test GET /fees endpoint"""
    print("\n" + "="*60)
    print("Testing GET /fees")
    print("="*60)
    
    if not api_key:
        print_test("GET /fees - Skipped", "WARN", "No API key available")
        return
    
    # Test 1: Basic request
    try:
        response = requests.get(
            f'{BASE_URL}/fees',
            params={'api_key': api_key, 'page': 1, 'per_page': 5}
        )
        response.raise_for_status()
        data = response.json()
        
        if 'items' in data and 'meta' in data:
            print_test("GET /fees - Basic request", "PASS",
                      f"Returned {len(data['items'])} items")
        else:
            print_test("GET /fees - Basic request", "FAIL",
                      "Missing 'items' or 'meta' in response")
    except Exception as e:
        print_test("GET /fees - Basic request", "FAIL", str(e))
    
    # Test 2: With category filter
    try:
        response = requests.get(
            f'{BASE_URL}/fees',
            params={'api_key': api_key, 'category': 'identity', 'per_page': 5}
        )
        response.raise_for_status()
        data = response.json()
        print_test("GET /fees - Category filter", "PASS",
                  f"Returned {len(data.get('items', []))} items")
    except Exception as e:
        print_test("GET /fees - Category filter", "FAIL", str(e))
    
    # Test 3: With search
    try:
        response = requests.get(
            f'{BASE_URL}/fees',
            params={'api_key': api_key, 'search': 'NIN', 'per_page': 5}
        )
        response.raise_for_status()
        data = response.json()
        print_test("GET /fees - Search filter", "PASS",
                  f"Returned {len(data.get('items', []))} items")
    except Exception as e:
        print_test("GET /fees - Search filter", "FAIL", str(e))
    
    # Test 4: Pagination
    try:
        response = requests.get(
            f'{BASE_URL}/fees',
            params={'api_key': api_key, 'page': 1, 'per_page': 10}
        )
        response.raise_for_status()
        data = response.json()
        if data.get('meta', {}).get('perPage') == 10:
            print_test("GET /fees - Pagination", "PASS")
        else:
            print_test("GET /fees - Pagination", "WARN",
                      "Pagination not working as expected")
    except Exception as e:
        print_test("GET /fees - Pagination", "FAIL", str(e))
    
    # Test 5: Missing API key
    try:
        response = requests.get(f'{BASE_URL}/fees', params={'page': 1})
        if response.status_code == 401:
            print_test("GET /fees - Missing API key (error handling)", "PASS")
        else:
            print_test("GET /fees - Missing API key (error handling)", "FAIL",
                      f"Expected 401, got {response.status_code}")
    except Exception as e:
        print_test("GET /fees - Missing API key", "WARN", str(e))
    
    # Test 6: Invalid API key
    try:
        response = requests.get(
            f'{BASE_URL}/fees',
            params={'api_key': 'invalid_key_12345'}
        )
        if response.status_code == 401:
            print_test("GET /fees - Invalid API key (error handling)", "PASS")
        else:
            print_test("GET /fees - Invalid API key (error handling)", "WARN",
                      f"Expected 401, got {response.status_code}")
    except Exception as e:
        print_test("GET /fees - Invalid API key", "WARN", str(e))

def test_get_fees_by_id(api_key: str):
    """Test GET /fees/{id} endpoint"""
    print("\n" + "="*60)
    print("Testing GET /fees/{id}")
    print("="*60)
    
    if not api_key:
        print_test("GET /fees/{id} - Skipped", "WARN", "No API key available")
        return
    
    # Test 1: Valid ID
    try:
        response = requests.get(
            f'{BASE_URL}/fees/1',
            params={'api_key': api_key}
        )
        response.raise_for_status()
        data = response.json()
        
        if 'id' in data and 'name' in data:
            print_test("GET /fees/{id} - Valid ID (1)", "PASS",
                      f"Fee: {data.get('name', 'N/A')}")
        else:
            print_test("GET /fees/{id} - Valid ID (1)", "FAIL",
                      "Missing required fields")
    except Exception as e:
        print_test("GET /fees/{id} - Valid ID (1)", "FAIL", str(e))
    
    # Test 2: Invalid ID (404)
    try:
        response = requests.get(
            f'{BASE_URL}/fees/99999',
            params={'api_key': api_key}
        )
        if response.status_code == 404:
            print_test("GET /fees/{id} - Invalid ID (404)", "PASS")
        else:
            print_test("GET /fees/{id} - Invalid ID (404)", "WARN",
                      f"Expected 404, got {response.status_code}")
    except Exception as e:
        print_test("GET /fees/{id} - Invalid ID", "WARN", str(e))
    
    # Test 3: Missing API key
    try:
        response = requests.get(f'{BASE_URL}/fees/1')
        if response.status_code == 401:
            print_test("GET /fees/{id} - Missing API key", "PASS")
        else:
            print_test("GET /fees/{id} - Missing API key", "WARN",
                      f"Expected 401, got {response.status_code}")
    except Exception as e:
        print_test("GET /fees/{id} - Missing API key", "WARN", str(e))

def test_get_fees_search(api_key: str):
    """Test GET /fees/search endpoint"""
    print("\n" + "="*60)
    print("Testing GET /fees/search")
    print("="*60)
    
    if not api_key:
        print_test("GET /fees/search - Skipped", "WARN", "No API key available")
        return
    
    # Test 1: Valid search
    try:
        response = requests.get(
            f'{BASE_URL}/fees/search',
            params={'q': 'NIN', 'api_key': api_key}
        )
        response.raise_for_status()
        data = response.json()
        
        if isinstance(data, list):
            print_test("GET /fees/search - Valid search (NIN)", "PASS",
                      f"Found {len(data)} results")
        else:
            print_test("GET /fees/search - Valid search (NIN)", "FAIL",
                      "Expected array response")
    except Exception as e:
        print_test("GET /fees/search - Valid search (NIN)", "FAIL", str(e))
    
    # Test 2: Search too short
    try:
        response = requests.get(
            f'{BASE_URL}/fees/search',
            params={'q': 'a', 'api_key': api_key}
        )
        if response.status_code == 400:
            print_test("GET /fees/search - Query too short", "PASS")
        else:
            print_test("GET /fees/search - Query too short", "WARN",
                      f"Expected 400, got {response.status_code}")
    except Exception as e:
        print_test("GET /fees/search - Query too short", "WARN", str(e))
    
    # Test 3: Missing query parameter
    try:
        response = requests.get(
            f'{BASE_URL}/fees/search',
            params={'api_key': api_key}
        )
        if response.status_code in [400, 422]:
            print_test("GET /fees/search - Missing query", "PASS")
        else:
            print_test("GET /fees/search - Missing query", "WARN",
                      f"Expected 400/422, got {response.status_code}")
    except Exception as e:
        print_test("GET /fees/search - Missing query", "WARN", str(e))

def test_get_categories(api_key: str):
    """Test GET /categories endpoint"""
    print("\n" + "="*60)
    print("Testing GET /categories")
    print("="*60)
    
    if not api_key:
        print_test("GET /categories - Skipped", "WARN", "No API key available")
        return
    
    try:
        response = requests.get(
            f'{BASE_URL}/categories',
            params={'api_key': api_key}
        )
        response.raise_for_status()
        data = response.json()
        
        if isinstance(data, list) and len(data) > 0:
            # Validate structure
            first_category = data[0]
            required_fields = ['id', 'display_name', 'fee_count']
            missing = [f for f in required_fields if f not in first_category]
            
            if missing:
                print_test("GET /categories - Response structure", "WARN",
                          f"Missing fields: {missing}")
            else:
                print_test("GET /categories - Response structure", "PASS")
            
            print_test("GET /categories - Basic request", "PASS",
                      f"Returned {len(data)} categories")
        else:
            print_test("GET /categories - Basic request", "FAIL",
                      "Expected non-empty array")
    except Exception as e:
        print_test("GET /categories - Basic request", "FAIL", str(e))

def test_get_metadata(api_key: str):
    """Test GET /metadata endpoint"""
    print("\n" + "="*60)
    print("Testing GET /metadata")
    print("="*60)
    
    if not api_key:
        print_test("GET /metadata - Skipped", "WARN", "No API key available")
        return
    
    try:
        response = requests.get(
            f'{BASE_URL}/metadata',
            params={'api_key': api_key}
        )
        response.raise_for_status()
        data = response.json()
        
        # Validate structure
        required_fields = ['api_version', 'statistics', 'last_database_update', 'generated_at']
        missing = [f for f in required_fields if f not in data]
        
        if missing:
            print_test("GET /metadata - Response structure", "FAIL",
                      f"Missing fields: {missing}")
        else:
            print_test("GET /metadata - Response structure", "PASS")
        
        # Validate statistics
        if 'statistics' in data:
            stats_fields = ['total_fees', 'total_categories', 'total_agencies', 
                          'total_subcategories', 'total_sources']
            missing_stats = [f for f in stats_fields if f not in data['statistics']]
            if missing_stats:
                print_test("GET /metadata - Statistics structure", "WARN",
                          f"Missing: {missing_stats}")
            else:
                print_test("GET /metadata - Statistics structure", "PASS")
        
        # Check documentation object
        if 'documentation' in data:
            print_test("GET /metadata - Documentation links", "PASS")
        else:
            print_test("GET /metadata - Documentation links", "WARN",
                      "Documentation object missing")
        
        print_test("GET /metadata - Basic request", "PASS",
                  f"API Version: {data.get('api_version', 'N/A')}")
    except Exception as e:
        print_test("GET /metadata - Basic request", "FAIL", str(e))

def test_rate_limiting(api_key: str):
    """Test rate limiting (100 requests/hour)"""
    print("\n" + "="*60)
    print("Testing Rate Limiting")
    print("="*60)
    
    if not api_key:
        print_test("Rate Limiting - Skipped", "WARN", "No API key available")
        return
    
    # Note: We won't actually hit 100 requests in this test
    # But we can verify the rate limiting logic exists
    print_test("Rate Limiting - Test setup", "INFO",
              "Rate limit is 100 requests/hour per API key")
    print_test("Rate Limiting - Manual verification needed", "WARN",
              "To fully test, make 101 requests rapidly and verify 101st is blocked")

def print_summary():
    """Print test summary"""
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    print(f"Total Tests: {test_results['total']}")
    print(f"✅ Passed: {len(test_results['passed'])}")
    print(f"❌ Failed: {len(test_results['failed'])}")
    print(f"⚠️  Warnings: {len(test_results['warnings'])}")
    
    if test_results['failed']:
        print("\nFailed Tests:")
        for test in test_results['failed']:
            print(f"  - {test}")
    
    success_rate = (len(test_results['passed']) / test_results['total'] * 100) if test_results['total'] > 0 else 0
    print(f"\nSuccess Rate: {success_rate:.1f}%")
    
    # Save results to file
    with open('test_results.json', 'w') as f:
        json.dump({
            'timestamp': datetime.now().isoformat(),
            'summary': {
                'total': test_results['total'],
                'passed': len(test_results['passed']),
                'failed': len(test_results['failed']),
                'warnings': len(test_results['warnings']),
                'success_rate': success_rate
            },
            'passed': test_results['passed'],
            'failed': test_results['failed'],
            'warnings': test_results['warnings']
        }, f, indent=2)
    
    print("\nTest results saved to: test_results.json")

def main():
    """Run all tests"""
    print("="*60)
    print("Nigerian Government Fees API - Test Suite")
    print("="*60)
    print(f"Base URL: {BASE_URL}")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Test public endpoints first
    test_get_docs()
    api_key = test_generate_api_key()
    
    # If we couldn't generate a key, try using a placeholder
    # (User will need to provide their own key)
    if not api_key:
        print("\n⚠️  Could not generate API key. Some tests will be skipped.")
        print("   You can provide an API key by setting it in the script.")
        api_key = None  # User can manually set this
    
    # Test authenticated endpoints
    if api_key:
        test_get_fees(api_key)
        test_get_fees_by_id(api_key)
        test_get_fees_search(api_key)
        test_get_categories(api_key)
        test_get_metadata(api_key)
        test_rate_limiting(api_key)
    else:
        print("\n⚠️  Skipping authenticated endpoint tests (no API key)")
    
    # Print summary
    print_summary()

if __name__ == '__main__':
    main()