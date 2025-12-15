table fees {
  auth = false

  schema {
    // Primary key for the fee
    int id
  
    // Subcategory this fee belongs to
    int subcategory_id {
      table = "subcategories"
    }
  
    // Source document this fee is derived from
    int source_id {
      table = "sources"
    }
  
    // Name of the fee or service
    text name filters=trim
  
    // Fee amount (can be null for N/A cases)
    decimal amount?
  
    // Currency code (NGN, USD, etc.)
    text currency? filters=trim|upper
  
    // Type of service (Standard, Modification, etc.)
    text service_type? filters=trim
  
    // Payment code or reference number
    text payment_code? filters=trim
  
    // Detailed description of the fee
    text description?
  
    // Additional metadata stored as JSON
    json meta?
  
    // Time the record was created
    timestamp created_at?=now
  
    // Time the record was last updated
    timestamp updated_at?=now
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "subcategory_id", op: "asc"}]}
    {type: "btree", field: [{name: "source_id", op: "asc"}]}
    {type: "btree", field: [{name: "name", op: "asc"}]}
  ]
}