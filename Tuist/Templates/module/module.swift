import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let moduleTemplate = Template(
    description: "New module template",
    attributes: [
        nameAttribute
    ],
    items: [
        .file(path: "\(nameAttribute)/Contract/File.swift", templatePath: "placeholder.stencil"),
        .file(path: "\(nameAttribute)/Implementation/File.swift", templatePath: "placeholder.stencil"),
        .file(path: "\(nameAttribute)/Mocks/File.swift", templatePath: "placeholder.stencil"),
        .file(path: "\(nameAttribute)/UnitTests/Tests.swift", templatePath: "placeholder.stencil"),
        .file(path: "\(nameAttribute)/SnapshotTests/Tests.swift", templatePath: "placeholder.stencil"),
        .file(path: "\(nameAttribute)/IntegrationTests/Tests.swift", templatePath: "placeholder.stencil"),
        .file(path: "\(nameAttribute)/Demo/AppDelegate.swift", templatePath: "app_delegate.stencil"),
        .file(path: "\(nameAttribute)/Project.swift", templatePath: "project.stencil"),
        .file(path: "Tuist/ProjectDescriptionHelpers/Modules/Module+\(nameAttribute).swift", templatePath: "module_extension.stencil")
    ]
)
