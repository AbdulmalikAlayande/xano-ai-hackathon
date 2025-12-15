// Retrieve fees with filtering, sorting, and pagination.
query fees verb=GET {
  api_group = "public"

  input {
    text category? filters=trim
    text state? filters=trim
    text search? filters=trim
    int page?=1 filters=min:1
    int per_page?=20 filters=min:1|max:100
  }

  stack {
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