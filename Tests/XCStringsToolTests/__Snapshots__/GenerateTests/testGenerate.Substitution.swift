import Foundation

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
internal enum Substitution {
    /// A string that uses substitutions as well as arguments
    internal static func substitutions_exampleString(_ arg1: String, totalStrings arg2: Int, remainingStrings arg3: Int) -> String {
        resolve(
            LocalizedStringResource(
                "substitutions_example.string",
                defaultValue: ###"\###(arg1)! There are \###(arg2) strings and you have \###(arg3) remaining"###,
                table: "Substitution",
                locale: .current,
                bundle: .current
            )
            )
    }
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension LocalizedStringResource.BundleDescription {
    #if !SWIFT_PACKAGE
    private class BundleLocator {
    }
    #endif

    fileprivate static let current: Self = {
        #if SWIFT_PACKAGE
        .atURL(Bundle.module.bundleURL)
        #else
        .forClass(BundleLocator.self)
        #endif
    }()
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
private extension Substitution {
    static func resolve(_ resource: LocalizedStringResource) -> String { String(localized: resource)
    }
}
