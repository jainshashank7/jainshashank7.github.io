import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../enitity/join_family_response.dart';
import '../enitity/user.dart';
import '../utils/helpers/amplify_helper.dart';
import 'amplify_service.dart';


class AuthRepository {
  final AmplifyAuthCognito _auth = AmplifyAuthCognito();

  final AmplifyService _amplifyAPI = AmplifyService();

  Future<JoinFamilyResponse> confirmInviteCode({String? inviteCode}) async {
    String graphQLDocument = '''mutation JoinFamily(\$inviteCode:ID!) {
             joinFamily(inviteCode:\$inviteCode){
                contactId
                createdAt
                createdBy
                expireAt
                familyId
                familyName
                givenName
                inviteCode
                status
                username
             }
        }''';

    GraphQLResponse resp = await _amplifyAPI.mutate(
      document: graphQLDocument,
      variables: {
        "inviteCode": inviteCode,
      },
      apiName: AmplifyApiName.iam,
    );

    if (resp.errors.isNotEmpty) {
      throw resp.errors.first;
    }
    return JoinFamilyResponse.fromJson(jsonDecode(resp.data)['joinFamily']);
  }

  Future<SignInResult?> signIn({
    required String username,
    required String password,
  }) async {
    SignInResult res = await Amplify.Auth.signIn(
      username: username, password: password
    );

    return res;
  }

  Future<User> currentUser() async {
    List<AuthUserAttribute> attributes = await Amplify.Auth.fetchUserAttributes(
      // request: FetchUserAttributesRequest(),
    );
    Map<String, dynamic> json = {};
    for (var att in attributes) {
      json.addAll({att.userAttributeKey.key: att.value});
    }

    return User.fromCurrentAuthUserJson(json);
  }

  Future<String?> generateAccessToken() async {
    AuthSession session = await Amplify.Auth.fetchAuthSession(
      // request: AuthSessionRequest(
      //     options: CognitoSessionOptions(getAWSCredentials: true)),
    );
    CognitoAuthSession cognitoSession = session as CognitoAuthSession;
    return cognitoSession.userPoolTokens?.accessToken.raw;
  }

  Future<bool> isSignedIn() async {
    AuthSession session = await Amplify.Auth.fetchAuthSession(
      // request: AuthSessionRequest(
      //     options: CognitoSessionOptions(getAWSCredentials: true)),
    );
    return session.isSignedIn;
  }

  Future<dynamic> signeOut() async {
    return await Amplify.Auth.signOut(
        // request: SignOutRequest()
    );
  }
}
