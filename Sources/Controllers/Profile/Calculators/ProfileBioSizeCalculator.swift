////
///  ProfileBioSizeCalculator.swift
//

import FutureKit


public class ProfileBioSizeCalculator: NSObject {
    let webView = UIWebView()
    let promise = Promise<CGFloat>()

    deinit {
        webView.delegate = nil
    }

    public func calculate(item: StreamCellItem, maxWidth: CGFloat) -> Future<CGFloat> {
        guard let
            user = item.jsonable as? User,
            formattedShortBio = user.formattedShortBio
        else {
            promise.completeWithSuccess(0)
            return promise.future
        }

        webView.frame.size.width = maxWidth
        webView.delegate = self
        webView.loadHTMLString(StreamTextCellHTML.postHTML(formattedShortBio), baseURL: NSURL(string: "/"))
        return promise.future
    }

}

extension ProfileBioSizeCalculator: UIWebViewDelegate {

    public func webViewDidFinishLoad(webView: UIWebView) {
        let webViewHeight = webView.windowContentSize()?.height ?? 0
        promise.completeWithSuccess(webViewHeight + ProfileBioView.Size.margins.top + ProfileBioView.Size.margins.bottom)
    }

    public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        promise.completeWithSuccess(0)
    }

}

private extension ProfileBioSizeCalculator {}
