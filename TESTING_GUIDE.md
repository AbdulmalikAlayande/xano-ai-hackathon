# API Endpoint Testing Guide
## Task 1.3: Test Each Endpoint

Follow this guide to systematically test all 5 API endpoints in Xano UI.

## Prerequisites
- ✅ All endpoints pushed to Xano via XanoScript extension
- ✅ Database seeded with test data (run `POST /seed_database` if needed)
- ✅ Xano workspace accessible

---

## 1. GET /fees - List All Fees with Filters

### Test Cases:

#### Test 1.1: Get All Fees (No Filters)
- **URL:** `/fees`
- **Expected:** Returns all fees with pagination (default limit: 50)
- **Verify:**
  - [ ] Response has `data` array with fee objects
  - [ ] Response has `meta` object with `total`, `limit`, `offset`, `page`
  - [ ] Each fee includes relationships: `category`, `subcategory`, `agency`, `source`
  - [ ] Fees are sorted by category name, then fee name

#### Test 1.2: Filter by Category
- **URL:** `/fees?category=identity`
- **Expected:** Returns only fees in "identity" category
- **Verify:**
  - [ ] All returned fees have `category.slug == "identity"`
  - [ ] Relationships are included
  - [ ] Count matches expected number

#### Test 1.3: Filter by Category (Different Category)
- **URL:** `/fees?category=education`
- **Expected:** Returns only fees in "education" category
- **Verify:**
  - [ ] All returned fees have `category.slug == "education"`
  - [ ] Different results from identity category

#### Test 1.4: Search Filter
- **URL:** `/fees?search=passport`
- **Expected:** Returns fees matching "passport" in name or description
- **Verify:**
  - [ ] All results contain "passport" in name or description (case-insensitive)
  - [ ] Relationships are included

#### Test 1.5: Combined Filters (Category + Search)
- **URL:** `/fees?category=identity&search=NIN`
- **Expected:** Returns fees in identity category matching "NIN"
- **Verify:**
  - [ ] Results match both filters
  - [ ] All have category slug "identity"
  - [ ] All contain "NIN" in name or description

#### Test 1.6: Pagination - Limit
- **URL:** `/fees?limit=10`
- **Expected:** Returns exactly 10 fees
- **Verify:**
  - [ ] `data` array has 10 items (or fewer if total < 10)
  - [ ] `meta.limit` equals 10
  - [ ] `meta.total` shows total count

#### Test 1.7: Pagination - Offset
- **URL:** `/fees?limit=10&offset=10`
- **Expected:** Returns next 10 fees (page 2)
- **Verify:**
  - [ ] Different results from offset=0
  - [ ] `meta.offset` equals 10
  - [ ] `meta.page` equals 2

#### Test 1.8: Pagination - Edge Cases
- **URL:** `/fees?limit=1&offset=0`
- **Expected:** Returns 1 fee
- **Verify:**
  - [ ] Only 1 item in data array
  - [ ] Pagination metadata is correct

#### Test 1.9: Invalid Limit (Should be Rejected)
- **URL:** `/fees?limit=200`
- **Expected:** Should reject (max is 100) OR cap at 100
- **Verify:**
  - [ ] Either error message OR results capped at 100

#### Test 1.10: Negative Offset (Should be Rejected)
- **URL:** `/fees?offset=-1`
- **Expected:** Should reject or default to 0
- **Verify:**
  - [ ] Either error message OR offset defaults to 0

---

## 2. GET /fees/{id} - Get Single Fee by ID

### Test Cases:

#### Test 2.1: Get Valid Fee
- **URL:** `/fees/1` (use actual ID from your database)
- **Expected:** Returns single fee object with all relationships
- **Verify:**
  - [ ] Returns single fee object (not array)
  - [ ] Includes all fields: id, name, amount, currency, etc.
  - [ ] Includes `category` object with id, name, slug, description
  - [ ] Includes `subcategory` object
  - [ ] Includes `agency` object
  - [ ] Includes `source` object

#### Test 2.2: Get Different Fee
- **URL:** `/fees/2` (use different valid ID)
- **Expected:** Returns different fee
- **Verify:**
  - [ ] Different fee data returned
  - [ ] All relationships present

#### Test 2.3: Invalid ID - Non-existent
- **URL:** `/fees/99999`
- **Expected:** Returns 404 error
- **Verify:**
  - [ ] HTTP status code is 404
  - [ ] Error message: "Fee not found with ID 99999"
  - [ ] Error type is "notfound"

#### Test 2.4: Invalid ID - Zero
- **URL:** `/fees/0`
- **Expected:** Should reject (min: 1)
- **Verify:**
  - [ ] Error message about invalid ID

#### Test 2.5: Invalid ID - Negative
- **URL:** `/fees/-1`
- **Expected:** Should reject
- **Verify:**
  - [ ] Error message about invalid ID

---

## 3. GET /categories - List All Categories

### Test Cases:

#### Test 3.1: Get All Categories
- **URL:** `/categories`
- **Expected:** Returns array of categories with fee counts
- **Verify:**
  - [ ] Returns array of category objects
  - [ ] Each category has: id, name, slug, description
  - [ ] Each category has `fee_count` field
  - [ ] Each category has `subcategories` array
  - [ ] Categories are sorted alphabetically by name

