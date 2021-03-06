////
///  PostbarControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class PostbarControllerSpec: QuickSpec {

    class ReplyAllCreatePostResponder: UIWindow, CreatePostResponder {
        var postId: String?
        var post: Post?
        var comment: ElloComment?
        var text: String?

        func createPost(text: String?, fromController: UIViewController) {
            self.text = text
        }
        func createComment(_ postId: String, text: String?, fromController: UIViewController) {
            self.postId = postId
            self.text = text
        }
        func editComment(_ comment: ElloComment, fromController: UIViewController) {
            self.comment = comment
        }
        func editPost(_ post: Post, fromController: UIViewController) {
            self.post = post
        }
    }

    class FakeCollectionView: UICollectionView {
        var fakeIndexPath: IndexPath?

        override func indexPath(for: UICollectionViewCell) -> IndexPath? {
            return fakeIndexPath
        }
    }

    override func spec() {
        var subject: PostbarController!
        var responder: ReplyAllCreatePostResponder!
        let currentUser: User = User.stub([
            "id": "user500",
            "lovesCount": 5,
            ])
        var controller: StreamViewController!
        var collectionView: FakeCollectionView!
        let streamKind: StreamKind = .postDetail(postParam: "post")

        beforeEach {
            let dataSource = StreamDataSource(streamKind: streamKind)
            dataSource.textSizeCalculator = FakeStreamTextCellSizeCalculator()
            dataSource.notificationSizeCalculator = FakeStreamNotificationCellSizeCalculator()
            dataSource.announcementSizeCalculator = FakeAnnouncementCellSizeCalculator()
            dataSource.profileHeaderSizeCalculator = FakeProfileHeaderCellSizeCalculator()

            controller = StreamViewController()
            controller.streamKind = streamKind
            controller.dataSource = dataSource
            controller.collectionView.dataSource = dataSource
            collectionView = FakeCollectionView(frame: .zero, collectionViewLayout: controller.collectionView.collectionViewLayout)

            subject = PostbarController(collectionView: collectionView, dataSource: dataSource)
            subject.currentUser = currentUser
            responder = ReplyAllCreatePostResponder()
            subject.responderChainable = ResponderChainableController(
                controller: controller,
                next: { return responder }
            )
            showController(controller, window: responder)
        }

        describe("PostbarController") {
            describe("replyToAllButtonTapped(_:)") {
                let cell = UICollectionViewCell()

                beforeEach {
                    let post: Post = stub([
                        "id": "post1",
                        "authorId": "user1",
                    ])
                    let parser = StreamCellItemParser()
                    var postCellItems = parser.parse([post], streamKind: streamKind)
                    let newComment = ElloComment.newCommentForPost(post, currentUser: currentUser)
                    postCellItems += [StreamCellItem(jsonable: newComment, type: .createComment)]
                    controller.dataSource.appendStreamCellItems(postCellItems)
                    collectionView.fakeIndexPath = IndexPath(item: postCellItems.count - 1, section: 0)
                }
                context("tapping replyToAll") {
                    it("opens an OmnibarViewController with usernames set") {
                        subject.replyToAllButtonTapped(cell)
                        expect(responder.text) == "@user1 @user2 "
                    }
                }
            }

            describe("watchPostTapped(_:cell:)") {
                let cell = StreamCreateCommentCell()

                beforeEach {
                    let post: Post = stub([
                        "id": "post1",
                        "authorId": "user1",
                    ])
                    let parser = StreamCellItemParser()
                    var postCellItems = parser.parse([post], streamKind: streamKind)
                    let newComment = ElloComment.newCommentForPost(post, currentUser: currentUser)
                    postCellItems += [StreamCellItem(jsonable: newComment, type: .createComment)]
                    controller.dataSource.appendStreamCellItems(postCellItems)
                    collectionView.fakeIndexPath = IndexPath(item: postCellItems.count - 1, section: 0)
                }

                it("should disable the cell during submission") {
                    ElloProvider.sharedProvider = ElloProvider.DelayedStubbingProvider()
                    cell.isUserInteractionEnabled = true
                    subject.watchPostTapped(true, cell: cell)
                    expect(cell.isUserInteractionEnabled) == false
                }
                it("should set the cell.watching property") {
                    ElloProvider.sharedProvider = ElloProvider.DelayedStubbingProvider()
                    cell.watching = false
                    subject.watchPostTapped(true, cell: cell)
                    expect(cell.watching) == true
                }
                it("should enable the cell after failure") {
                    ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    cell.isUserInteractionEnabled = false
                    subject.watchPostTapped(true, cell: cell)
                    expect(cell.isUserInteractionEnabled) == true
                }
                it("should restore the cell.watching property after failure") {
                    ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    cell.watching = false
                    subject.watchPostTapped(true, cell: cell)
                    expect(cell.watching) == false
                }
                it("should enable the cell after success") {
                    cell.isUserInteractionEnabled = false
                    subject.watchPostTapped(true, cell: cell)
                    expect(cell.isUserInteractionEnabled) == true
                }
                it("should post a notification after success") {
                    var postedNotification = false
                    let observer = NotificationObserver(notification: PostChangedNotification) { (post, contentChange) in
                        postedNotification = true
                    }
                    subject.watchPostTapped(true, cell: cell)
                    expect(postedNotification) == true
                    observer.removeObserver()
                }
            }

            describe("loveButtonTapped(_:)") {
                var post: Post!

                func stubCellItems(loved: Bool) {
                    post = Post.stub([
                        "id": "post1",
                        "authorId": "user1",
                        "lovesCount": 5,
                        "loved": loved
                    ])
                    let parser = StreamCellItemParser()
                    let postCellItems = parser.parse([post], streamKind: streamKind)
                    controller.dataSource.appendUnsizedCellItems(postCellItems, withWidth: 320.0) { cellCount in
                        controller.collectionView.reloadData()
                    }
                }

                beforeEach {
                    collectionView.fakeIndexPath = IndexPath(item: 0, section: 0)
                }

                context("post has not been loved") {
                    it("loves the post") {
                        stubCellItems(loved: false)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        var lovesCount = 0
                        var contentChange: ContentChange?
                        let observer = NotificationObserver(notification: PostChangedNotification) { (post, change) in
                            lovesCount = post.lovesCount!
                            contentChange = change
                        }
                        subject.lovesButtonTapped(cell)
                        observer.removeObserver()

                        expect(lovesCount) == 6
                        expect(contentChange) == .loved
                    }

                    it("increases currentUser lovesCount") {
                        stubCellItems(loved: false)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        let prevLovesCount = currentUser.lovesCount!
                        var lovesCount = 0
                        let observer = NotificationObserver(notification: CurrentUserChangedNotification) { (user) in
                            lovesCount = user.lovesCount!
                        }
                        subject.lovesButtonTapped(cell)
                        observer.removeObserver()

                        expect(lovesCount) == prevLovesCount + 1
                    }
                }

                context("post has already been loved") {
                    it("unloves the post") {
                        stubCellItems(loved: true)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        var lovesCount = 0
                        var contentChange: ContentChange?
                        let observer = NotificationObserver(notification: PostChangedNotification) { (post, change) in
                            lovesCount = post.lovesCount!
                            contentChange = change
                        }
                        subject.lovesButtonTapped(cell)
                        observer.removeObserver()

                        expect(lovesCount) == 4
                        expect(contentChange) == .loved
                    }

                    it("decreases currentUser lovesCount") {
                        stubCellItems(loved: true)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        let prevLovesCount = currentUser.lovesCount!
                        var lovesCount = 0
                        let observer = NotificationObserver(notification: CurrentUserChangedNotification) { (user) in
                            lovesCount = user.lovesCount!
                        }
                        subject.lovesButtonTapped(cell)
                        observer.removeObserver()

                        expect(lovesCount) == prevLovesCount - 1
                    }
                }

                context("footer cell is not visible") {
                    it("loves the post") {
                        stubCellItems(loved: false)

                        var lovesCount = 0
                        var contentChange: ContentChange?
                        let observer = NotificationObserver(notification: PostChangedNotification) { (post, change) in
                            lovesCount = post.lovesCount!
                            contentChange = change
                        }
                        subject.toggleLove(nil, post: post, via: "")
                        observer.removeObserver()

                        expect(lovesCount) == 6
                        expect(contentChange) == .loved
                    }

                    it("increases currentUser lovesCount") {
                        stubCellItems(loved: false)

                        let prevLovesCount = currentUser.lovesCount!
                        var lovesCount = 0
                        let observer = NotificationObserver(notification: CurrentUserChangedNotification) { (user) in
                            lovesCount = user.lovesCount!
                        }
                        subject.toggleLove(nil, post: post, via: "")
                        observer.removeObserver()

                        expect(lovesCount) == prevLovesCount + 1
                    }
                }
            }

            context("responder chain") {
                it("returns the next responder assigned via responderChainable.next()") {
                    expect(subject.next) == responder
                }
            }
        }
    }
}
