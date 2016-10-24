////
///  CategoryGenerator.swift
//

public final class CategoryGenerator: StreamGenerator {

    public var currentUser: User?
    public var streamKind: StreamKind
    weak public var destination: StreamDestination?

    private var category: Category?
    private var posts: [Post]?
    private var hasPosts: Bool?
    private var localToken: String!
    private var loadingToken = LoadingToken()

    private let queue = NSOperationQueue()

    func headerItems() -> [StreamCellItem] {
        guard let category = category else { return [] }

        let items = [
            StreamCellItem(jsonable: category, type: .CategoryHeader),
        ]
//        if hasPosts != false {
//            items += [
//                StreamCellItem(jsonable: user, type: .FullWidthSpacer(height: 3)),
//                StreamCellItem(jsonable: user, type: .ColumnToggle),
//                StreamCellItem(jsonable: user, type: .FullWidthSpacer(height: 5))
//            ]
//        }
        return items
    }

    public init(category: Category?,
                currentUser: User?,
                streamKind: StreamKind,
                destination: StreamDestination?
        ) {
        self.category = category
        self.currentUser = currentUser
        self.streamKind = streamKind
        self.localToken = loadingToken.resetInitialPageLoadingToken()
        self.destination = destination
    }

    public func load(reload reload: Bool = false) {
        let doneOperation = AsyncOperation()
        queue.addOperation(doneOperation)

        localToken = loadingToken.resetInitialPageLoadingToken()
        setPlaceHolders()
        setInitialCategory(doneOperation)
        loadCategory(doneOperation, reload: reload)
        loadCategoryPosts(doneOperation)
    }

    public func toggleGrid() {
        guard let posts = posts else { return }
        destination?.replacePlaceholder(.ProfilePosts, items: parse(posts)) {}
    }

}

private extension CategoryGenerator {

    func setPlaceHolders() {
//        let header = StreamCellItem(type: .ProfileHeaderGhost, placeholderType: .ProfileHeader)
//        header.calculatedCellHeights.oneColumn = ProfileHeaderGhostCell.Size.height
//        header.calculatedCellHeights.multiColumn = ProfileHeaderGhostCell.Size.height
        destination?.setPlaceholders([
            StreamCellItem(type: .Placeholder, placeholderType: .CategoryHeader),
            StreamCellItem(type: .Placeholder, placeholderType: .CategoryPosts)
        ])
    }

    func setInitialCategory(doneOperation: AsyncOperation) {
        guard let category = category else { return }

        destination?.setPrimaryJSONAble(category)
        destination?.replacePlaceholder(.CategoryHeader, items: headerItems()) {}
        doneOperation.run()
    }

    func loadCategory(doneOperation: AsyncOperation, reload: Bool = false) {
//        guard !doneOperation.finished || reload else { return }
        guard let category = category else { return }

        // load the category
        CategoryService().loadCategory(category.slug)
            .onSuccess { [weak self] category in
                guard let sself = self else { return }
                guard sself.loadingToken.isValidInitialPageLoadingToken(sself.localToken) else { return }
                sself.category = category
                sself.destination?.setPrimaryJSONAble(category)
                let items = sself.parse([category])
                sself.destination?.replacePlaceholder(.CategoryHeader, items: items) {}
                doneOperation.run()
            }
            .onFail { [weak self] _ in
                guard let sself = self else { return }
                sself.destination?.primaryJSONAbleNotFound()
                sself.queue.cancelAllOperations()
        }
    }

    func loadCategoryPosts(doneOperation: AsyncOperation) {
        guard let category = category else { return }
        let displayPostsOperation = AsyncOperation()
        displayPostsOperation.addDependency(doneOperation)
        queue.addOperation(displayPostsOperation)

        self.destination?.replacePlaceholder(.ProfilePosts, items: [StreamCellItem(type: .StreamLoading)]) {}
    
        StreamService().loadStream(
            category.endpoint,
            streamKind: streamKind,
            success: { [weak self] (jsonables, responseConfig) in
                guard let sself = self else { return }
                guard sself.loadingToken.isValidInitialPageLoadingToken(sself.localToken) else { return }

                let items = sself.parse(jsonables)
                displayPostsOperation.run {
                    inForeground {
                        sself.destination?.replacePlaceholder(.CategoryPosts, items: items) {
                            sself.destination?.pagingEnabled = true
                        }
                    }
                }

            }, failure: { [weak self] _ in
                guard let sself = self else { return }
                sself.destination?.primaryJSONAbleNotFound()
                sself.queue.cancelAllOperations()
            }, noContent: { [weak self] in
                guard let sself = self else { return }
                sself.destination?.primaryJSONAbleNotFound()
                sself.queue.cancelAllOperations()
        })
    }
}
