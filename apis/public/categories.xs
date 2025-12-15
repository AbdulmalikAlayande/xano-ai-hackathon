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