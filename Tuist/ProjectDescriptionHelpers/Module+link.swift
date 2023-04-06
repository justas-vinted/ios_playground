import ProjectDescription

extension Module {
    
    func linkContract(for module: Module) {
        [
            contract,
            implementation,
            mocks,
            unitTests,
            snapshotTests,
            demoApp,
            integrationTests
        ].forEach { target in
            target?.dependencies += [
                .project(
                    target: module.contract.name,
                    path: "../\(module.name)"
                )
            ]
        }
    }
    
    func linkImplementation(for module: Module) {
        guard let moduleImplementation = module.implementation else { return }

        [
            contract,
            implementation,
            mocks,
            unitTests,
            snapshotTests,
            demoApp,
            integrationTests
        ].forEach { target in
            target?.dependencies += [
                .project(
                    target: moduleImplementation.name,
                    path: "../\(module.name)"
                )
            ]
        }
    }
    
    func linkContractAndImplementation(for module: Module) {
        linkContract(for: module)
        linkImplementation(for: module)
    }
}
