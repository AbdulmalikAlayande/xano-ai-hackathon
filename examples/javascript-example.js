/**
 * Nigerian Government Fees API - JavaScript Examples
 * 
 * This file contains complete examples for all 5 API endpoints using the Fetch API.
 * Replace 'nga_your_api_key_here' with your actual API key.
 */

const BASE_URL = 'https://xmlb-8xh6-ww1h.n7e.xano.io/api:public';
const API_KEY = 'nga_your_api_key_here'; // Replace with your actual API key

/**
 * Helper function to handle API responses and errors
 */
async function handleResponse(response) {
  const data = await response.json();
  
  // Check for API-level errors
  if (data.code && data.code.startsWith('ERROR_CODE')) {
    throw new Error(`${data.code}: ${data.message}`);
  }
  
  // Check for HTTP errors
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${data.message || response.statusText}`);
  }
  
  return data;
}

/**
 * Example 1: GET /fees
 * Retrieve a paginated list of fees with optional filters
 */
async function getFees(options = {}) {
  try {
    const params = new URLSearchParams({
      page: options.page || 1,
      per_page: options.perPage || 20,
      api_key: API_KEY
    });
    
    // Add optional filters
    if (options.category) params.append('category', options.category);
    if (options.state) params.append('state', options.state);
    if (options.search) params.append('search', options.search);
    
    const response = await fetch(`${BASE_URL}/fees?${params}`);
    const data = await handleResponse(response);
    
    console.log(`Retrieved ${data.items.length} fees (Page ${data.meta.page} of ${data.meta.pageTotal})`);
    console.log(`Total: ${data.meta.total} fees`);
    
    return data;
  } catch (error) {
    console.error('Error fetching fees:', error.message);
    throw error;
  }
}

// Usage examples:
// getFees(); // Get first page with default settings
// getFees({ category: 'identity', page: 1, perPage: 10 });
// getFees({ search: 'NIN', page: 1 });

/**
 * Example 2: GET /fees/{id}
 * Retrieve a single fee by ID with all relationships
 */
async function getFeeById(feeId) {
  try {
    const params = new URLSearchParams({
      api_key: API_KEY
    });
    
    const response = await fetch(`${BASE_URL}/fees/${feeId}?${params}`);
    
    // Handle 404 specifically
    if (response.status === 404) {
      const error = await response.json();
      throw new Error(`Fee not found: ${error.message}`);
    }
    
    const data = await handleResponse(response);
    
    console.log(`Fee: ${data.name}`);
    console.log(`Amount: ${data.amount} ${data.currency}`);
    if (data.subcategory) {
      console.log(`Category: ${data.subcategory.category?.name || 'N/A'}`);
      console.log(`Subcategory: ${data.subcategory.name || 'N/A'}`);
    }
    if (data.source) {
      console.log(`Agency: ${data.source.agency?.name || 'N/A'}`);
    }
    
    return data;
  } catch (error) {
    console.error('Error fetching fee:', error.message);
    throw error;
  }
}

// Usage example:
// getFeeById(1);

/**
 * Example 3: GET /fees/search
 * Search fees by name and description
 */
async function searchFees(query) {
  try {
    // Validate query length
    if (!query || query.trim().length < 2) {
      throw new Error('Search query must be at least 2 characters long');
    }
    
    const params = new URLSearchParams({
      q: query.trim(),
      api_key: API_KEY
    });
    
    const response = await fetch(`${BASE_URL}/fees/search?${params}`);
    const data = await handleResponse(response);
    
    console.log(`Found ${data.length} fees matching "${query}"`);
    
    return data;
  } catch (error) {
    console.error('Error searching fees:', error.message);
    throw error;
  }
}

// Usage examples:
// searchFees('NIN');
// searchFees('passport');
// searchFees('JAMB');

/**
 * Example 4: GET /categories
 * Get all categories with fee counts
 */
async function getCategories() {
  try {
    const params = new URLSearchParams({
      api_key: API_KEY
    });
    
    const response = await fetch(`${BASE_URL}/categories?${params}`);
    const data = await handleResponse(response);
    
    console.log(`Found ${data.length} categories:`);
    data.forEach(category => {
      console.log(`  - ${category.display_name}: ${category.fee_count} fees`);
    });
    
    return data;
  } catch (error) {
    console.error('Error fetching categories:', error.message);
    throw error;
  }
}

// Usage example:
// getCategories();

/**
 * Example 5: GET /metadata
 * Get API statistics and metadata
 */
async function getMetadata() {
  try {
    const params = new URLSearchParams({
      api_key: API_KEY
    });
    
    const response = await fetch(`${BASE_URL}/metadata?${params}`);
    const data = await handleResponse(response);
    
    console.log('API Metadata:');
    console.log(`  Version: ${data.api_version}`);
    console.log(`  Total Fees: ${data.statistics.total_fees}`);
    console.log(`  Total Categories: ${data.statistics.total_categories}`);
    console.log(`  Total Agencies: ${data.statistics.total_agencies}`);
    console.log(`  Last Update: ${new Date(data.last_database_update).toISOString()}`);
    
    return data;
  } catch (error) {
    console.error('Error fetching metadata:', error.message);
    throw error;
  }
}

// Usage example:
// getMetadata();

/**
 * Advanced Example: Get all fees with pagination
 */
async function getAllFees(options = {}) {
  try {
    let allFees = [];
    let page = 1;
    let hasMore = true;
    
    while (hasMore) {
      const result = await getFees({
        ...options,
        page: page,
        perPage: 100 // Maximum per page
      });
      
      allFees = allFees.concat(result.items);
      
      // Check if there are more pages
      hasMore = page < result.meta.pageTotal;
      page++;
      
      // Add a small delay to avoid rate limiting (when implemented)
      if (hasMore) {
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }
    
    console.log(`Retrieved all ${allFees.length} fees`);
    return allFees;
  } catch (error) {
    console.error('Error fetching all fees:', error.message);
    throw error;
  }
}

// Usage example:
// getAllFees({ category: 'identity' });

/**
 * Advanced Example: Get fees by category with error handling
 */
async function getFeesByCategory(categorySlug) {
  try {
    // First, get all categories to validate
    const categories = await getCategories();
    const category = categories.find(cat => 
      cat.display_name.toLowerCase() === categorySlug.toLowerCase() ||
      cat.id.toString() === categorySlug
    );
    
    if (!category) {
      throw new Error(`Category "${categorySlug}" not found`);
    }
    
    console.log(`Fetching fees for category: ${category.display_name}`);
    
    // Get fees for this category
    const result = await getFees({
      category: categorySlug,
      perPage: 100
    });
    
    return {
      category: category,
      fees: result.items,
      total: result.meta.total
    };
  } catch (error) {
    console.error('Error fetching fees by category:', error.message);
    throw error;
  }
}

// Usage example:
// getFeesByCategory('identity');

/**
 * Example: Complete workflow - Search, filter, and get details
 */
async function completeWorkflow() {
  try {
    console.log('=== Nigerian Government Fees API - Complete Workflow ===\n');
    
    // Step 1: Get API metadata
    console.log('Step 1: Getting API metadata...');
    const metadata = await getMetadata();
    console.log('');
    
    // Step 2: Get all categories
    console.log('Step 2: Getting all categories...');
    const categories = await getCategories();
    console.log('');
    
    // Step 3: Search for specific fees
    console.log('Step 3: Searching for "NIN" fees...');
    const searchResults = await searchFees('NIN');
    console.log('');
    
    // Step 4: Get details of first result
    if (searchResults.length > 0) {
      console.log('Step 4: Getting details of first result...');
      const feeDetails = await getFeeById(searchResults[0].id);
      console.log('');
    }
    
    // Step 5: Get fees by category
    console.log('Step 5: Getting fees by category "identity"...');
    const categoryFees = await getFees({ category: 'identity', perPage: 5 });
    console.log('');
    
    console.log('=== Workflow Complete ===');
  } catch (error) {
    console.error('Workflow failed:', error.message);
  }
}

// Run the complete workflow
// completeWorkflow();

// Export functions for use in other modules (if using modules)
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    getFees,
    getFeeById,
    searchFees,
    getCategories,
    getMetadata,
    getAllFees,
    getFeesByCategory,
    completeWorkflow
  };
}

