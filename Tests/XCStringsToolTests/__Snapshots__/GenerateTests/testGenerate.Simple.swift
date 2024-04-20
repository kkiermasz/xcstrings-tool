import Foundation

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
internal enum Simple {
    /// This is a simple key and value
    internal static let simpleKey = resolve(
        LocalizedStringResource(
            "SimpleKey",
            defaultValue: ###"My Value"###,
            table: "Simple",
            locale: .current,
            bundle: .current
        )
        )
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
private extension Simple {
    static func resolve(_ resource: LocalizedStringResource) -> String { String(localized: resource)
    }
}
