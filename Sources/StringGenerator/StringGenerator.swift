import Foundation
import StringResource
import SwiftBasicFormat
import SwiftIdentifier
import SwiftSyntax
import SwiftSyntaxBuilder

public struct StringGenerator {
    public enum AccessLevel: String, CaseIterable {
        case `internal`, `public`, `package`
    }

    let tableName: String
    let accessLevel: AccessLevel
    let resources: [Resource]

    init(tableName: String, accessLevel: AccessLevel, resources: [Resource]) {
        self.tableName = tableName
        self.accessLevel = accessLevel
        self.resources = resources
    }

    public static func generateSource(
        for resources: [Resource],
        tableName: String,
        accessLevel: AccessLevel
    ) -> String {
        StringGenerator(tableName: tableName, accessLevel: accessLevel, resources: resources)
            .generate()
            .formatted()
            .description
    }

    func generate() -> SourceFileSyntax {
        SourceFileSyntax(
            statementsBuilder: {
                generateImports()
                generateStringsTableExtension()
                generateBundleDescriptionExtension()
                generateResolveExtension()
            },
            trailingTrivia: .newline
        )
        .spacingStatements()
    }

    // MARK: - Source File Contents

    func generateImports() -> ImportDeclSyntax {
        ImportDeclSyntax(
            path: [
                ImportPathComponentSyntax(name: .import(.Foundation))
            ]
        )
    }

    func generateStringsTableExtension() -> EnumDeclSyntax {
        EnumDeclSyntax(
            attributes: [
                .attribute(
                    AttributeSyntax(availability: .wwdc2022)
                        .with(\.trailingTrivia, .newline)
                )
            ],
            modifiers: [
                DeclModifierSyntax(name: accessLevel.token)
            ],
            name: namespaceToken
        ) {
            for resource in resources {
                resource.declaration(
                    tableName: tableName,
                    accessLevel: accessLevel.token,
                    resolveToken: resolveFuncToken
                )
            }
        }
    }

    func generateBundleDescriptionExtension() -> ExtensionDeclSyntax {
        ExtensionDeclSyntax(
            availability: .wwdc2022,
            extendedType: localizedStringResourceBundleDescriptionMemberType
        ) {
            IfConfigDeclSyntax(
                prefixOperator: "!",
                reference: "SWIFT_PACKAGE",
                elements: .decls([
                    .init(decl: DeclSyntax("private class BundleLocator {}"))
                ])
            )

            VariableDeclSyntax(
                modifiers: [
                    DeclModifierSyntax(name: .keyword(.fileprivate)),
                    DeclModifierSyntax(name: .keyword(.static)),
                ],
                bindingSpecifier: .keyword(.let),
                bindings: [
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: "current"),
                        typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .keyword(.Self))),
                        initializer: InitializerClauseSyntax(
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                calledExpression: ClosureExprSyntax(statements: [
                                    CodeBlockItemSyntax(
                                        item: .decl(
                                            DeclSyntax(
                                                IfConfigDeclSyntax(
                                                    reference: "SWIFT_PACKAGE",
                                                    elements: .statements([
                                                        CodeBlockItemSyntax(item: .expr(ExprSyntax(".atURL(Bundle.module.bundleURL)")))
                                                    ]),
                                                    else: .statements([
                                                        CodeBlockItemSyntax(item: .expr(ExprSyntax(".forClass(BundleLocator.self)")))
                                                    ])
                                                )
                                            )
                                        )
                                    )
                                ]),
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax {},
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                ]
            )
        }
        .spacingMembers()
    }

    func generateResolveExtension() -> ExtensionDeclSyntax {
        let paramName = TokenSyntax("resource")
        return ExtensionDeclSyntax(
            availability: .wwdc2022,
            accessLevel: .private,
            extendedType: IdentifierTypeSyntax(name: .identifier(tableName))
        ) {
            FunctionDeclSyntax(
                modifiers: [
                    DeclModifierSyntax(name: .keyword(.static)),
                ],
                name: resolveFuncToken,
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        parameters: FunctionParameterListSyntax {
                            FunctionParameterSyntax(
                                firstName: .wildcardToken(),
                                secondName: paramName,
                                type: .identifier(.LocalizedStringResource)
                            )
                        }
                    ),
                    returnClause: ReturnClauseSyntax(type: .identifier(.String))
                ),
                body: CodeBlockSyntax(
                    statements: [
                        CodeBlockItemSyntax(
                            leadingTrivia: .space,
                            item: .decl(
                                DeclSyntax(
                                    " String(localized: resource)"
                                )
                            )
                        )
                    ]
                )
            )
        }
        .spacingMembers()
    }

    // MARK: - Helpers

    // Localizable
    var namespaceToken: TokenSyntax {
        .identifier(SwiftIdentifier.identifier(from: tableName))
    }

    // String.Localizable
    var localTableMemberType: MemberTypeSyntax {
        MemberTypeSyntax(
            baseType: .identifier(.String),
            name: namespaceToken
        )
    }

    // String.Localizable.BundleDescription
    var localBundleDescriptionMemberType: MemberTypeSyntax {
        MemberTypeSyntax(
            baseType: localTableMemberType,
            name: .type(.BundleDescription)
        )
    }

    // LocalizedStringResource.BundleDescription
    var localizedStringResourceBundleDescriptionMemberType: MemberTypeSyntax {
        MemberTypeSyntax(
            baseType: .identifier(.LocalizedStringResource),
            name: .type(.BundleDescription)
        )
    }

    // localizable
    var variableToken: TokenSyntax {
        .identifier(SwiftIdentifier.variableIdentifier(for: tableName))
    }

    // bundleDescription
    var bundleToken: TokenSyntax {
        .identifier("bundleDescription")
    }

    var resolveFuncToken: TokenSyntax {
        .identifier("resolve")
    }
}

