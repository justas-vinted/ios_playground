import ProjectDescription
import Foundation

public final class Module: NSObject {
    public typealias Target = ProjectBuilder.ModuleTarget

    public let name: String
    public let contract: Target
    public var implementation: Target?
    public var unitTests: Target?
    public var mocks: Target?
    public var integrationTests: Target?
    public var snapshotTests: Target?
    public var demoApp: Target?
    public var packages: [Package]

    public init(name: String, packages: [Package] = []) {
        self.name = name

        self.contract = Target(
            name: "\(name)Contract",
            targetPath: .relativeToProjectPath(path: "Contract"),
            product: .framework
        )
        self.implementation = Target(
            name: "\(name)Implementation",
            targetPath: .relativeToProjectPath(path: "Implementation"),
            product: .staticFramework,
            resources: ProjectBuilder.ModuleTarget.defaultResources
        )
        self.mocks = Target(
            name: "\(name)Mocks",
            targetPath: .relativeToProjectPath(path: "Mocks"),
            product: .staticFramework
        )
        self.unitTests = Target(
            name: "\(name)UnitTests",
            targetPath: .relativeToProjectPath(path: "UnitTests"),
            product: .unitTests
        )
        self.snapshotTests = Target(
            name: "\(name)SnapshotTests",
            targetPath: .relativeToProjectPath(path: "SnapshotTests"),
            product: .unitTests
        )
        self.integrationTests = Target(
            name: "\(name)IntegrationTests",
            targetPath: .relativeToProjectPath(path: "IntegrationTests"),
            product: .unitTests
        )
        self.demoApp = Target(
            name: "\(name)Demo",
            targetPath: .relativeToProjectPath(path: "Demo"),
            product: .app
        )
        self.packages = packages
    }
}

extension Module {
    public func buildProject() -> Project {

        linkTargets()

        return ProjectBuilder(
            path: "./../\(name)",
            targets: [
                contract,
                implementation,
                unitTests,
                integrationTests,
                snapshotTests,
                demoApp,
                mocks
            ].compactMap {
                $0
            },
            schemes: [implementationScheme],
            packages: packages
        )
        .build()
    }

    private func linkTargets() {
        implementation?.dependencies += [contract]
            .map { .target(name: $0.name) }
        mocks?.dependencies += [contract, implementation]
            .compactMap { $0 }
            .map { .target(name: $0.name) }
        [unitTests, integrationTests, snapshotTests, demoApp].forEach { targer in
            targer?.dependencies += [contract, implementation, mocks]
                .compactMap { $0 }
                .map { .target(name: $0.name) }
        }

        snapshotTests?.dependencies += [.package(product: "SnapshotTesting")]
    }

    private var implementationScheme: Scheme {
        Scheme(
            name: name,
            buildAction: .init(
                targets: [
                    contract,
                    implementation,
                    unitTests,
                    snapshotTests,
                    integrationTests,
                    demoApp
                ]
                .compactMap { $0 }
                .map {
                    .init(projectPath: nil, target: $0.name)
                }
            ),
            testAction: .targets(
                [
                    unitTests,
                    integrationTests,
                    snapshotTests
                ]
                .compactMap { $0 }
                .map { target in
                    .init(
                        target: .init(
                            projectPath: nil,
                            target: target.name
                        )
                    )
                },
                arguments: .init(),
                options: .options(
                    coverage: true,
                    codeCoverageTargets: [
                        contract, implementation
                    ]
                    .compactMap { $0 }
                    .map {
                        .init(
                            projectPath: nil,
                            target: $0.name
                        )
                    }
                )
            )
        )
    }
}
