# APIM OpenAPI Integration Sample #

This provides sample Azure Functions apps that integrate with Azure API Management, and expose their respective Swagger UI pages through it.


## Getting Started ##

1. Click the button below to autopilot all instances and apps on Azure. Make sure that you don't forget the app name you give.

    [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdevkimchi%2FAPIM-OpenAPI-Sample%2Fmain%2FResources%2Fazuredeploy.json)

2. Visit the following URLs to check whether all the apps have been properly provisioned and deployed.

   * `https://apim-<APP_NAME>.azure-api.net/azip/swagger/ui`
   * ~~`https://apim-<APP_NAME>.azure-api.net/azoop/swagger/ui`~~


## Known Issues ##

1. Due to the fact that Azure CLI has an error to deploy .NET-based out-of-proc function app, the autopilot feature only takes care of the in-proc function app. However, manual deployment of both in-proc and out-of-proc function apps is fine.
