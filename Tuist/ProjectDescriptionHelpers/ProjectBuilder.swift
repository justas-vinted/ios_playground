import ProjectDescription

public final class ProjectBuilder {
    public final class ModuleTarget {
        public enum TargetPath {
            case relativeToProjectPathUsingTargetName
            case relativeToProjectPath(path: String)

            func pathRelativeTo(projectPath: String, targetName: String) -> String {
                switch self {
                case .relativeToProjectPath(path: let path):
                    return "\(projectPath)/\(path)"
                case .relativeToProjectPathUsingTargetName:
                    return "\(projectPath)/\(targetName)"
                }
            }
        }

        public enum Resource {
            case relativeToTarget(path: String)
            case absolute(Path)

            func pathRelativeTo(targetPath: String) -> String {
                switch self {
                case .absolute(let path):
                    return path.pathString
                case .relativeToTarget(path: let path):
                    return "\(targetPath)/\(path)"
                }
            }
        }

        public static let defaultResources: [Resource] = [
            "/**/*.xcassets",
            "/**/*.xib",
        ].map(Resource.relativeToTarget(path:))

        public static let defaultSources: [Resource] = [
            "/**/*.swift"
        ].map(Resource.relativeToTarget(path:))

        public var name: String
        public let targetPath: TargetPath
        public var dependencies: [TargetDependency]
        public var product: Product
        public var sources: [Resource]
        public var resources: [Resource]
        public var additionalScripts: [TargetScript]
        public var infoPlist: ProjectDescription.InfoPlist
        let deploymentTarget: DeploymentTarget

        public init(name: String,
                    targetPath: TargetPath = .relativeToProjectPathUsingTargetName,
                    product: Product,
                    sources: [Resource] = ModuleTarget.defaultSources,
                    resources: [Resource] = [],
                    dependencies: [TargetDependency] = [],
                    additionalScripts: [TargetScript] = [],
                    infoPlist: ProjectDescription.InfoPlist = .default,
                    deploymentTarget: DeploymentTarget = Constants.deploymentTarget) {
            self.name = name
            self.dependencies = dependencies
            self.product = product
            self.resources = resources
            self.additionalScripts = additionalScripts
            self.deploymentTarget = deploymentTarget
            self.infoPlist = infoPlist
            self.sources = sources
            self.targetPath = targetPath
        }
    }

    let projectPath: String
    let targets: [ModuleTarget]
    let packages: [Package]
    let schemes: [Scheme]
    var projectName: String { ProjectDescriptionHelpers.name(from: projectPath) }

    public init(path: String,
                targets: [ModuleTarget] = [],
                schemes: [Scheme] = [],
                packages: [Package] = []) {
        self.targets = targets
        self.projectPath = path
        self.packages = packages
        self.schemes = schemes
    }

    public func build() -> Project {
        Project(
            name: projectName,
            organizationName: Constants.organizationName,
            options: .options(
                automaticSchemesOptions: .disabled
            ),
            packages: packages,
            settings: settings,
            targets: projectTargets,
            schemes: schemes,
            fileHeaderTemplate: nil,
            additionalFiles: [],
            resourceSynthesizers: []
        )
    }

    private var settings: Settings? {
        .settings(configurations: [.debug(name: .debug)])
    }

    private var projectTargets: [Target] {
        targets.map { target in
            let targetPath = target.targetPath.pathRelativeTo(projectPath: projectPath, targetName: target.name)
            return Target(
                name: target.name,
                platform: .iOS,
                product: target.product,
                productName: target.name,
                bundleId: "\(Constants.bundlePrefix).\(target.name)",
                deploymentTarget: target.deploymentTarget,
                infoPlist: target.infoPlist,
                sources: ProjectDescription.SourceFilesList(
                    globs: target.sources
                        .map {
                            SourceFileGlob(
                                stringLiteral: $0.pathRelativeTo(targetPath: targetPath)
                            )
                        }
                ),
                resources: ResourceFileElements(
                    resources: target.resources.map { resource in
                        ResourceFileElement(stringLiteral: resource.pathRelativeTo(targetPath: targetPath))
                    }
                ),
                copyFiles: [],
                headers: .headers(
                    public: ["\(targetPath)/**"]
                ),
                entitlements: nil,
                scripts: target.scripts,
                dependencies: target.dependencies,
                settings: nil,
                coreDataModels: [],
                environment: [:],
                launchArguments: []
            )
        }
    }
}

extension ProjectBuilder.ModuleTarget {

    var scripts: [ProjectDescription.TargetScript] {
        additionalScripts
    }
}

func name(from path: String) -> String {
    guard let name = path.split(separator: "/").last else {
        fatalError("Invalid path:\(path)")
    }
    return String(name)
}
