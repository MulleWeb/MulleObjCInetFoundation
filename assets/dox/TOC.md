# MulleObjCInetFoundation Library Documentation for AI

## 1. Introduction & Purpose

**MulleObjCInetFoundation** provides Internet and networking utilities for Objective-C, including URL encoding/decoding, hostname resolution support, and network address manipulation. It extends Foundation classes (NSURL, NSString, NSHost) with practical networking functionality commonly needed in web and network applications.

This library is particularly useful for:
- URL parameter encoding and decoding
- Percent-encoding for URLs and email addresses
- Host name and IP address handling
- Building and parsing network addresses
- Cross-platform URL utilities
- Internet protocol address manipulation

## 2. Key Concepts & Design Philosophy

- **URL Standard Compliance**: RFC 3986 percent-encoding for URLs
- **Character Set Management**: NSCharacterSet for flexible encoding rules
- **Network Abstraction**: Unified interface for DNS and address handling
- **Lazy Resolution**: Optional resolver library support for DNS lookups
- **String Escaping**: Bidirectional encoding/decoding for URL safety
- **Thread-Safe**: Proper locking for concurrent access to shared resources

## 3. Core API & Data Structures

### NSString Category: `NSString (MulleURL)`

#### Percent Encoding

- `- (NSString *) stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)encoding` → `NSString *`
  - Percent-encode string for safe URL inclusion
  - **encoding**: Character encoding to use (typically NSUTF8StringEncoding)
  - Converts reserved and unsafe characters to %XX format
  - Returns autoreleased NSString
  - **Example**: `"hello world"` → `"hello%20world"`
  - **Use case**: Encoding query parameters, form data, path components

- `- (NSString *) stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)encoding` → `NSString *`
  - Decode percent-encoded string back to original
  - Reverses `stringByAddingPercentEscapesUsingEncoding:`
  - Returns autoreleased NSString
  - Returns nil on malformed percent sequences
  - **Example**: `"hello%20world"` → `"hello world"`
  - **Use case**: Processing URL parameters, form submissions

### NSCharacterSet Category: `NSCharacterSet (MulleURL)`

#### URL Character Set Queries

- `+ (NSCharacterSet *) mulleURLAllowedCharacterSet` → `NSCharacterSet *`
  - Returns characters allowed in URLs (unreserved + reserved)
  - Per RFC 3986

- `+ (NSCharacterSet *) mulleURLUnreservedCharacterSet` → `NSCharacterSet *`
  - Unreserved characters: A-Z, a-z, 0-9, `-`, `.`, `_`, `~`
  - Safe for any position in URL

- `+ (NSCharacterSet *) mulleURLReservedCharacterSet` → `NSCharacterSet *`
  - Reserved characters: `:`, `/`, `?`, `#`, `[`, `]`, `@`, `!`, `$`, `&`, `'`, `(`, `)`, `*`, `+`, `,`, `;`, `=`
  - Meaning varies by URL context

- `+ (NSCharacterSet *) mulleURLQueryCharacterSet` → `NSCharacterSet *`
  - Safe characters in query string context
  - Excludes `&` and `=` to preserve query structure

- `+ (NSCharacterSet *) mulleURLPathComponentCharacterSet` → `NSCharacterSet *`
  - Safe characters in path component
  - Excludes `/` to preserve path structure

- `+ (NSCharacterSet *) mulleURLSchemeCharacterSet` → `NSCharacterSet *`
  - Valid characters for URL scheme
  - Alphanumeric plus `+`, `-`, `.`

#### Custom Encoding Character Sets

- `+ (NSCharacterSet *) mulleURLCharacterSetExcludingCharacterSet:(NSCharacterSet *)excluded` → `NSCharacterSet *`
  - Create allowed character set excluding specific characters
  - **excluded**: Characters to remove from allowed set
  - **Use case**: Custom encoding for specific contexts

### NSHost Class: `NSHost`

#### Properties

- `@property (nonatomic, readonly, copy) NSArray *names`
  - Primary and alternate host names
  - First entry is canonical name

- `@property (nonatomic, readonly, copy) NSArray *addresses`
  - IP addresses (v4 and/or v6) associated with host
  - Format: dotted decimal for IPv4, colon-hex for IPv6

- `@property (nonatomic, readonly) BOOL _IP6`
  - YES if any address is IPv6

- `@property (nonatomic, readonly) BOOL _isCurrentHost`
  - YES if this is the local host

#### Creation

- `- (id) initWithNames:(NSString **)names count:(NSUInteger)count addresses:(NSString **)addresses count:(NSUInteger)nAddresses`
  - Create host with names and addresses
  - **names**: Array of host names
  - **addresses**: Array of address strings
  - For advanced custom host objects

- `+ (instancetype) hostWithName:(NSString *)name` → `NSHost *`
  - Create host by name
  - Attempts DNS lookup if resolver available
  - Returns autoreleased NSHost
  - May return partially initialized host if resolver unavailable

- `+ (instancetype) hostWithAddress:(NSString *)address` → `NSHost *`
  - Create host by IP address
  - Reverse DNS lookup if resolver available
  - Returns autoreleased NSHost

#### Current Host (Future API)

- `+ (instancetype) currentHost` → `NSHost *`
  - Get the local host object

- `- (NSString *) localizedName` → `NSString *`
  - Get display name for this host

#### Comparison

- `- (BOOL) isEqualToHost:(NSHost *)other`
  - Compare two host objects for equality

#### Accessors

- `- (NSString *) name` → `NSString *`
  - Primary host name (first in names array)

