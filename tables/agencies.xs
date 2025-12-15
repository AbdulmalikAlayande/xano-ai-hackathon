table agencies {
  auth = false

  schema {
    // Primary key for the agency
    int id
  
    // Name of the issuing or regulating agency
    text name filters=trim
  
    // URL-friendly identifier for the agency
    text slug filters=trim|lower
  
    // Primary website for the agency
    text website? filters=trim
  
    // Internal notes about the agency
    text notes?
  
    // Time the record was created
    timestamp created_at?=now
  
    // Time the record was last updated
    timestamp updated_at?=now
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree|unique", field: [{name: "slug", op: "asc"}]}
    {type: "btree|unique", field: [{name: "name", op: "asc"}]}
  ]
}