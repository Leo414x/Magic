import SwiftData
import Foundation

/// mat 列表 CRUD
enum MatStore {
    static func createMat(context: ModelContext) -> MatDocument {
        let mat = MatDocument()
        context.insert(mat)
        try? context.save()
        return mat
    }

    static func delete(_ mat: MatDocument, context: ModelContext) {
        context.delete(mat)
        try? context.save()
    }
}
