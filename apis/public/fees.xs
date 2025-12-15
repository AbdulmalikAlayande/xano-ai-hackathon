// Retrieve fees with filtering, sorting, and pagination.
query fees verb=GET {
  api_group = "public"

  input {
    text category? filters=trim
    text state? filters=trim
    text search? filters=trim
    int page?=1 filters=min:1
    int per_page?=20 filters=min:1|max:100
  
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
  
    conditional {
      if ($input.category != null && $input.category != "") {
        db.query categories {
          where = $db.categories.slug == $input.category || $db.categories.name == $input.category
          return = {type: "exists"}
        } as $category_exists
      
        precondition ($category_exists) {
          error_type = "inputerror"
          error = "Category not found"
        }
      }
    }
  
    var $category_filter {
      value = ($input.category != "") ? $input.category : null
    }
  
    var $state_filter {
      value = ($input.state != "") ? $input.state : null
    }
  
    var $search_filter {
      value = ($input.search != "") ? $input.search : null
    }
  
    db.query fees {
      join = {
        subcategory: {
          table: "subcategories"
          where: $db.fees.subcategory_id == $db.subcategory.id
        }
        category   : {
          table: "categories"
          where: $db.subcategory.category_id == $db.category.id
        }
        source     : {
          table: "sources"
          where: $db.fees.source_id == $db.source.id
        }
        agency     : {
          table: "agencies"
          where: $db.source.agency_id == $db.agency.id
        }
      }
    
      where = ($search_filter == null || $db.fees.name includes? $search_filter || $db.fees.description includes? $search_filter) && ($category_filter == null || $db.category.slug ==? $category_filter || $db.category.name ==? $category_filter) && ($state_filter == null || $db.fees.meta.state ==? $state_filter)
      sort = {category.name: "asc", fees.name: "asc"}
      eval = {
        category_name   : $db.category.name
        agency_name     : $db.agency.name
        subcategory_name: $db.subcategory.name
        source_name     : $db.source.name
      }
    
      return = {
        type  : "list"
        paging: {
          page    : $input.page
          per_page: $input.per_page
          totals  : true
        }
      }
    } as $fees_result
  
    array.map ($fees_result.items) {
      by = $this
        |set:"created_at":($this.created_at|format_timestamp:"c")
        |set:"updated_at":($this.updated_at|format_timestamp:"c")
    } as $formatted_items
  
    var $response_object {
      value = {
        items: $formatted_items
        meta : {
          total: $fees_result.itemsTotal
          limit: $fees_result.perPage
          offset: $fees_result.offset
          page: $fees_result.curPage
        }
      }
    }
  }

  response = $response_object
}