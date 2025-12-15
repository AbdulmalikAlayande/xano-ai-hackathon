// Master endpoint to seed the database with all import data in dependency order
query seed_database verb=POST {
  api_group = "import"

  input {
  }

  stack {
    // Step 1: Import agencies (no dependencies)
    function.run import_agencies as $agencies_result
  
    debug.log {
      value = "Step 1: Agencies imported"
    }
  
    // Step 2: Import categories (no dependencies)
    function.run import_categories as $categories_result
  
    debug.log {
      value = "Step 2: Categories imported"
    }
  
    // Step 3: Import sources (depends on agencies)
    function.run import_sources as $sources_result
  
    debug.log {
      value = "Step 3: Sources imported"
    }
  
    // Step 4: Import subcategories (depends on categories)
    function.run import_subcategories as $subcategories_result
  
    debug.log {
      value = "Step 4: Subcategories imported"
    }
  
    // Step 5: Import fees (depends on subcategories and sources)
    function.run import_fees as $fees_result
  
    debug.log {
      value = "Step 5: Fees imported"
    }
  
    var $summary {
      value = {
        status   : "success"
        message  : "Database seeding completed successfully"
        timestamp: now
        results  : {
          agencies: $agencies_result
          categories: $categories_result
          sources: $sources_result
          subcategories: $subcategories_result
          fees: $fees_result
        }
      }
    }
  }

  response = $summary
}