- `- (NSString *) address` → `NSString *`
  - Primary address (first in addresses array)

## 4. Performance Characteristics

- **Percent Encoding**: O(n) where n = string length; typical: 1-10 MB/s
- **DNS Lookup**: O(1) + network time; blocking operation, typically 10-1000ms
- **Character Set Queries**: O(1) constant time (cached)
- **Host Comparison**: O(n) where n = number of names/addresses
- **Memory**: Minimal, character sets are shared/cached
- **Concurrency**: Thread-safe for reads; DNS operations may be blocking

## 5. AI Usage Recommendations & Patterns

### Pattern 1: Encode Query Parameters
Build safe query strings:

```objc
NSString *userName = @"john@example.com";
NSString *encoded = [userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
NSString *queryURL = [NSString stringWithFormat:@"http://api.example.com?user=%@", encoded];
// Result: "http://api.example.com?user=john%40example.com"
```

### Pattern 2: Decode URL Parameters
Process received URLs:

```objc
NSString *encodedParam = @"hello%20world%21";
NSString *decoded = [encodedParam stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
// Result: "hello world!"
```

### Pattern 3: DNS Resolution
Lookup hostname:

```objc
NSHost *host = [NSHost hostWithName:@"example.com"];
if (host) {
    NSLog(@"Addresses: %@", [host addresses]);
    NSLog(@"Primary: %@", [host address]);
}
```

### Pattern 4: Reverse DNS Lookup
Get hostname from IP:

```objc
NSHost *host = [NSHost hostWithAddress:@"192.0.2.1"];
if (host) {
    NSLog(@"Names: %@", [host names]);
    NSLog(@"Primary: %@", [host name]);
}
```

### Pattern 5: Query String Building
Safe parameter concatenation:

```objc
NSString *search = @"mulle objc & c";
NSString *safe = [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
NSString *url = [NSString stringWithFormat:@"http://api.example.com/search?q=%@", safe];
```

### Common Pitfalls
- **Encoding twice**: Only encode once; double-encoding creates invalid URLs
- **Wrong encoding**: Always use NSUTF8StringEncoding for web content
- **Assuming & is safe**: `&` separates parameters; must be encoded in values
- **DNS blocking**: NSHost DNS lookups block thread; cache results
- **Missing resolver**: DNS features work only if optional resolver library linked

## 6. Integration Examples

### Example 1: Safe URL Building
```objc
- (NSURL *) buildSearchURL:(NSString *)query limit:(NSUInteger)limit {
    NSString *encodedQuery = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:
        @"http://api.example.com/search?q=%@&limit=%lu",
        encodedQuery, limit];
    return [NSURL URLWithString:urlString];
}
```

### Example 2: Parse Form Data
```objc
- (NSDictionary *) parseFormData:(NSString *)formData {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (NSString *pair in [formData componentsSeparatedByString:@"&"]) {
        NSArray *parts = [pair componentsSeparatedByString:@"="];
        if ([parts count] == 2) {
            NSString *key = [parts[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *value = [parts[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (key) result[key] = value ?: @"";
        }
    }
    
    return result;
}
```

### Example 3: Email Encoding in URL
```objc
NSString *email = @"user+tag@example.com";
NSString *subject = @"Test & Demo";

NSString *encodedEmail = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
NSString *encodedSubject = [subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

NSString *mailtoURL = [NSString stringWithFormat:@"mailto:%@?subject=%@",
    encodedEmail, encodedSubject];
```

### Example 4: Host Information Display
```objc
@interface HostInfo : NSObject
+ (NSString *) describeHost:(NSString *)hostname;
@end

@implementation HostInfo
+ (NSString *) describeHost:(NSString *)hostname {
    NSHost *host = [NSHost hostWithName:hostname];
    if (!host) return [NSString stringWithFormat:@"Host not found: %@", hostname];
    
    NSString *names = [[host names] componentsJoinedByString:@", "];
    NSString *addrs = [[host addresses] componentsJoinedByString:@", "];
    
    return [NSString stringWithFormat:
        @"Host: %@\nNames: %@\nAddresses: %@",
        hostname, names, addrs];
}
@end
```

### Example 5: Query Parameter Encoding
```objc
- (NSString *) buildQueryString:(NSDictionary *)params {
    NSMutableArray *pairs = [NSMutableArray array];
    
    for (NSString *key in params) {
        NSString *value = [params[key] description];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedValue = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
    }
    
    return [pairs componentsJoinedByString:@"&"];
}
```

### Example 6: URL Path Encoding
```objc
- (NSURL *) buildFileURL:(NSString *)filename directory:(NSString *)dir {
    // Encode each component separately to preserve /
    NSString *encodedDir = [dir stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedFile = [filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"http://files.example.com/%@/%@",
        encodedDir, encodedFile];
    
    return [NSURL URLWithString:urlString];
}
```

## 7. Dependencies

- **MulleFoundation** - NSString, NSArray, NSCharacterSet, NSHost base classes
- **Optional**: Resolver library for DNS functionality (libc-ares or similar)
- **mulle-objc** (runtime) - Objective-C runtime
- Standard C library

## 8. Standards & References

- **RFC 3986**: Uniform Resource Identifier (URI) syntax
- **RFC 1738**: Uniform Resource Locators (URLs)
- **RFC 2396**: URI Generic Syntax
- **WHATWG URL Standard**: Living URL specification

## 9. Version Information

MulleObjCInetFoundation version macro: `MULLE_OBJC_INET_FOUNDATION_VERSION`
- Format: `(major << 20) | (minor << 8) | patch`
- Current: 0.18.8
