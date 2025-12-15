// Import sources from CSV data, mapping agencies by name/slug
function import_sources {
  input {
  }

  stack {
    // Load all agencies for mapping
    db.query agencies {
      return = {type: "list"}
    } as $agencies
  
    // Map agency name/slug to agency id
    var $agency_map {
      value = {}
    }
  
    foreach ($agencies) {
      each as $agency {
        // Map by name
        var.update $agency_map {
          value = $agency_map|set:$agency.name:$agency.id
        }
      
        // Map by slug
        var.update $agency_map {
          value = $agency_map|set:$agency.slug:$agency.id
        }
      }
    }
  
    // Source data with agency name mapping
    var $sources_data {
      value = [
        {name: "NIMC", url: "https://nimc.gov.ng", document_ref: "SERVICE_LEVEL_AGREEMENT_2025_.pdf", notes: "Official NIMC SLA document containing NIN modification fees.", agency_key: "nimc"}
        {name: "Nigerian Immigration Service (NIS)", url: "https://immigration.gov.ng", document_ref: "SERVICE_LEVEL_AGREEMENT_2025_.pdf", notes: "Passport issuance/renewal fees sourced from NIS section of the SLA.", agency_key: "nis"}
        {name: "NECO", url: "https://neco.gov.ng/exams", document_ref: "neco_fees_list", notes: "SSCE Internal, SSCE External, BECE, NCEE, NGE, and Other Fees from NECO official website.", agency_key: "neco"}
        {name: "JAMB", url: "https://www.jamb.gov.ng/payment-Services", document_ref: "jamb_payment_services", notes: "All JAMB payment services and fees sourced from official JAMB portal.", agency_key: "jamb"}
        {name: "EKEDC (Ikeja Electric)", url: "https://ekedp.com/tariff-plans", document_ref: "ekedc_tariff_page", notes: "Official tariff plan page used for electricity tariff categorizations.", agency_key: "ekedc"}
        {name: "UNILAG", url: "https://acedhars.unilag.edu.ng/?page_id=154", document_ref: "unilag_accepance_page", notes: "Official UNILAG acceptance and postgraduate fee breakdown.", agency_key: "unilag"}
      ]
    }
  
    // Array to store created sources
    var $created {
      value = []
    }
  
    foreach ($sources_data) {
      each as $source {
        // Resolve agency id from key
        var $agency_id {
          value = $agency_map|get:$source.agency_key:null
        }
      
        precondition ($agency_id != null) {
          error = "Agency not found for key: " ~ $source.agency_key
        }
      
        // Upsert source by name
        db.add_or_edit sources {
          field_name = "name"
          field_value = $source.name
          data = {
            agency_id   : $agency_id
            name        : $source.name
            url         : $source.url
            document_ref: $source.document_ref
            notes       : $source.notes
          }
        } as $source_record
      
        array.push $created {
          value = $source_record
        }
      }
    }
  
    // Count imported sources
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
      value = {imported: $count, sources: $created}
    }
  }

  response = $result
}