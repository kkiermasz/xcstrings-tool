import Foundation

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
internal enum Multiline {
    /// This example tests the following:
    /// 1. That line breaks in the defaultValue are supported
    /// 2. That line breaks in the comment are supported
    internal static let multiline = resolve(
        LocalizedStringResource(
            "multiline",
            defaultValue: ###"Options:\###n- One\###n- Two\###n- Three"###,
            table: "Multiline",
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
private extension Multiline {
    static func resolve(_ resource: LocalizedStringResource) -> String { String(localized: resource)
    }
}
