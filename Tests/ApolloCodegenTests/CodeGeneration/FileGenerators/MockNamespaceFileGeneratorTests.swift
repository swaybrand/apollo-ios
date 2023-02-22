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
}

private extension ApolloCodegenConfiguration {
  static func mock(
    _ moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    schemaName: String = "TestSchema",
    testMocks: ApolloCodegenConfiguration.TestMockFileOutput,
    to path: String
  ) -> Self {
    .mock(
      schemaName: schemaName,
      output: .init(
        schemaTypes: .init(
          path: path,
          moduleType: moduleType),
        testMocks: testMocks)
    )
  }
}
