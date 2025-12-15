// GET /metadata - Returns API statistics and metadata
// Returns API statistics including total fees count, total categories count, total agencies count, last database update timestamp, and API version number.
query metadata verb=GET {
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
  
    // Count total fees
    db.query fees {
      return = {type: "count"}
    } as $total_fees
  
    // Count total categories
    db.query categories {
      return = {type: "count"}
    } as $total_categories
  
    // Count total agencies
    db.query agencies {
      return = {type: "count"}
    } as $total_agencies
  
    // Count total subcategories
    db.query subcategories {
      return = {type: "count"}
    } as $total_subcategories
  
    // Count total sources
    db.query sources {
      return = {type: "count"}
    } as $total_sources
  
    // Get last update timestamp from fees table
    db.query fees {
      sort = {fees.updated_at: "desc"}
      return = {type: "single"}
    } as $latest_fee
  
    var $last_update {
      value = ($latest_fee != null) ? $latest_fee.updated_at : now
    }
  
    // GitHub repository base URL
    var $github_base {
      value = "https://github.com/AbdulmalikAlayande/xano-ai-hackathon"
    }
  
    // Build metadata response
    var $metadata {
      value = {
        api_version         : "1.0.0"
        statistics          : {
          total_fees: $total_fees
          total_categories: $total_categories
          total_agencies: $total_agencies
          total_subcategories: $total_subcategories
          total_sources: $total_sources
        }
        last_database_update: $last_update
        generated_at        : now
        documentation       : {
          repository: $github_base
          api_reference: $github_base ~ "/blob/main/API_DOCUMENTATION.md"
          quick_start: $github_base ~ "/blob/main/QUICK_START.md"
          data_sources: $github_base ~ "/blob/main/DATA_SOURCES.md"
          readme: $github_base ~ "/blob/main/README.md"
          examples: {
            javascript: $github_base ~ "/blob/main/examples/javascript-example.js"
            python: $github_base ~ "/blob/main/examples/python-example.py"
            curl: $github_base ~ "/blob/main/examples/curl-examples.sh"
          }
        }
      }
    }
  }

  response = $metadata
}