import Foundation

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
internal enum Positional {
    /// A string where the second argument is at the front of the string and the first argument is at the end
    internal static func reorder(_ arg1: Int, _ arg2: String) -> String {
        resolve(
            LocalizedStringResource(
                "reorder",
                defaultValue: ###"Second: \###(arg2) - First: \###(arg1)"###,
                table: "Positional",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// A string that uses the same argument twice
    internal static func repeatExplicit(_ arg1: Int) -> String {
        resolve(
            LocalizedStringResource(
                "repeatExplicit",
                defaultValue: ###"\###(arg1), I repeat: \###(arg1)"###,
                table: "Positional",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// A string that uses the same argument twice implicitly because a positional specifier wasn't provided in one instance
    internal static func repeatImplicit(_ arg1: String) -> String {
        resolve(
            LocalizedStringResource(
                "repeatImplicit",
                defaultValue: ###"\###(arg1), are you there? \###(arg1)?"###,
                table: "Positional",
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
private extension Positional {
    static func resolve(_ resource: LocalizedStringResource) -> String { String(localized: resource)
    }
}
