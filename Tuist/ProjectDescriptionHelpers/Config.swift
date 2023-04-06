import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .list([
        .upToNextMajor("14.0.0")
    ]),
    generationOptions: .options()
)
