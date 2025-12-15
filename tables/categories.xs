table categories {
  auth = false

  schema {
    // Primary key for the category
    int id
  
    // Display name of the category
    text name filters=trim
  
    // URL-friendly identifier for the category
    text slug filters=trim|lower
  
    // Long-form description of the category
    text description?
  
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