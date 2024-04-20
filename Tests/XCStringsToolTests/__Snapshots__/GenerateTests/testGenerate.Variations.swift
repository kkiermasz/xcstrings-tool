import Foundation

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
internal enum Variations {
    /// A string that should have a macOS variation to replace 'Tap' with 'Click'
    internal static let stringDevice = resolve(
        LocalizedStringResource(
            "String.Device",
            defaultValue: ###"Tap to open"###,
            table: "Variations",
            locale: .current,
            bundle: .current
        )
        )
    internal static func stringPlural(_ arg1: Int) -> String {
        resolve(
            LocalizedStringResource(
                "String.Plural",
                defaultValue: ###"I have \###(arg1) strings"###,
                table: "Variations",
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
private extension Variations {
    static func resolve(_ resource: LocalizedStringResource) -> String { String(localized: resource)
    }
}
