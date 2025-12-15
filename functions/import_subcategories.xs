// Import subcategories from CSV data, mapping categories by slug
function import_subcategories {
  input {
  }

  stack {
    // Load all categories for mapping
    db.query categories {
      return = {type: "list"}
    } as $categories
  
    // Map category slug to category id
    var $category_map {
      value = {}
    }
  
    foreach ($categories) {
      each as $cat {
        // Build slug to id mapping
        var.update $category_map {
          value = $category_map|set:$cat.slug:$cat.id
        }
      }
    }
  
    // Subcategory data with category slug mapping
    var $subcategories_data {
      value = [
        {name: "NIN", slug: "nin", description: "National Identification Number fees", category_slug: "identity"}
        {name: "Passport", slug: "passport", description: "Nigerian passport issuance and renewal", category_slug: "immigration"}
        {name: "Visa Fees", slug: "visa", description: "Country-specific visa charges (Appendix I)", category_slug: "immigration"}
        {name: "NECO SSCE Internal", slug: "neco-ssce-internal", description: "Senior school certificate exam (internal)", category_slug: "education"}
        {name: "NECO SSCE External", slug: "neco-ssce-external", description: "Senior school certificate exam (external)", category_slug: "education"}
        {name: "NECO BECE", slug: "neco-bece", description: "Junior exam fees", category_slug: "education"}
        {name: "NECO NCEE", slug: "neco-ncee", description: "Common entrance exam fees", category_slug: "education"}
        {name: "NECO NGE", slug: "neco-nge", description: "Gifted exam fees", category_slug: "education"}
        {name: "JAMB", slug: "jamb", description: "JAMB UTME, DE and service fees", category_slug: "education"}
        {name: "IKEDC Tariff", slug: "ikedc-tariff", description: "Ikeja Electric tariff structure", category_slug: "electricity"}
        {name: "EKEDC Tariff", slug: "ekedc-tariff", description: "Eko Electric tariff structure", category_slug: "electricity"}
      ]
    }
  
    // Array to store created subcategories
    var $created {
      value = []
    }
  
    foreach ($subcategories_data) {
      each as $subcat {
        // Resolve category id from slug
        var $category_id {
          value = $category_map|get:$subcat.category_slug:null
        }
      
        precondition ($category_id != null) {
          error = "Category not found for slug: " ~ $subcat.category_slug
        }
      
        // Upsert subcategory by slug
        db.add_or_edit subcategories {
          field_name = "slug"
          field_value = $subcat.slug
          data = {
            category_id: $category_id
            name       : $subcat.name
            slug       : $subcat.slug
            description: $subcat.description
          }
        } as $subcat_record
      
        array.push $created {
          value = $subcat_record
        }
      }
    }
  
    // Count imported subcategories
    var $count {
      value = 0
    }
  
    foreach ($created) {
      each as $item {
        math.add $count {
          value = 1
        }
      }
    }
  
    // Import result
    var $result {
      value = {imported: $count, subcategories: $created}
    }
  }

  response = $result
}