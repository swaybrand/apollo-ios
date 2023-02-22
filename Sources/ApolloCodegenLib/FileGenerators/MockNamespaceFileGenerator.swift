import Foundation

struct MockNamespaceFileGenerator: FileGenerator {
  let config: ApolloCodegen.ConfigurationContext

  var fileName: String { "\(config.schemaName)TestMocks"}

  var template: TemplateRenderer {
    MockNamespaceTemplate(config: config)
  }

  var target: FileTarget { .testMock }

  init?(config: ApolloCodegen.ConfigurationContext) {
    if config.needsTypesWrappedInNamespace, config.output.testMocks != .none {
      self.config = config
    } else {
      return nil
    }
  }
}
