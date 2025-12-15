// Import fees from CSV data, mapping subcategories and sources by slug/name
function import_fees {
  input {
  }

  stack {
    // Load all subcategories for mapping
    db.query subcategories {
      return = {type: "list"}
    } as $subcategories
  
    // Load all sources for mapping
    db.query sources {
      return = {type: "list"}
    } as $sources
  
    // Map subcategory slug to id
    var $subcat_map {
      value = {}
    }
  
    foreach ($subcategories) {
      each as $subcat {
        // Build slug to id mapping
        var.update $subcat_map {
          value = $subcat_map|set:$subcat.slug:$subcat.id
        }
      }
    }
  
    // Map source name to id
    var $source_map {
      value = {}
    }
  
    foreach ($sources) {
      each as $source {
        // Build name to id mapping
        var.update $source_map {
          value = $source_map|set:$source.name:$source.id
        }
      }
    }
  
    // Map placeholder IDs to actual subcategory slugs
    var $subcat_id_map {
      value = {
        NIN_SUBCAT_ID       : "nin"
        SUB_ID_PASSPORT     : "passport"
        SUB_ID_JAMB         : "jamb"
        SUB_ID_NECO_SSCE_INT: "neco-ssce-internal"
        SUB_ID_NECO_SSCE_EXT: "neco-ssce-external"
        SUB_ID_NECO_BECE    : "neco-bece"
        SUB_ID_NECO_NCEE    : "neco-ncee"
        SUB_ID_NECO_NGE     : "neco-nge"
        SUB_ID_EKEDC        : "ekedc-tariff"
        SUB_ID_UNILAG       : "unilag"
      }
    }
  
    // Map placeholder IDs to actual source names
    var $source_id_map {
      value = {
        NIMC_SOURCE_ID: "NIMC"
        SRC_ID_NIS    : "Nigerian Immigration Service (NIS)"
        SRC_ID_NECO   : "NECO"
        SRC_ID_JAMB   : "JAMB"
        SRC_ID_EKEDC  : "EKEDC (Ikeja Electric)"
        SRC_ID_UNILAG : "UNILAG"
      }
    }
  
    // All fee data from CSV files
    var $all_fees {
      value = []
    }
  
    // NIN fees
    var $nin_fees {
      value = [
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "NIN Enrolment (First Time)", amount: 0, currency: "NGN", service_type: "Standard", payment_code: "", description: "Initial NIN enrollment is free", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Modification of Name", amount: 500, currency: "NGN", service_type: "Modification", payment_code: "", description: "Change of name on NIN", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Modification of Address", amount: 500, currency: "NGN", service_type: "Modification", payment_code: "", description: "Change of address on NIN", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Modification of Phone Number", amount: 500, currency: "NGN", service_type: "Modification", payment_code: "", description: "Change of phone number on NIN", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Modification of Email", amount: 500, currency: "NGN", service_type: "Modification", payment_code: "", description: "Change of email address", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Modification of Place of Birth", amount: 500, currency: "NGN", service_type: "Modification", payment_code: "", description: "Correction of place of birth", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Modification of Occupation", amount: 500, currency: "NGN", service_type: "Modification", payment_code: "", description: "Updating occupation field", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Modification of State of Origin", amount: 500, currency: "NGN", service_type: "Modification", payment_code: "", description: "Correction of state of origin", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Modification of LGA", amount: 500, currency: "NGN", service_type: "Modification", payment_code: "", description: "Correction of LGA", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Modification of Polling Unit", amount: 500, currency: "NGN", service_type: "Modification", payment_code: "", description: "Updating polling unit information", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Change of Date of Birth (One-Time)", amount: 15000, currency: "NGN", service_type: "Bio-data Correction", payment_code: "", description: "Change of DOB allowed once", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Change of Date of Birth (If Repeated)", amount: null, currency: "NGN", service_type: "Bio-data Correction", payment_code: "", description: "Not allowed more than once", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Replacement of NIN Slip (Standard Paper Print)", amount: 500, currency: "NGN", service_type: "Reprint", payment_code: "", description: "Reprinting the paper NIN slip", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Premium Slip (Polycarbonate/Plastic Card)", amount: 2500, currency: "NGN", service_type: "Reprint", payment_code: "", description: "Plastic card version of NIN slip", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Card Replacement After Loss", amount: 5000, currency: "NGN", service_type: "Replacement", payment_code: "", description: "Replacing lost/damaged NIN card", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Attestation Letter", amount: 5000, currency: "NGN", service_type: "Attestation", payment_code: "", description: "Official letter proving identity", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Non-Resident (Diaspora NIN Enrollment)", amount: 50, currency: "USD", service_type: "Diaspora", payment_code: "", description: "NIN enrollment outside Nigeria", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Diaspora NIN Modification", amount: 15, currency: "USD", service_type: "Modification", payment_code: "", description: "Change of data for diaspora applicants", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
        {subcategory_placeholder: "NIN_SUBCAT_ID", name: "Diaspora NIN Slip Reprint", amount: 5, currency: "USD", service_type: "Reprint", payment_code: "", description: "Reprinting diaspora slip", meta: "{}", source_placeholder: "NIMC_SOURCE_ID"}
      ]
    }
  
    array.merge $all_fees {
      value = $nin_fees
    }
  
    // Passport fees
    var $passport_fees {
      value = [
        {subcategory_placeholder: "SUB_ID_PASSPORT", name: "Standard Passport 32 Pages (5-Year Validity)", amount: 100000, currency: "NGN", service_type: "Standard", payment_code: "", description: "New or Renewal", meta: "{}", source_placeholder: "SRC_ID_NIS"}
        {subcategory_placeholder: "SUB_ID_PASSPORT", name: "Standard Passport 64 Pages (10-Year Validity)", amount: 200000, currency: "NGN", service_type: "Standard", payment_code: "", description: "New or Renewal", meta: "{}", source_placeholder: "SRC_ID_NIS"}
        {subcategory_placeholder: "SUB_ID_PASSPORT", name: "Diaspora Passport 32 Pages (5-Year)", amount: 150, currency: "USD", service_type: "Diaspora", payment_code: "", description: "Outside Nigeria", meta: "{}", source_placeholder: "SRC_ID_NIS"}
        {subcategory_placeholder: "SUB_ID_PASSPORT", name: "Diaspora Passport 64 Pages (10-Year)", amount: 230, currency: "USD", service_type: "Diaspora", payment_code: "", description: "Outside Nigeria", meta: "{}", source_placeholder: "SRC_ID_NIS"}
        {subcategory_placeholder: "SUB_ID_PASSPORT", name: "Correction of Data (Admin Charge)", amount: 30000, currency: "NGN", service_type: "Correction", payment_code: "", description: "Name/DoB/Data correction", meta: "{}", source_placeholder: "SRC_ID_NIS"}
        {subcategory_placeholder: "SUB_ID_PASSPORT", name: "ECOWAS Travel Certificate (Fresh)", amount: 2600, currency: "NGN", service_type: "ETC", payment_code: "", description: "24-hour processing", meta: "{}", source_placeholder: "SRC_ID_NIS"}
        {subcategory_placeholder: "SUB_ID_PASSPORT", name: "ECOWAS Travel Certificate (Renewal)", amount: 1300, currency: "NGN", service_type: "ETC", payment_code: "", description: "Renewal", meta: "{}", source_placeholder: "SRC_ID_NIS"}
        {subcategory_placeholder: "SUB_ID_PASSPORT", name: "Contactless Biometric Passport 32 Pages", amount: 130, currency: "USD", service_type: "Diaspora", payment_code: "", description: "Mobile app enrollment", meta: "{}", source_placeholder: "SRC_ID_NIS"}
        {subcategory_placeholder: "SUB_ID_PASSPORT", name: "Contactless Biometric Passport 64 Pages", amount: 230, currency: "USD", service_type: "Diaspora", payment_code: "", description: "Mobile app enrollment", meta: "{}", source_placeholder: "SRC_ID_NIS"}
        {subcategory_placeholder: "SUB_ID_PASSPORT", name: "Contactless Service Charge", amount: 100, currency: "USD", service_type: "Service", payment_code: "", description: "Additional fee", meta: "{}", source_placeholder: "SRC_ID_NIS"}
      ]
    }
  
    array.merge $all_fees {
      value = $passport_fees
    }
  
    // JAMB fees
    var $jamb_fees {
      value = [
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Condonement of Illegal Admission", amount: 10000, currency: "NGN", service_type: "JAMB", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Application for Transfer", amount: 7000, currency: "NGN", service_type: "JAMB", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Change of Admission Letter", amount: 5000, currency: "NGN", service_type: "JAMB", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Fresh Admission Letter", amount: 5000, currency: "NGN", service_type: "JAMB", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "UTME Registration", amount: 3500, currency: "NGN", service_type: "UTME", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "UTME De-Registration", amount: 3500, currency: "NGN", service_type: "UTME", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Open University Registration", amount: 3500, currency: "NGN", service_type: "OU", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Distance Learning Registration", amount: 3500, currency: "NGN", service_type: "DL", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Sandwich Registration", amount: 10000, currency: "NGN", service_type: "Sandwich", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Part-time Registration", amount: 10000, currency: "NGN", service_type: "Part-Time", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Data Correction - Institution/Course", amount: 2500, currency: "NGN", service_type: "Correction", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Data Correction - Name", amount: 2500, currency: "NGN", service_type: "Correction", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Data Correction - Date of Birth", amount: 2500, currency: "NGN", service_type: "Correction", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Data Correction - State/LGA", amount: 2500, currency: "NGN", service_type: "Correction", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Data Correction - Gender", amount: 2500, currency: "NGN", service_type: "Correction", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Data Correction - A Level Qualification", amount: 2500, currency: "NGN", service_type: "Correction", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "JAMB Result Slip", amount: 1000, currency: "NGN", service_type: "Slip", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "Retrieve Registration Number", amount: 1000, currency: "NGN", service_type: "Retrieval", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
        {subcategory_placeholder: "SUB_ID_JAMB", name: "JAMB Admission Letter", amount: 1000, currency: "NGN", service_type: "Admission", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_JAMB"}
      ]
    }
  
    array.merge $all_fees {
      value = $jamb_fees
    }
  
    // NECO fees
    var $neco_fees {
      value = [
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "SSCE Internal Registration Fee", amount: 30000, currency: "NGN", service_type: "Internal", payment_code: "8201", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Late Registration Fee", amount: 5000, currency: "NGN", service_type: "Internal", payment_code: "8410", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "4-Figure Table", amount: 500, currency: "NGN", service_type: "Internal", payment_code: "8404", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Non Validation", amount: 10000, currency: "NGN", service_type: "Internal", payment_code: "8436", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Result Checker Token", amount: 1000, currency: "NGN", service_type: "Internal", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Syllabus", amount: 2000, currency: "NGN", service_type: "Internal", payment_code: "8405", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Photo Album", amount: 2700, currency: "NGN", service_type: "Internal", payment_code: "8401", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Late CAS 3 Upload", amount: 40000, currency: "NGN", service_type: "Internal", payment_code: "8411", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Unviable Centre Fee", amount: 70000, currency: "NGN", service_type: "Internal", payment_code: "8407", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Remarking (Per Paper)", amount: 20000, currency: "NGN", service_type: "Internal", payment_code: "8412", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Fresh Accreditation (Public)", amount: 150000, currency: "NGN", service_type: "Internal", payment_code: "8423", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Re-Accreditation (Public)", amount: 120000, currency: "NGN", service_type: "Internal", payment_code: "8424", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Fresh Accreditation (Private)", amount: 150000, currency: "NGN", service_type: "Internal", payment_code: "8437", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Fresh Accreditation (Foreign)", amount: 600000, currency: "NGN", service_type: "Internal", payment_code: "8439", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Re-Accreditation (Foreign)", amount: 500000, currency: "NGN", service_type: "Internal", payment_code: "8440", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_INT", name: "Certificate Jacket", amount: 2500, currency: "NGN", service_type: "Internal", payment_code: "8448", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_EXT", name: "SSCE External Registration Fee", amount: 30000, currency: "NGN", service_type: "External", payment_code: "8202", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_EXT", name: "Late Registration Fee", amount: 5000, currency: "NGN", service_type: "External", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_EXT", name: "Walk-In Fee", amount: 43000, currency: "NGN", service_type: "External", payment_code: "8414", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_EXT", name: "4-Figure Table", amount: 500, currency: "NGN", service_type: "External", payment_code: "84041", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_EXT", name: "Result Checker Token", amount: 1000, currency: "NGN", service_type: "External", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_EXT", name: "Syllabus", amount: 2000, currency: "NGN", service_type: "External", payment_code: "84051", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_EXT", name: "Result Slip", amount: 1600, currency: "NGN", service_type: "External", payment_code: "8415", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_EXT", name: "Remarking (Per Paper)", amount: 20000, currency: "NGN", service_type: "External", payment_code: "84121", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_EXT", name: "Certificate Collection", amount: 500, currency: "NGN", service_type: "External", payment_code: "8403", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_EXT", name: "Non Validation", amount: 10000, currency: "NGN", service_type: "External", payment_code: "8441", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_SSCE_EXT", name: "Certificate Jacket", amount: 2500, currency: "NGN", service_type: "External", payment_code: "8448", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_BECE", name: "BECE Registration", amount: 13595, currency: "NGN", service_type: "BECE", payment_code: "8203", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_BECE", name: "BECE Late Registration", amount: 5000, currency: "NGN", service_type: "BECE", payment_code: "8416", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_BECE", name: "BECE Re-Sit", amount: 3750, currency: "NGN", service_type: "BECE", payment_code: "8417", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_BECE", name: "BECE Non Validation", amount: 10000, currency: "NGN", service_type: "BECE", payment_code: "84361", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_BECE", name: "BECE Result Checker", amount: 1000, currency: "NGN", service_type: "BECE", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_BECE", name: "Syllabus", amount: 2000, currency: "NGN", service_type: "BECE", payment_code: "8418", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_BECE", name: "BECE Remarking (Per Paper)", amount: 15000, currency: "NGN", service_type: "BECE", payment_code: "8419", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_NCEE", name: "NCEE Registration", amount: 5940, currency: "NGN", service_type: "NCEE", payment_code: "8204", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_NCEE", name: "NCEE Non Validation", amount: 4000, currency: "NGN", service_type: "NCEE", payment_code: "83043", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_NGE", name: "NGE Registration", amount: 5940, currency: "NGN", service_type: "NGE", payment_code: "83041", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
        {subcategory_placeholder: "SUB_ID_NECO_NGE", name: "NGE Non Validation", amount: 4000, currency: "NGN", service_type: "NGE", payment_code: "83042", description: "", meta: "{}", source_placeholder: "SRC_ID_NECO"}
      ]
    }
  
    array.merge $all_fees {
      value = $neco_fees
    }
  
    // Electricity fees
    var $electricity_fees {
      value = [
        {subcategory_placeholder: "SUB_ID_EKEDC", name: "Band A Tariff (per kWh)", amount: 225, currency: "NGN", service_type: "kWh", payment_code: "", description: "Current NERC approved", meta: "{}", source_placeholder: "SRC_ID_EKEDC"}
        {subcategory_placeholder: "SUB_ID_EKEDC", name: "Band B Tariff (per kWh)", amount: 128, currency: "NGN", service_type: "kWh", payment_code: "", description: "Standard tariff", meta: "{}", source_placeholder: "SRC_ID_EKEDC"}
        {subcategory_placeholder: "SUB_ID_EKEDC", name: "Band C Tariff (per kWh)", amount: 123, currency: "NGN", service_type: "kWh", payment_code: "", description: "Standard tariff", meta: "{}", source_placeholder: "SRC_ID_EKEDC"}
        {subcategory_placeholder: "SUB_ID_EKEDC", name: "Band D Tariff (per kWh)", amount: 80, currency: "NGN", service_type: "kWh", payment_code: "", description: "Standard tariff", meta: "{}", source_placeholder: "SRC_ID_EKEDC"}
        {subcategory_placeholder: "SUB_ID_EKEDC", name: "Band E Tariff (per kWh)", amount: 70, currency: "NGN", service_type: "kWh", payment_code: "", description: "Standard tariff", meta: "{}", source_placeholder: "SRC_ID_EKEDC"}
      ]
    }
  
    array.merge $all_fees {
      value = $electricity_fees
    }
  
    // University fees
    var $university_fees {
      value = [
        {subcategory_placeholder: "SUB_ID_UNILAG", name: "UNILAG Acceptance Fee", amount: 62500, currency: "NGN", service_type: "Acceptance", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_UNILAG"}
        {subcategory_placeholder: "SUB_ID_UNILAG", name: "UNILAG Application Fee", amount: 25000, currency: "NGN", service_type: "Application", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_UNILAG"}
        {subcategory_placeholder: "SUB_ID_UNILAG", name: "UNILAG Prospectus Fee", amount: 5000, currency: "NGN", service_type: "Prospectus", payment_code: "", description: "", meta: "{}", source_placeholder: "SRC_ID_UNILAG"}
      ]
    }
  
    array.merge $all_fees {
      value = $university_fees
    }
  
    // Array to store created fees
    var $created {
      value = []
    }
  
    foreach ($all_fees) {
      each as $fee {
        // Resolve subcategory slug from placeholder
        var $subcat_slug {
          value = $subcat_id_map
            |get:$fee.subcategory_placeholder:null
        }
      
        // Resolve subcategory id from slug
        var $subcategory_id {
          value = $subcat_map|get:$subcat_slug:null
        }
      
        // Resolve source name from placeholder
        var $source_name {
          value = $source_id_map|get:$fee.source_placeholder:null
        }
      
        // Resolve source id from name
        var $source_id {
          value = $source_map|get:$source_name:null
        }
      
        conditional {
          if ($subcategory_id != null && $source_id != null) {
            // Build fee data object
            var $fee_data {
              value = {
                subcategory_id: $subcategory_id
                source_id     : $source_id
                name          : $fee.name
                currency      : $fee.currency
                service_type  : $fee.service_type
                description   : $fee.description
              }
            }
          
            conditional {
              if ($fee.amount != null) {
                var.update $fee_data {
                  value = $fee_data|set:"amount":$fee.amount
                }
              }
            }
          
            conditional {
              if (($fee.payment_code|strlen) > 0) {
                var.update $fee_data {
                  value = $fee_data
                    |set:"payment_code":$fee.payment_code
                }
              }
            }
          
            conditional {
              if (($fee.meta|strlen) > 0) {
                // Parse JSON meta
                var $meta_parsed {
                  value = $fee.meta|json_decode
                }
              
                var.update $fee_data {
                  value = $fee_data|set:"meta":$meta_parsed
                }
              }
            }
          
            // Add fee record
            db.add fees {
              data = {
                subcategory_id: $subcategory_id
                source_id     : $source_id
                name          : $fee.name
                currency      : $fee.currency
                service_type  : $fee.service_type
                description   : $fee.description
                amount        : $fee.amount
                payment_code  : $fee.payment_code
                meta          : ((($fee.meta|strlen) > 0) ? ($fee.meta|json_decode) : null)
              }
            } as $fee_record
          
            array.push $created {
              value = $fee_record
            }
          }
        }
      }
    }
  
    // Count imported fees
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
      value = {imported: $count, fees: $created}
    }
  }

  response = $result
}