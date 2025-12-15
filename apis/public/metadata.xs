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
    // TODO: Update this with your actual GitHub repository URL
    var $github_base {
      value = "https://github.com/yourusername/xano-ai-app"
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