import Foundation

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
internal enum FormatSpecifiers {
    /// %@ should convert to a String argument
    internal static func at(_ arg1: String) -> String {
        resolve(
            LocalizedStringResource(
                "at",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// %c should convert to a CChar argument
    internal static func c(_ arg1: CChar) -> String {
        resolve(
            LocalizedStringResource(
                "c",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// %d should convert to an Int argument
    internal static func d(_ arg1: Int) -> String {
        resolve(
            LocalizedStringResource(
                "d",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// %lld should covert to an Int
    internal static func d_length(_ arg1: Int) -> String {
        resolve(
            LocalizedStringResource(
                "d_length",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// %f should convert to a Double argument
    internal static func f(_ arg1: Double) -> String {
        resolve(
            LocalizedStringResource(
                "f",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// %.2f should convert to a Double argument
    internal static func f_precision(_ arg1: Double) -> String {
        resolve(
            LocalizedStringResource(
                "f_precision",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// %i should convert to an Int argument
    internal static func i(_ arg1: Int) -> String {
        resolve(
            LocalizedStringResource(
                "i",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// %o should convert to a UInt argument
    internal static func o(_ arg1: UInt) -> String {
        resolve(
            LocalizedStringResource(
                "o",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// %p should convert to an UnsafeRawPointer argument
    internal static func p(_ arg1: UnsafeRawPointer) -> String {
        resolve(
            LocalizedStringResource(
                "p",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// %s should convert to an UnsafePointer<CChar> argument
    internal static func s(_ arg1: UnsafePointer<CChar>) -> String {
        resolve(
            LocalizedStringResource(
                "s",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// %u should convert to a UInt argument
    internal static func u(_ arg1: UInt) -> String {
        resolve(
            LocalizedStringResource(
                "u",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
                locale: .current,
                bundle: .current
            )
            )
    }
    /// %x should convert to a UInt argument
    internal static func x(_ arg1: UInt) -> String {
        resolve(
            LocalizedStringResource(
                "x",
                defaultValue: ###"Test \###(arg1)"###,
                table: "FormatSpecifiers",
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
private extension FormatSpecifiers {
    static func resolve(_ resource: LocalizedStringResource) -> String { String(localized: resource)
    }
}
