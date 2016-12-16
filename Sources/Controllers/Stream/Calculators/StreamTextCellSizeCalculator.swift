////
///  StreamTextCellSizeCalculator.swift
//

import Foundation

public class StreamTextCellSizeCalculator: NSObject, UIWebViewDelegate {
    let webView: UIWebView
    private typealias CellJob = (cellItems: [StreamCellItem], width: CGFloat, columnCount: Int, completion: ElloEmptyCompletion)
    private var cellJobs: [CellJob] = []
    private var cellItems: [StreamCellItem] = []
    private var maxWidth: CGFloat
    private var completion: ElloEmptyCompletion = {}

    public init(webView: UIWebView) {
        self.webView = webView
        self.maxWidth = 0
        super.init()
        self.webView.delegate = self
    }

// MARK: Public

    public func processCells(cellItems: [StreamCellItem], withWidth width: CGFloat, columnCount: Int, completion: ElloEmptyCompletion) {
        let job: CellJob = (cellItems: cellItems, width: width, columnCount: columnCount, completion: completion)
        cellJobs.append(job)
        if cellJobs.count == 1 {
            processJob(job)
        }
    }

// MARK: Private

    private func processJob(job: CellJob) {
        self.completion = {
            if self.cellJobs.count > 0 {
                self.cellJobs.removeAtIndex(0)
            }
            job.completion()
            if let nextJob = self.cellJobs.safeValue(0) {
                self.processJob(nextJob)
            }
        }
        self.cellItems = job.cellItems
        if job.columnCount == 1 {
            self.maxWidth = job.width
        }
        else {
            self.maxWidth = floor(job.width / CGFloat(job.columnCount) - StreamKind.Following.columnSpacing * CGFloat(job.columnCount - 1))
        }
        loadNext()
    }

    private func loadNext() {
        if let item = self.cellItems.safeValue(0) {
            if item.jsonable is ElloComment {
                // need to add back in the postMargin (15) since the maxWidth should already
                // account for 15 on the left that is part of the commentMargin (60)
                self.webView.frame = self.webView.frame.withWidth(maxWidth - StreamTextCellPresenter.commentMargin + StreamTextCellPresenter.postMargin)
            }
            else {
                self.webView.frame = self.webView.frame.withWidth(maxWidth)
            }
            let textElement = item.type.data as? TextRegion

            if let textElement = textElement {
                let content = textElement.content
                let strippedContent = content.stripHtmlImgSrc()
                let html = StreamTextCellHTML.postHTML(strippedContent)
                // needs to use the same width as the post text region
                self.webView.loadHTMLString(html, baseURL: NSURL(string: "/"))
            }
            else {
                self.cellItems.removeAtIndex(0)
                loadNext()
            }
        }
        else {
            completion()
        }
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        let textHeight = self.webView.windowContentSize()?.height
        assignCellHeight(textHeight ?? 0)
    }

    private func assignCellHeight(height: CGFloat) {
        if let cellItem = self.cellItems.safeValue(0) {
            self.cellItems.removeAtIndex(0)
            cellItem.calculatedCellHeights.webContent = height
            cellItem.calculatedCellHeights.oneColumn = height
            cellItem.calculatedCellHeights.multiColumn = height
        }
        loadNext()
    }

}