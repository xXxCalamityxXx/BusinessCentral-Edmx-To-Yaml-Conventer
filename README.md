# BusinessCentral-Edmx-To-Yaml-Conventer

### How to Use the Script

This script fetches the EDMX and OpenAPI specification for your Business Central API.

1.  **Execute the Script:** Open PowerShell and run the `RUN.ps1` script.
    ```bash
    ./RUN.ps1
    ```
2.  **Provide Details:** The script will prompt you for the following information. Enter each value and press Enter:
    *   `BaseUrl`: The base URL of your Business Central API (e.g., `https://api.businesscentral.dynamics.com/v2.0/YOURTENANTID/Sandbox/api/v2.0`)
    *   `TenantId`: Your Azure AD Tenant ID
    *   `ClientId`: Your Azure AD Application Client ID
    *   `ClientSecret`: Your Azure AD Application Client Secret
3.  **Retrieve Files:** The script will save the EDMX file as `edmx.xml` and the OpenAPI specification as `openapi.yaml` in the same directory.

More flexible C# executable with parameters is comming later.
Oh, and i don't know how reliable this code is, use it on own risk.
