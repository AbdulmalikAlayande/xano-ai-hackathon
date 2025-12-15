// Import agencies from CSV data
function import_agencies {
  input {
  }

  stack {
    // Agency data from CSV
    var $agencies_data {
      value = [
        {name: "National Identity Management Commission", slug: "nimc", website: "https://nimc.gov.ng", notes: "Handles NIN issuance and modifications"}
        {name: "Nigeria Immigration Service", slug: "nis", website: "https://immigration.gov.ng", notes: "Handles passports and visas"}
        {name: "National Examinations Council", slug: "neco", website: "https://neco.gov.ng", notes: "Conducts SSCE, BECE, NCEE exams"}
        {name: "Joint Admissions and Matriculation Board", slug: "jamb", website: "https://jamb.gov.ng", notes: "Conducts UTME and DE admissions"}
        {name: "Nigerian Electricity Regulatory Commission", slug: "nerc", website: "https://nerc.gov.ng", notes: "Regulates electricity tariffs"}
        {name: "Federal Ministry of Power", slug: "power", website: "https://power.gov.ng", notes: "Supervises electricity sector"}
        {name: "EKEDC (Ikeja Electric)", slug: "ekedc", website: "https://ekedp.com/tariff-plans", notes: "Ikeja Electric utility provider"}
        {name: "University of Lagos", slug: "unilag", website: "https://unilag.edu.ng", notes: "Federal university handling admissions and postgraduate fees"}
      ]
    }
  
    // Array to store created agencies
    var $created {
      value = []
    }
  
    foreach ($agencies_data) {
      each as $agency {
        // Upsert agency by slug
        db.add_or_edit agencies {
          field_name = "slug"
          field_value = $agency.slug
          data = {
            name   : $agency.name
            slug   : $agency.slug
            website: $agency.website
            notes  : $agency.notes
          }
        } as $agency_record
      
        array.push $created {
          value = $agency_record
        }
      }
    }
  
    // Count imported agencies
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
      value = {imported: $count, agencies: $created}
    }
  }

  response = $result
}