extension StringGenerator.AccessLevel {
    var token: TokenSyntax {
        switch self {
        case .internal: .keyword(.internal)
        case .public: .keyword(.public)
        case .package: .keyword(.package)
        }
    }
}

extension Resource {
    func declaration(
        tableName: String,
        accessLevel: TokenSyntax,
        resolveToken: TokenSyntax
    ) -> DeclSyntaxProtocol {
        let modifiers = [
            DeclModifierSyntax(name: accessLevel),
            DeclModifierSyntax(name: .keyword(.static)),
        ]

        return if arguments.isEmpty {
            VariableDeclSyntax(
                leadingTrivia: leadingTrivia,
                modifiers: .init(modifiers),
                bindingSpecifier: .keyword(.let),
                bindings: [
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: name),
                        initializer: InitializerClauseSyntax(
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                calledExpression: DeclReferenceExprSyntax(baseName: resolveToken),
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax {
                                    LabeledExprSyntax(
                                        leadingTrivia: .newline,
                                        label: nil,
                                        expression: statements(table: tableName),
                                        trailingTrivia: .newline
                                    )
                                },
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                ]
            )
        } else {
            FunctionDeclSyntax(
                leadingTrivia: leadingTrivia,
                modifiers: .init(modifiers),
                name: name,
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax {
                        for argument in arguments {
                            argument.parameter
                        }
                    }.commaSeparated(),
                    returnClause: ReturnClauseSyntax(type: .identifier(.String))
                ),
                body: CodeBlockSyntax(statements: [
                    CodeBlockItemSyntax(
                        item: .expr(
                            ExprSyntax(
                                FunctionCallExprSyntax(
                                    calledExpression: DeclReferenceExprSyntax(baseName: resolveToken),
                                    leftParen: .leftParenToken(),
                                    arguments: LabeledExprListSyntax {
                                        LabeledExprSyntax(
                                            leadingTrivia: .newline,
                                            label: nil,
                                            expression: statements(table: tableName),
                                            trailingTrivia: .newline
                                        )
                                    },
                                    rightParen: .rightParenToken()
                                )
                            )
                        )
                    )
                ])
            )
        }
    }

    var name: TokenSyntax {
        .identifier(identifier)
    }

    var leadingTrivia: Trivia {
        var trivia: Trivia = .init(pieces: [])

        if let commentLines = comment?.components(separatedBy: .newlines), !commentLines.isEmpty {
            for line in commentLines {
                trivia = trivia.appending(Trivia.docLineComment("/// \(line)"))
                trivia = trivia.appending(.newline)
            }
        }

        return trivia
    }

    func statements(
        table: String
    ) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(
            callee: DeclReferenceExprSyntax(
                baseName: .type(.LocalizedStringResource)
            )
        ) {
            LabeledExprSyntax(expression: keyExpr)

            LabeledExprSyntax(label: "defaultValue", expression: defaultValueExpr)

            LabeledExprSyntax(
                label: "table",
                expression: StringLiteralExprSyntax(content: table)
            )

            LabeledExprSyntax(
                label: "locale",
                expression: MemberAccessExprSyntax(
                    name: .identifier("current")
                )
            )

            LabeledExprSyntax(
                label: "bundle",
                expression: MemberAccessExprSyntax(
                    name: .identifier("current")
                )
            )
        }
        .multiline()
    }

    var keyExpr: StringLiteralExprSyntax {
        StringLiteralExprSyntax(content: key)
    }

    // TODO: Improve this
    // 1. Maybe use multiline string literals?
    // 2. Calculate the correct number of pounds to be used.
    var defaultValueExpr: StringLiteralExprSyntax {
        StringLiteralExprSyntax(
            openingPounds: .rawStringPoundDelimiter("###"),
            openingQuote: .stringQuoteToken(),
            segments: StringLiteralSegmentListSyntax(defaultValue.map(\.element)),
            closingQuote: .stringQuoteToken(),
            closingPounds: .rawStringPoundDelimiter("###")
        )
    }
}

