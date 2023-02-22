import Foundation
import OrderedCollections

struct MockInterfacesTemplate: TemplateRenderer {

  let graphQLInterfaces: OrderedSet<GraphQLInterfaceType>

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .testMockFile

  var detachedTemplate: TemplateString? {
    TemplateString("""
    public extension MockObject {
      \(graphQLInterfaces.map {
        "typealias \($0.name.firstUppercased) = Interface"
      }, separator: "\n")
    }

    """)
  }

  var template: TemplateString { .init(stringLiteral: "") }
}
