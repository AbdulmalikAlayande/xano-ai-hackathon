table api_keys {
  auth = false

  schema {
    // Primary key for the API key record
    int id
  
    // API key string (format: nga_ + 32 random characters)
    // Unique API key for authentication
    text key filters=trim
  
    // Email of the user who owns this API key
    // Email address of the API key owner
    text user_email? filters=trim
  
    // Time the API key was created
    // Timestamp when the API key was created
    timestamp created_at?=now
  
    // Whether the API key is currently active
    // Whether the API key is active and can be used
    bool is_active?=true
  
    // Number of requests made with this API key
    // Total number of requests made using this API key
    int request_count?
  
    // Timestamp of the last request made with this API key
    // Timestamp of the most recent request using this API key
    timestamp last_request_at?
  
    // Timestamp when the request count was last reset
    // Timestamp when the request count was last reset
    timestamp last_reset_at?=now
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree|unique", field: [{name: "key", op: "asc"}]}
    {type: "btree", field: [{name: "user_email", op: "asc"}]}
    {type: "btree", field: [{name: "is_active", op: "asc"}]}
  ]
}