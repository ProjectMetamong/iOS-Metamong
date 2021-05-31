//
// Copyright 2010-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
// http://aws.amazon.com/apache2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import <UIKit/UIKit.h>

/*!
 Project version number for the AWSCore framework.

 @warning This value is deprecated and will be removed in an upcoming minor
 version of the SDK. It conflicts with the umbrella header generated by
 CocoaPods, and is not implemented at all in cases where this SDK is imported
 as a CocoaPod static library. As this numeric value does not support
 patch-level versioning, you should use AWSiOSSDKVersion instead.
 @deprecated Use AWSiOSSDKVersion instead.
 */
FOUNDATION_EXPORT double AWSCoreVersionNumber DEPRECATED_MSG_ATTRIBUTE("Use AWSiOSSDKVersion instead.");

/*!
 Project version string for the AWSCore framework.

 @warning This value is deprecated and will be removed in an upcoming minor
 version of the SDK. It conflicts with the umbrella header generated by
 CocoaPods, and is not implemented at all in cases where this SDK is imported
 as a CocoaPod static library.
 @deprecated Use AWSiOSSDKVersion instead.
 */
FOUNDATION_EXPORT const unsigned char AWSCoreVersionString[] DEPRECATED_MSG_ATTRIBUTE("Use AWSiOSSDKVersion instead.");

#import "AWSCocoaLumberjack.h"

#import "AWSServiceEnum.h"
#import "AWSService.h"
#import "AWSCredentialsProvider.h"
#import "AWSIdentityProvider.h"
#import "AWSModel.h"
#import "AWSNetworking.h"
#import "AWSNetworkingHelpers.h"
#import "AWSCategory.h"
#import "AWSLogging.h"
#import "AWSClientContext.h"
#import "AWSSynchronizedMutableDictionary.h"
#import "AWSXMLDictionary.h"
#import "AWSSerialization.h"
#import "AWSTimestampSerialization.h"
#import "AWSURLRequestSerialization.h"
#import "AWSURLResponseSerialization.h"
#import "AWSURLSessionManager.h"
#import "AWSSignature.h"
#import "AWSURLRequestRetryHandler.h"
#import "AWSValidation.h"
#import "AWSInfo.h"
#import "AWSNSCodingUtilities.h"

#import "AWSBolts.h"
#import "AWSGZIP.h"
#import "AWSFMDB.h"
#import "AWSKSReachability.h"
#import "AWSTMCache.h"
#import "AWSUICKeyChainStore.h"

#import "AWSSTS.h"
#import "AWSCognitoIdentity.h"
