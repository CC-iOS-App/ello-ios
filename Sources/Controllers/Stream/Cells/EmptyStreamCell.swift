////
///  EmptyStreamCell.swift
//

import SnapKit


class EmptyStreamCell: CollectionViewCell {
    static let reuseEmbedIdentifier = "EmptyStreamCell"

    struct Size {
        static let bottomMargin: CGFloat = 15
        static let sideMargin: CGFloat = 15
        static let logoWidth: CGFloat = 60
        static let logoBottomPadding: CGFloat = 20
    }

    var title: String {
        set { label.text = newValue }
        get { return label.text ?? "" }
    }

    fileprivate let label = UILabel()
    fileprivate let logo = ElloLogoView(style: .grey)

    override func style() {
        contentView.backgroundColor = .white
        label.numberOfLines = 0
        label.font = .defaultFont(12)
        label.textColor = .greyA
        label.textAlignment = .center
    }

    override func arrange() {
        contentView.addSubview(logo)
        contentView.addSubview(label)

        logo.snp.makeConstraints { make in
            make.width.height.equalTo(Size.logoWidth)
            make.centerX.equalTo(contentView)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(logo.snp.bottom).offset(Size.logoBottomPadding)
            make.leading.trailing.equalTo(contentView).inset(Size.sideMargin)
            make.bottom.equalTo(contentView).inset(Size.bottomMargin)
        }
    }
}
