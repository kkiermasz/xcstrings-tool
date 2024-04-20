import Foundation

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
package enum Localizable {
    /// This is a comment
    package static let key = resolve(
        LocalizedStringResource(
            "Key",
            defaultValue: ###"Default Value"###,
            table: "Localizable",
            locale: .current,
            bundle: .current
        )
        )
    package static let myDeviceVariant = resolve(
        LocalizedStringResource(
            "myDeviceVariant",
            defaultValue: ###"Multiplatform Original"###,
            table: "Localizable",
            locale: .current,
            bundle: .current
        )
        )
    package static func myPlural(_ arg1: Int) -> String {
        resolve(
            LocalizedStringResource(
                "myPlural",
                defaultValue: ###"I have \###(arg1) plurals"###,
                table: "Localizable",
                locale: .current,
                bundle: .current
            )
            )
    }
    package static func mySubstitute(_ arg1: Int, count arg2: Int) -> String {
        resolve(
            LocalizedStringResource(
                "mySubstitute",
                defaultValue: ###"\###(arg1): People liked \###(arg2) posts"###,
                table: "Localizable",
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
private extension Localizable {
    static func resolve(_ resource: LocalizedStringResource) -> String { String(localized: resource)
    }
}
