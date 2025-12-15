table sources {
  auth = false

  schema {
    // Primary key for the source
    int id
  
    // Agency that provides this source
    int agency_id {
      table = "agencies"
    }
  
    // Name of the source document or reference
    text name filters=trim
  
    // URL pointing to the source
    text url? filters=trim
  
    // Reference identifier for the source
    text document_ref? filters=trim
  
    // Additional notes about the source
    text notes?
  
    // Time the record was created
    timestamp created_at?=now
  
    // Time the record was last updated
    timestamp updated_at?=now
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "agency_id", op: "asc"}]}
    {type: "btree", field: [{name: "name", op: "asc"}]}
  ]
}