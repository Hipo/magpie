# Magpie

[![CI Status](https://img.shields.io/travis/eraydiler/Magpie.svg?style=flat)](https://travis-ci.org/eraydiler/Magpie)
[![Version](https://img.shields.io/cocoapods/v/Magpie.svg?style=flat)](https://cocoapods.org/pods/Magpie)
[![License](https://img.shields.io/cocoapods/l/Magpie.svg?style=flat)](https://cocoapods.org/pods/Magpie)
[![Platform](https://img.shields.io/cocoapods/p/Magpie.svg?style=flat)](https://cocoapods.org/pods/Magpie)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Magpie is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Magpie'
```

## Features
- [x] Support for cancellation for a specific request
- [x] Network reachability
- [x] Model conversion in a background thread

## Usage
### Creating NetworkClient instance
```swift
let client = HipNetworkClient()
```

### Making a Request
The library expects a `Request` object which provides required parameters for any type of request. Below are the examples for possible request scenarios.

#### Request without any parameters
```swift
let request = Request(url: url, method: Request.HTTPMethod.get)

client.send(request)
```

#### Request with query parameters
```swift
let parameters: [String: String] = [
    ...
]

let request = Request(
    url: url,
    method: Request.HTTPMethod.post,
    queryParameters: parameters
)

client.send(request)
```

### Request with body parameters
```swift
let parameters: [String: String] = [
    ...
]

let request = Request(
    url: url,
    method: Request.HTTPMethod.post,
    bodyParameters: parameters
)

client.send(request)
```

### Request with custom headers
```swift
let headers: [String: String] = [
    "Authorization": "...",
    "Accept": "application/json"
]

let request = Request(
    headers: headers,
    url: url,
    method: Request.HTTPMethod.get
)

client.send(request)
```


### Handling the response
Two closures are provided by default by the library for both success and fail situations.

```swift
client.send(request,
    onSuccess: { response in

    },
    onFail: { error in

    }
)

```

### HTTP Methods
Httpmethods suported by the library are in the enum below.

```swift
public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}
```

### Parameter encoding
The library supports all the paramter encoding types that `Alamofire` supports. These are URL, JSON, PropertyList, custom encodings can be implemented by conforming the protocol `ParameterEncoding`.

- `.methodDependent` - Sets the query string for `GET`, `HEAD` and `DELETE` requests. Otherwise sets the HTTP body for requests with any other HTTP method.
- `.queryString` - Sets the query string.
- `.httpBody` - Sets the HTTP body of the URL request.

Below are some examples.

#### GET Request with URL-Encoded Parameters
```swift
let parameters: Parameters = ["foo": "bar"]

let request = Request(
    headers: headers,
    url: url,
    method: Request.HTTPMethod.get,
    encoding: URLEncoding.methodDependent
)

client.send(request)

// https://example.com/get?foo=bar
```

Note that `URLEncoding.default` is equivalent for `URLEncoding.methodDependent` for `GET` requests. 

#### POST Request with URL-Encoded Parameters

```swift
let encoding: URLEncoding = URLEncoding.default or URLEncoding.methodDependent
let parameters: Parameters = [
    "foo": "bar",
    "baz": ["a", 1],
    "qux": [
        "x": 1,
        "y": 2,
        "z": 3
    ]
]

let request = Request(
    headers: headers,
    url: url,
    method: Request.HTTPMethod.post,
    encoding: URLEncoding.httpBody
)

client.send(request)

// HTTP body: foo=bar&baz[]=a&baz[]=1&qux[x]=1&qux[y]=2&qux[z]=3
```

Note that `URLEncoding.default` is equivalent for `URLEncoding.httpBody` for `POST` requests. 

#### Post Request with JSON-Encoded parameters

```swift
let parameters: Parameters = [
    "foo": [1, 2, 3],
    "bar": [
        "baz": "qux"
    ]
]

let request = Request(
    headers: headers,
    url: url,
    method: Request.HTTPMethod.post,
    encoding: JSONEncoding(options: []) // equivalent to JSONEncoding.default
)

// HTTP body: {"foo": [1, 2, 3], "bar": {"baz": "qux"}}
```

Note that the `Content-Type` HTTP header field of an encoded request is set to `application/json`.

## Author

Hipo team

## License

Magpie is available under the MIT license. See the LICENSE file for more info.
