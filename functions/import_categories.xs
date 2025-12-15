// Import categories from CSV data
function import_categories {
  input {
  }

  stack {
    // Category data from CSV
    var $categories_data {
      value = [
        {name: "Identity & Management", slug: "identity", description: "Fees related to national identity systems such as NIN"}
        {name: "Immigration", slug: "immigration", description: "Passport and visa related fees"}
        {name: "Education", slug: "education", description: "NECO, JAMB and related examination fees"}
        {name: "Electricity & Utilities", slug: "electricity", description: "Nigerian electricity tariffs and energy charges"}
        {name: "Business & Legal", slug: "business", description: "Corporate and government service fees"}
        {name: "Transport & Vehicle Services", slug: "transport", description: "Driver licensing and related fees"}
      ]
    }
  
    // Array to store created categories
    var $created {
      value = []
    }
  
    foreach ($categories_data) {
      each as $cat {
        // Upsert category by slug
        db.add_or_edit categories {
          field_name = "slug"
          field_value = $cat.slug
          data = {
            name       : $cat.name
            slug       : $cat.slug
            description: $cat.description
          }
        } as $category
      
        array.push $created {
          value = $category
        }
      }
    }
  
    // Count imported categories
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
      value = {imported: $count, categories: $created}
    }
  }

  response = $result
}