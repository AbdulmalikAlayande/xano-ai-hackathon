table subcategories {
  auth = false

  schema {
    // Primary key for the subcategory
    int id
  
    // Parent category this subcategory belongs to
    int category_id {
      table = "categories"
    }
  
    // Display name of the subcategory
    text name filters=trim
  
    // URL-friendly identifier for the subcategory
    text slug filters=trim|lower
  
    // Long-form description of the subcategory
    text description?
  
    // Time the record was created
    timestamp created_at?=now
  
    // Time the record was last updated
    timestamp updated_at?=now
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "category_id", op: "asc"}]}
    {type: "btree|unique", field: [{name: "slug", op: "asc"}]}
    {type: "btree", field: [{name: "name", op: "asc"}]}
  ]
}