extension Argument {
    var parameter: FunctionParameterSyntax {
        FunctionParameterSyntax(
            firstName: label.flatMap { .identifier($0) } ?? .wildcardToken(),
            secondName: .identifier(name),
            type: IdentifierTypeSyntax(name: .identifier(type))
        )
    }
}

extension StringSegment {
    var element: StringLiteralSegmentListSyntax.Element {
        switch self {
        case .string(let content):
            return .stringSegment(
                StringSegmentSyntax(
                    content: .stringSegment(
                        content.escapingForStringLiteral(usingDelimiter: "###", isMultiline: false)
                    )
                )
            )
        case .interpolation(let identifier):
            return .expressionSegment(
                ExpressionSegmentSyntax(
                    pounds: .rawStringPoundDelimiter("###"),
                    expressions: [
                        LabeledExprSyntax(
                            expression: DeclReferenceExprSyntax(
                                baseName: .identifier(identifier)
                            )
                        )
                    ]
                )
            )
        }
    }
}

// Taken from inside SwiftSyntax
private extension String {
    /// Replace literal newlines with "\r", "\n", "\u{2028}", and ASCII control characters with "\0", "\u{7}"
    func escapingForStringLiteral(usingDelimiter delimiter: String, isMultiline: Bool) -> String {
        // String literals cannot contain "unprintable" ASCII characters (control
        // characters, etc.) besides tab. As a matter of style, we also choose to
        // escape Unicode newlines like "\u{2028}" even though swiftc will allow
        // them in string literals.
        func needsEscaping(_ scalar: UnicodeScalar) -> Bool {
            if Character(scalar).isNewline {
                return true
            }

            if !scalar.isASCII || scalar.isPrintableASCII {
                return false
            }

            if scalar == "\t" {
                // Tabs need to be escaped in single-line string literals but not
                // multi-line string literals.
                return !isMultiline
            }
            return true
        }

        // Work at the Unicode scalar level so that "\r\n" isn't combined.
        var result = String.UnicodeScalarView()
        var input = self.unicodeScalars[...]
        while let firstNewline = input.firstIndex(where: needsEscaping(_:)) {
            result += input[..<firstNewline]

            result += "\\\(delimiter)".unicodeScalars
            switch input[firstNewline] {
            case "\r":
                result += "r".unicodeScalars
            case "\n":
                result += "n".unicodeScalars
            case "\t":
                result += "t".unicodeScalars
            case "\0":
                result += "0".unicodeScalars
            case let other:
                result += "u{\(String(other.value, radix: 16))}".unicodeScalars
            }
            input = input[input.index(after: firstNewline)...]
        }
        result += input

        return String(result)
    }
}

private extension Unicode.Scalar {
    /// Whether this character represents a printable ASCII character,
    /// for the purposes of pattern parsing.
    var isPrintableASCII: Bool {
        // Exclude non-printables before the space character U+20, and anything
        // including and above the DEL character U+7F.
        return self.value >= 0x20 && self.value < 0x7F
    }
}

extension Trivia {
    init(docComment: String) {
        self = docComment
            .components(separatedBy: .newlines)
            .map { "/// \($0)" }
            .map { [.docLineComment($0.trimmingCharacters(in: .whitespaces)), .newlines(1)] }
            .reduce([], +)
    }
}
