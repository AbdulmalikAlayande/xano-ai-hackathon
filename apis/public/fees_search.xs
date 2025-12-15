// GET /fees/search - Search fees by query parameter
// Searches fees by name and description using the 'q' query parameter. Returns up to 20 results with all relationships included.
query "fees/search" verb=GET {
  api_group = "public"

  input {
    // Search query (required, minimum 2 characters). Searches in fee name and description.
    text q filters=trim|min:2
  
    // API key for authentication (required)
    text api_key
  }

  stack {
    // Authenticate API key
    var $api_key_value {
      value = $input.api_key
    }
  
    // If api_key starts with "Bearer ", extract the actual key
    conditional {
      if ($api_key_value != null && (($api_key_value|index:"Bearer ") == 0)) {
        var.update $api_key_value {
          value = $api_key_value|replace:"Bearer ":""
        }
      
        var.update $api_key_value {
          value = $api_key_value|trim
        }
      }
    }
  
    // Check if API key was provided
    precondition ($api_key_value != null && ($api_key_value|strlen) > 0) {
      error_type = "accessdenied"
      error = "Missing API Key. Please provide api_key query parameter."
    }
  
    // Query api_keys table for matching key
    db.get api_keys {
      field_name = "key"
      field_value = $api_key_value
    } as $key_record
  
    // Check if key exists and is active
    precondition ($key_record != null && $key_record.is_active) {
      error_type = "accessdenied"
      error = "Invalid or inactive API Key."
    }
  
    // ===== RATE LIMITING BLOCK START =====
    // This entire block can be removed to disable rate limiting
    // Rate limit: 100 requests per hour per API key
  
    // Calculate 1 hour ago timestamp
    var $one_hour_ago {
      value = now
        |transform_timestamp:"-1 hour":"UTC"
    }
  
    // Check if reset is needed (last_reset_at is null or >1 hour ago)
    var $needs_reset {
      value = ($key_record.last_reset_at == null) || ($key_record.last_reset_at < $one_hour_ago)
    }
  
    // Reset count if needed
    conditional {
      if ($needs_reset) {
        db.edit api_keys {
          field_name = "id"
          field_value = $key_record.id
          data = {request_count: 0, last_reset_at: now}
        }
      
        // Update key_record for rate limit check
        var.update $key_record {
          value = $key_record|set:"request_count":0
        }
      }
    }
  
    // Check if rate limit exceeded (after potential reset)
    var $current_count {
      value = $key_record.request_count|first_notnull:0
    }
  
    precondition ($current_count < 100) {
      error_type = "accessdenied"
      error = "Rate limit exceeded. Maximum 100 requests per hour. Please try again later."
    }
  
    // ===== RATE LIMITING BLOCK END =====
  
    // Increment request_count and update last_request_at
    db.edit api_keys {
      field_name = "id"
      field_value = $key_record.id
      data = {
        request_count  : ($key_record.request_count|first_notnull:0) + 1
        last_request_at: now
      }
    }
  
    // Validate query parameter
    // Validate search query is at least 2 characters
    precondition (($input.q|strlen) >= 2) {
      error_type = "inputerror"
      error = "Search query 'q' must be at least 2 characters long"
    }
  
    // Search fees with relationships
    db.query fees {
      join = {
        subcategory: {
          table: "subcategories"
          type : "left"
          where: $db.fees.subcategory_id == $db.subcategory.id
        }
        category   : {
          table: "categories"
          type : "left"
          where: $db.subcategory.category_id == $db.category.id
        }
        source     : {
          table: "sources"
          type : "left"
          where: $db.fees.source_id == $db.source.id
        }
        agency     : {
          table: "agencies"
          type : "left"
          where: $db.source.agency_id == $db.agency.id
        }
      }
    
      where = (($db.fees.name includes $input.q) || ($db.fees.description includes $input.q))
      sort = {fees.name: "asc"}
      return = {type: "list", paging: {page: 1, per_page: 20}}
    } as $search_results
  }

  response = $search_results.items
}