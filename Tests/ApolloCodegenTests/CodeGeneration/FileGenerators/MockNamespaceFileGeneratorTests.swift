import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class MockNamespaceFileGeneratorTests: XCTestCase {
  let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
  let mockFileManager = MockApolloFileManager(strict: false)

  var subject: MockNamespaceFileGenerator!

  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()
    subject = nil

    super.tearDown()
  }

  func buildSubject(config: ApolloCodegen.ConfigurationContext) {
    subject = MockNamespaceFileGenerator(config: config)
  }

  // MARK: - Tests

  func test__generate__givenModuleType_swiftPackageManager_shouldBeNil() throws {
    // given
    let configuration = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      .swiftPackageManager,
      testMocks: .absolute(path: rootURL.path),
      to: rootURL.path
    ))

    buildSubject(config: configuration)
    
    // then
    expect(self.subject).to(beNil())
  }

  func test__generate__givenModuleType_embeddedInTarget_lowercaseSchemaName_shouldGenerateNamespaceFileWithCapitalizedName() throws {
    // given
    let fileURL = rootURL.appendingPathComponent("SchemaTestMocks.graphql.swift")

    let configuration = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      .embeddedInTarget(name: "MockApplication"),
      schemaName: "schema",
      testMocks: .absolute(path: rootURL.path),
      to: rootURL.path
    ))

    buildSubject(config: configuration)

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      // then
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // when
    try subject.generate(forConfig: configuration, fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__givenModuleType_embeddedInTarget_uppercaseSchemaName_shouldGenerateNamespaceFileWithUppercaseName() throws {
    // given
    let fileURL = rootURL.appendingPathComponent("SCHEMATestMocks.graphql.swift")

    let configuration = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      .embeddedInTarget(name: "MockApplication"),
      schemaName: "SCHEMA",
      testMocks: .absolute(path: rootURL.path),
      to: rootURL.path
    ))

    buildSubject(config: configuration)

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      // then
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // when
    try subject.generate(forConfig: configuration, fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__givenModuleType_embeddedInTarget_capitalizedSchemaName_shouldGenerateNamespaceFileWithCapitalizedName() throws {
    // given
    let fileURL = rootURL.appendingPathComponent("MySchemaTestMocks.graphql.swift")

    let configuration = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      .embeddedInTarget(name: "MockApplication"),
      schemaName: "MySchema",
      testMocks: .absolute(path: rootURL.path),
      to: rootURL.path
    ))

    buildSubject(config: configuration)

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      // then
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // when
    try subject.generate(forConfig: configuration, fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__givenModuleType_other_shouldBeNil() throws {
    // given
    let configuration = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      .other,
      testMocks: .absolute(path: rootURL.path),
      to: rootURL.path
    ))

    buildSubject(config: configuration)

    // then
    expect(self.subject).to(beNil())
  }

  func test__generate__givenTestMockFileOutput_none_shouldBeNil() throws {
    // given
    let configuration = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      .embeddedInTarget(name: "MockApplication"),
      testMocks: .none,
      options: .init(alwaysWrapInNamespace: true),
      to: rootURL.path
    ))

    buildSubject(config: configuration)

    // then
    expect(self.subject).to(beNil())
  }

  func test__generate__givenTestMockFileOutput_swiftPackage_shouldBeNil() throws {
    // given
    let configuration = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      .embeddedInTarget(name: "MockApplication"),
      testMocks: .swiftPackage(targetName: nil),
      to: rootURL.path
    ))

    buildSubject(config: configuration)

    // then
    expect(self.subject).to(beNil())
  }

  func test__generate__givenOutputOption_alwaysWrapInNamespace_shouldGenerateNamespaceFile() throws {
    // given
    let absoluteFileURL = rootURL.appendingPathComponent("TestSchemaTestMocks.graphql.swift")
    let moduleFileURL = rootURL.appendingPathComponent("TestMocks/TestSchemaTestMocks.graphql.swift")

    let tests: [(
      moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
      operations: ApolloCodegenConfiguration.OperationsFileOutput,
      testMocks: ApolloCodegenConfiguration.TestMockFileOutput,
      expectation: URL
    )] = [
      (
        moduleType: .swiftPackageManager,
        operations: .inSchemaModule,
        testMocks: .swiftPackage(targetName: nil),
        expectation: moduleFileURL
      ),
      (
        moduleType: .swiftPackageManager,
        operations: .relative(subpath: nil),
        testMocks: .swiftPackage(targetName: nil),
        expectation: moduleFileURL
      ),
      (
        moduleType: .swiftPackageManager,
        operations: .absolute(path: rootURL.path),
        testMocks: .swiftPackage(targetName: nil),
        expectation: moduleFileURL
      ),
      (
        moduleType: .swiftPackageManager,
        operations: .inSchemaModule,
        testMocks: .absolute(path: rootURL.path),
        expectation: absoluteFileURL
      ),
      (
        moduleType: .swiftPackageManager,
        operations: .relative(subpath: nil),
        testMocks: .absolute(path: rootURL.path),
        expectation: absoluteFileURL
      ),
      (
        moduleType: .swiftPackageManager,
        operations: .absolute(path: rootURL.path),
        testMocks: .absolute(path: rootURL.path),
        expectation: absoluteFileURL
      ),
      /* Ignored Cases: Invalid configurations caught in ApolloCodegenTests.swift
      (
        moduleType: .embeddedInTarget(name: "MockApplication"),
        operations: .inSchemaModule,
        testMocks: .swiftPackage(targetName: nil)
      ),
      (
        moduleType: .embeddedInTarget(name: "MockApplication"),
        operations: .relative(subpath: nil),
        testMocks: .swiftPackage(targetName: nil)
      ),
      (
        moduleType: .embeddedInTarget(name: "MockApplication"),
        operations: .absolute(path: rootURL.path),
        testMocks: .swiftPackage(targetName: nil)
      ),
      */
      (
        moduleType: .embeddedInTarget(name: "MockApplication"),
        operations: .inSchemaModule,
        testMocks: .absolute(path: rootURL.path),
        expectation: absoluteFileURL
      ),
      (
        moduleType: .embeddedInTarget(name: "MockApplication"),
        operations: .relative(subpath: nil),
        testMocks: .absolute(path: rootURL.path),
        expectation: absoluteFileURL
      ),
      (
        moduleType: .embeddedInTarget(name: "MockApplication"),
        operations: .absolute(path: rootURL.path),
        testMocks: .absolute(path: rootURL.path),
        expectation: absoluteFileURL
      ),
      /* Ignored Cases: Invalid configurations caught in ApolloCodegenTests.swift
      (
        moduleType: .other,
        operations: .inSchemaModule,
        testMocks: .swiftPackage(targetName: nil)
      ),
      (
        moduleType: .other,
        operations: .relative(subpath: nil),
        testMocks: .swiftPackage(targetName: nil)
      ),
      (
        moduleType: .other,
        operations: .absolute(path: rootURL.path),
        testMocks: .swiftPackage(targetName: nil)
      ),
      */
      (
        moduleType: .other,
        operations: .inSchemaModule,
        testMocks: .absolute(path: rootURL.path),
        expectation: absoluteFileURL
      ),
      (
        moduleType: .other,
        operations: .relative(subpath: nil),
        testMocks: .absolute(path: rootURL.path),
        expectation: absoluteFileURL
      ),
      (
        moduleType: .other,
        operations: .absolute(path: rootURL.path),
        testMocks: .absolute(path: rootURL.path),
        expectation: absoluteFileURL
      )
    ]

    for test in tests {
      let config = ApolloCodegen.ConfigurationContext(config: .mock(
        test.moduleType,
        operations: test.operations,
        testMocks: test.testMocks,
        options: .init(alwaysWrapInNamespace: true),
        to: rootURL.path
      ))

      buildSubject(config: config)

      mockFileManager.mock(closure: .createFile({ path, data, attributes in
        // then
        expect(path).to(equal(test.expectation.path))

        return true
      }))

      // when
      try subject.generate(forConfig: config, fileManager: mockFileManager)

      // then
      expect(self.mockFileManager.allClosuresCalled).to(beTrue())
    }
  }
}

private extension ApolloCodegenConfiguration {
  static func mock(
    _ moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    schemaName: String = "TestSchema",
    operations: ApolloCodegenConfiguration.OperationsFileOutput = .inSchemaModule,
    testMocks: ApolloCodegenConfiguration.TestMockFileOutput,
    options: ApolloCodegenConfiguration.OutputOptions = .init(),
    to path: String
  ) -> Self {
    .mock(
      schemaName: schemaName,
      output: .init(
        schemaTypes: .init(
          path: path,
          moduleType: moduleType),
        operations: operations,
        testMocks: testMocks),
      options: options
    )
  }
}