#### Test 3.2: Verify Fee Counts
- **URL:** `/categories`
- **Expected:** Fee counts are accurate
- **Verify:**
  - [ ] Count fee_count for each category manually
  - [ ] Compare with actual fees in database
  - [ ] Counts match expected values

#### Test 3.3: Verify Subcategories
- **URL:** `/categories`
- **Expected:** Each category includes subcategories
- **Verify:**
  - [ ] Each category has `subcategories` array
  - [ ] Each subcategory has: id, name, slug, description, fee_count
  - [ ] Subcategory fee counts are accurate
  - [ ] Subcategories are sorted alphabetically

#### Test 3.4: Empty Categories (If Any)
- **URL:** `/categories`
- **Expected:** Categories with 0 fees still appear
- **Verify:**
  - [ ] Categories with no fees show `fee_count: 0`
  - [ ] Empty subcategories arrays are present

---

## 4. GET /fees/search - Search Fees

### Test Cases:

#### Test 4.1: Basic Search
- **URL:** `/fees/search?q=passport`
- **Expected:** Returns fees matching "passport"
- **Verify:**
  - [ ] Returns array of fee objects
  - [ ] All results contain "passport" in name or description (case-insensitive)
  - [ ] Maximum 20 results returned
  - [ ] All relationships included

#### Test 4.2: Search Different Term
- **URL:** `/fees/search?q=jamb`
- **Expected:** Returns fees matching "jamb"
- **Verify:**
  - [ ] Different results from "passport" search
  - [ ] All results relevant to "jamb"
  - [ ] Relationships included

#### Test 4.3: Search with Partial Match
- **URL:** `/fees/search?q=NIN`
- **Expected:** Returns fees with "NIN" in name or description
- **Verify:**
  - [ ] Results include partial matches
  - [ ] Case-insensitive matching works

#### Test 4.4: Search with No Results
- **URL:** `/fees/search?q=xyzabc123`
- **Expected:** Returns empty array
- **Verify:**
  - [ ] Returns empty array `[]`
  - [ ] No error thrown
  - [ ] HTTP status is 200

#### Test 4.5: Missing Query Parameter
- **URL:** `/fees/search`
- **Expected:** Should return error (q is required)
- **Verify:**
  - [ ] Error message about missing 'q' parameter
  - [ ] HTTP status indicates error (400 or similar)

#### Test 4.6: Query Too Short
- **URL:** `/fees/search?q=a`
- **Expected:** Should reject (minimum 2 characters)
- **Verify:**
  - [ ] Error message: "Search query 'q' must be at least 2 characters long"
  - [ ] Error type is "inputerror"

#### Test 4.7: Query Exactly 2 Characters
- **URL:** `/fees/search?q=ab`
- **Expected:** Should work (minimum is 2)
- **Verify:**
  - [ ] Returns results (if any match)
  - [ ] No error thrown

---

## 5. GET /metadata - API Statistics

### Test Cases:

#### Test 5.1: Get Metadata
- **URL:** `/metadata`
- **Expected:** Returns API statistics
- **Verify:**
  - [ ] Response has `api_version` field (value: "1.0.0")
  - [ ] Response has `statistics` object with:
    - [ ] `total_fees` (integer)
    - [ ] `total_categories` (integer)
    - [ ] `total_agencies` (integer)
    - [ ] `total_subcategories` (integer)
    - [ ] `total_sources` (integer)
  - [ ] Response has `last_database_update` (timestamp)
  - [ ] Response has `generated_at` (timestamp)

#### Test 5.2: Verify Counts Match Database
- **URL:** `/metadata`
- **Expected:** Counts are accurate
- **Verify:**
  - [ ] `total_fees` matches actual count in fees table
  - [ ] `total_categories` matches actual count in categories table
  - [ ] `total_agencies` matches actual count in agencies table
  - [ ] `total_subcategories` matches actual count in subcategories table
  - [ ] `total_sources` matches actual count in sources table

#### Test 5.3: Verify Timestamps
- **URL:** `/metadata`
- **Expected:** Timestamps are valid
- **Verify:**
  - [ ] `last_database_update` is a valid timestamp
  - [ ] `generated_at` is current timestamp
  - [ ] `last_database_update` matches most recent `updated_at` in fees table

---

## Testing Checklist Summary

### Quick Test (5 minutes)
- [ ] GET /fees - returns data
- [ ] GET /fees/1 - returns single fee
- [ ] GET /categories - returns categories
- [ ] GET /fees/search?q=passport - returns results
- [ ] GET /metadata - returns statistics

### Full Test (1 hour)
- [ ] All test cases above completed
- [ ] All relationships verified
- [ ] All error cases tested
- [ ] All edge cases tested
- [ ] Response formats verified

---

## Common Issues to Watch For

1. **Missing Relationships:** If category, subcategory, agency, or source are null
2. **Pagination Errors:** If offset/limit don't work correctly
3. **Search Not Working:** If search doesn't find expected results
4. **404 Errors:** If valid IDs return 404
5. **Count Mismatches:** If fee counts don't match database

---

## Next Steps After Testing

1. **Document Issues:** Create "AI Generation Report" (Task 1.4)
2. **Fix Critical Bugs:** Address any blocking issues
3. **Move to Day 2:** Start refining endpoints (Task 2.1)

---

## Notes

- Record any errors or unexpected behavior
- Take screenshots of successful responses
- Note response times
- Document any missing features

