const amplifyconfig = ''' {
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "Default": {
                    "endpointType": "GraphQL",
                    "endpoint": "https://2x7qjjxv2rgitern3w35t7ygsq.appsync-api.us-west-2.amazonaws.com/graphql",
                    "region": "us-west-2",
                    "authorizationType": "AMAZON_COGNITO_USER_POOLS"
                },
                "family-connect-api-development_AWS_IAM": {
                    "endpointType": "GraphQL",
                    "endpoint": "https://2x7qjjxv2rgitern3w35t7ygsq.appsync-api.us-west-2.amazonaws.com/graphql",
                    "region": "us-west-2",
                    "authorizationType": "AWS_IAM",
                   "apiKey": "da2-uebx3lqi5fekpgq3cz4zwc3ip4"
                },
                "family-connect-api-development_API_KEY": {
                    "endpointType": "GraphQL",
                    "endpoint": "https://2x7qjjxv2rgitern3w35t7mygsq.appsync-api.us-west-2.amazonaws.com/graphql",
                    "region": "us-west-2",
                    "authorizationType": "API_KEY",
                   "apiKey": "da2-uebx3lqi5fekpgq3cz4zwc3ip4"
                },
                "family-connect-api-development": {
                    "endpointType": "GraphQL",
                    "endpoint": "https://2x7qjjxv2rgitern3w35t7ygsq.appsync-api.us-west-2.amazonaws.com/graphql",
                    "region": "us-west-2",
                    "authorizationType": "AMAZON_COGNITO_USER_POOLS",
                    "apiKey": "da2-uebx3lqi5fekpgq3cz4zwc3ip4"
                }
            }
        }
    },
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "us-west-2:9e2de753-54b3-4b99-9ae0-d06af96fd5fe",
                            "Region": "us-west-2"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "us-west-2_nTbfSsqjJ",
                        "AppClientId": "5v68jdhknv13b2em2up9cj9ks1",
                        "Region": "us-west-2"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": [],
                        "signupAttributes": [],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": [],
                        "verificationMechanisms": []
                    }
                },
                "S3TransferUtility": {
                    "Default": {
                        "Bucket": "mobex-health-development-data-us-west-2",
                        "Region": "us-west-2"
                    }
                },
                "AppSync": {
                    "Default": {
                        "ApiUrl": "https://2x7qjjxv2rgitern3w35t7ygsq.appsync-api.us-west-2.amazonaws.com/graphql",
                        "Region": "us-west-2",
                        "AuthMode": "AMAZON_COGNITO_USER_POOLS",
                        "ClientDatabasePrefix": "family-connect-api-development_AMAZON_COGNITO_USER_POOLS"
                    },
                    "family-connect-api-development": {
                        "ApiUrl": "https://2x7qjjxv2rgitern3w35t7ygsq.appsync-api.us-west-2.amazonaws.com/graphql",
                        "Region": "us-west-2",
                        "AuthMode": "AMAZON_COGNITO_USER_POOLS",
                        "ClientDatabasePrefix": "family-connect-api-development_AMAZON_COGNITO_USER_POOLS"
                    },
                    "family-connect-api-development_AWS_IAM": {
                        "ApiUrl": "https://2x7qjjxv2rgitern3w35t7ygsq.appsync-api.us-west-2.amazonaws.com/graphql",
                        "Region": "us-west-2",
                        "AuthMode": "AWS_IAM",
                        "ClientDatabasePrefix": "family-connect-api-development_AWS_IAM"
                    },
                    "family-connect-api-development_API_KEY": {
                        "ApiUrl": "https://2x7qjjxv2rgitern3w35t7ygsq.appsync-api.us-west-2.amazonaws.com/graphql",
                        "Region": "us-west-2",
                        "AuthMode": "API_KEY",
                        "ApiKey": "da2-uebx3lqi5fekpgq3cz4zwc3ip4",
                        "ClientDatabasePrefix": "family-connect-api-development_API_KEY"
                    }
                }
            }
        }
    },
    "storage": {
        "plugins": {
            "awsS3StoragePlugin": {
                "bucket": "mobex-health-development-data-us-west-2",
                "region": "us-west-2",
                "defaultAccessLevel": "guest"
            }
        }
    }
}''';
