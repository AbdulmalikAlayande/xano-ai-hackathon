// Generate and insert 3 test API keys into the database
// Creates API keys for testing, judges, and documentation examples
// Generates and inserts 3 test API keys into the api_keys table. Creates keys for testing, judges, and documentation.
function "admin/generate_api_keys" {
  input {
  }

  stack {
    // Check and delete any existing malformed or test keys to avoid duplicates
    db.query "" {
      where = ($db.api_keys.user_email == "test@example.com") || ($db.api_keys.user_email == "judge@example.com") || ($db.api_keys.user_email == "docs@example.com") || ($db.api_keys.key == "nga_")
      return = {type: "list"}
    } as $existing_keys
  
    foreach ($existing_keys) {
      each as $existing_key {
        db.del "" {
          field_name = "id"
          field_value = $existing_key.id
        }
      }
    }
  
    // Generate API key 1: For testing
    security.create_uuid as $uuid_1
  
    var $uuid_clean_1 {
      value = $uuid_1|replace:"-":""
    }
  
    var $key_1 {
      value = "nga_" ~ ($uuid_clean_1|slice:0:32)
    }
  
    // Generate API key 2: For judges (JUDGE_KEY)
    security.create_uuid as $uuid_2
  
    var $uuid_clean_2 {
      value = $uuid_2|replace:"-":""
    }
  
    var $key_2 {
      value = "nga_" ~ ($uuid_clean_2|slice:0:32)
    }
  
    // Generate API key 3: For documentation examples
    security.create_uuid as $uuid_3
  
    var $uuid_clean_3 {
      value = $uuid_3|replace:"-":""
    }
  
    var $key_3 {
      value = "nga_" ~ ($uuid_clean_3|slice:0:32)
    }
  
    // Insert API key 1: For testing
    db.add "" {
      data = {
        key          : $key_1
        user_email   : "test@example.com"
        is_active    : true
        request_count: 0
        created_at   : now
        last_reset_at: now
      }
    } as $api_key_1
  
    // Insert API key 2: For judges
    db.add "" {
      data = {
        key          : $key_2
        user_email   : "judge@example.com"
        is_active    : true
        request_count: 0
        created_at   : now
        last_reset_at: now
      }
    } as $api_key_2
  
    // Insert API key 3: For documentation
    db.add "" {
      data = {
        key          : $key_3
        user_email   : "docs@example.com"
        is_active    : true
        request_count: 0
        created_at   : now
        last_reset_at: now
      }
    } as $api_key_3
  
    var $result {
      value = {
        success: true
        message: "3 API keys generated and inserted successfully"
        keys   : [
          {
            id: $api_key_1.id
            key: $api_key_1.key
            label: "Testing Key"
            user_email: $api_key_1.user_email
          }
          {
            id: $api_key_2.id
            key: $api_key_2.key
            label: "Judge Key (JUDGE_KEY)"
            user_email: $api_key_2.user_email
          }
          {
            id: $api_key_3.id
            key: $api_key_3.key
            label: "Documentation Key"
            user_email: $api_key_3.user_email
          }
        ]
      }
    }
  }

  response = $result
}