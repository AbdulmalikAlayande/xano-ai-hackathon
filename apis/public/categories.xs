// Returns a list of categories with fee counts
query categories verb=GET {
  api_group = "public"

  input {
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
  
    db.query categories {
      return = {type: "list"}
    } as $categories
  
    var $categories_with_counts {
      value = []
    }
  
    foreach ($categories) {
      each as $category {
        // Count fees for this category by joining subcategories
        // Using inner join ensures we only count fees with valid subcategory links
        db.query fees {
          join = {
            subcategory: {
              table: "subcategories"
              where: $db.fees.subcategory_id == $db.subcategory.id
            }
          }
        
          where = $db.subcategory.category_id == $category.id
          return = {type: "count"}
        } as $fee_count
      
        array.push $categories_with_counts {
          value = {
            id          : $category.id
            display_name: $category.name
            description : $category.description
            fee_count   : $fee_count
          }
        }
      }
    }
  }

  response = $categories_with_counts
}