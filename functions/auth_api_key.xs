// Authentication function for API key validation
// Checks Authorization: Bearer {key} or x-api-key: {key} headers
// Validates API key from headers, checks against api_keys table, and updates request tracking
function "auth/api_key" {
  input {
    // API key from Authorization header or x-api-key header
    text api_key?
  }

  stack {
    // Check if API key was provided
    precondition ($input.api_key != null && ($input.api_key|strlen) > 0) {
      error_type = "accessdenied"
      error = "Missing API Key. Please provide Authorization: Bearer {key} or x-api-key: {key} header."
    }
  
    // Query api_keys table for matching key
    db.get api_keys {
      field_name = "key"
      field_value = $input.api_key
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
  
    var $result {
      value = {key_record: $key_record, authenticated: true}
    }
  }

  response = $result
}