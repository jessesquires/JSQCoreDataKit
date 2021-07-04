//
//  Created by Jesse Squires
//  https://www.jessesquires.com
//
//
//  Documentation
//  https://jessesquires.github.io/JSQCoreDataKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQCoreDataKit
//
//
//  License
//  Copyright © 2015-present Jesse Squires
//  Released under an MIT license: https://opensource.org/licenses/MIT
// 

import UIKit

class CollectionViewController: UICollectionViewController {

    init() {
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem.add(target: self, selector: #selector(didTapAdd(_:))),
            UIBarButtonItem.trash(target: self, selector: #selector(didTapDelete(_:)))
        ]
    }

    @objc
    private func didTapAdd(_ sender: UIBarButtonItem) {
        self.addAction()
    }

    func addAction() { }

    @objc
    private func didTapDelete(_ sender: UIBarButtonItem) {
        self.deleteAction()
    }

    func deleteAction() { }
}
