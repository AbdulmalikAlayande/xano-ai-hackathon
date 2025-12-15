// Generates a new API key with the format nga_[32_chars] and saves it to the database.
query "api_key/generate" verb=POST {
  api_group = "public"

  input {
    // Optional email address to associate with the API key
    email user_email?
  }

  stack {
    // Generate 32 random alphanumeric characters
    security.create_password {
      character_count = 32
      require_lowercase = true
      require_uppercase = true
      require_digit = true
      require_symbol = false
      symbol_whitelist = ""
    } as $random_suffix
  
    // Construct the full API key with the required prefix
    var $generated_key {
      value = "nga_" ~ $random_suffix
    }
  
    // Save the new key to the database
    db.add api_keys {
      data = {
        key          : $generated_key
        user_email   : $input.user_email
        is_active    : true
        request_count: 0
        last_reset_at: "now"
      }
    } as $new_api_key_record
  }

  response = {
    success: true
    api_key: $new_api_key_record.key
    message: "API key generated successfully. Please save this key as it provides access to the API."
  }
}