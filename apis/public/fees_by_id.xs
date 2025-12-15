// GET /fees/{id} - Returns a single fee by ID with all relationships
// Returns a single government fee by ID with all relationships including subcategory, category, agency, and source. Returns 404 if not found.
query "fees/{id}" verb=GET {
  api_group = "public"

  input {
    // Fee ID
    int id filters=min:1
  
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
  
    // Retrieve the main fee record by ID
    db.get fees {
      field_name = "id"
      field_value = $input.id
    } as $fee
  
    // Validate fee exists before fetching relationships
    precondition ($fee != null) {
      error_type = "notfound"
      error = "Fee not found with ID " ~ ($input.id|to_text)
    }
  
    // Fetch Subcategory and its parent Category
    conditional {
      if ($fee.subcategory_id != null) {
        db.get subcategories {
          field_name = "id"
          field_value = $fee.subcategory_id
        } as $subcategory
      
        conditional {
          if ($subcategory != null && $subcategory.category_id != null) {
            db.get categories {
              field_name = "id"
              field_value = $subcategory.category_id
            } as $category
          
            // Nest category inside subcategory
            var.update $subcategory {
              value = $subcategory|set:"category":$category
            }
          }
        }
      
        // Nest subcategory inside fee
        var.update $fee {
          value = $fee|set:"subcategory":$subcategory
        }
      }
    }
  
    // Fetch Source and its parent Agency
    conditional {
      if ($fee.source_id != null) {
        db.get sources {
          field_name = "id"
          field_value = $fee.source_id
        } as $source
      
        conditional {
          if ($source != null && $source.agency_id != null) {
            db.get agencies {
              field_name = "id"
              field_value = $source.agency_id
            } as $agency
          
            // Nest agency inside source
            var.update $source {
              value = $source|set:"agency":$agency
            }
          }
        }
      
        // Nest source inside fee
        var.update $fee {
          value = $fee|set:"source":$source
        }
      }
    }
  }

  response = $fee
}