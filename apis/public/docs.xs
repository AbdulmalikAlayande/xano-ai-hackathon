// GET /docs - Returns documentation links
// Returns links to all API documentation including GitHub repository, main docs, quick start, data sources, and code examples.
query docs verb=GET {
  api_group = "public"

  input {
  }

  stack {
    // GitHub repository base URL
    var $github_base {
      value = "https://github.com/AbdulmalikAlayande/xano-ai-hackathon"
    }
  
    // Build documentation links
    var $documentation {
      value = {
        repository        : $github_base
        main_documentation: {
          api_reference: $github_base ~ "/blob/main/API_DOCUMENTATION.md"
          quick_start: $github_base ~ "/blob/main/QUICK_START.md"
          data_sources: $github_base ~ "/blob/main/DATA_SOURCES.md"
          readme: $github_base ~ "/blob/main/README.md"
        }
        code_examples     : {
          javascript: $github_base ~ "/blob/main/examples/javascript-example.js"
          python: $github_base ~ "/blob/main/examples/python-example.py"
          curl: $github_base ~ "/blob/main/examples/curl-examples.sh"
        }
        raw_links         : {
          api_reference: $github_base ~ "/raw/main/API_DOCUMENTATION.md"
          quick_start: $github_base ~ "/raw/main/QUICK_START.md"
          data_sources: $github_base ~ "/raw/main/DATA_SOURCES.md"
          readme: $github_base ~ "/raw/main/README.md"
          javascript: $github_base ~ "/raw/main/examples/javascript-example.js"
          python: $github_base ~ "/raw/main/examples/python-example.py"
          curl: $github_base ~ "/raw/main/examples/curl-examples.sh"
        }
        note              : "Update the repository URL in the endpoint code to point to your actual GitHub repository"
      }
    }
  }

  response = $documentation
}