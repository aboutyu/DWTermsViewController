//
//  Created by 유태훈 on 2023/10/06.
//

import QuartzCore
import UIKit
import WebKit

open class DWTermsViewController: UIViewController {
    
    private lazy var headerContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "closed", bundle: Bundle.module, compatibleWith: nil), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = self.isTitleHide
        label.text = "약관"
        return label
    }()
    
    private lazy var webView: WKWebView = {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        let contentController = WKUserContentController()
        contentController.addUserScript(script)
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        if #available(iOS 14.0, *) {
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            webView.configuration.preferences.javaScriptEnabled = true
        }
        
        webView.backgroundColor = .clear
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
        return webView
    }()
    
    private lazy var menuView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: self.menuInsets, bottom: 0, right: self.menuInsets)
        
        let menu = UICollectionView(frame: .zero, collectionViewLayout: layout)
        menu.backgroundColor = .clear
        menu.register(THTermsMenuViewCell.self, forCellWithReuseIdentifier: "cell")
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.showsVerticalScrollIndicator = false
        menu.showsHorizontalScrollIndicator = false
        
        return menu
    }()
    
    private var items: [THTermsEntity] = []
    private var startedItem: Int = 0
    private var selectedItem: Int = 0
    private var isTitleHide: Bool = false
    private var menuFont: UIFont = UIFont.systemFont(ofSize: 17)
    
    private let headerHeight: CGFloat = 40.0
    private var menuInsets: CGFloat = 12.0
    
    private var selectedColor: UIColor?
    private var diselectedColor: UIColor?
    
    public init(_ items: [THTermsEntity], startedItem: Int? = nil, menuInsets: CGFloat? = nil, font: UIFont? = nil, selectedColor: UIColor? = nil, diselectedColor: UIColor? = nil, isTitleHide: Bool = false) {
        self.items = items
        if let started = startedItem {
            self.startedItem = started
            self.selectedItem = started
        }
        if let insets = menuInsets {
            self.menuInsets = insets
        }
        if let font = font {
            self.menuFont = font
        }
        
        self.isTitleHide = isTitleHide
        self.diselectedColor = diselectedColor
        self.selectedColor = selectedColor
        
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.modalTransitionStyle = .coverVertical
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSubViews()
        self.setupLayout()
        self.requestWeb(self.startedItem)
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .white
        
        self.menuView.delegate = self
        self.menuView.dataSource = self
    }
    
    private func setupSubViews() {
        self.view.addSubview(self.headerContainer)
        self.view.addSubview(self.menuView)
        self.view.addSubview(self.webView)
        
        [self.webView, self.menuView, self.headerContainer].forEach { self.view.addSubview($0) }
        [self.button, self.titleLabel].forEach { self.headerContainer.addSubview($0) }
        
        self.headerContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.headerContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.headerContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.headerContainer.bottomAnchor.constraint(equalTo: self.menuView.topAnchor, constant: -5.0).isActive = true
        self.headerContainer.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        self.menuView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.menuView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.menuView.bottomAnchor.constraint(equalTo: self.webView.topAnchor).isActive = true
        self.menuView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.button.leadingAnchor.constraint(equalTo: self.headerContainer.leadingAnchor, constant: 10).isActive = true
        self.button.topAnchor.constraint(equalTo: self.headerContainer.topAnchor).isActive = true
        self.button.bottomAnchor.constraint(equalTo: self.headerContainer.bottomAnchor).isActive = true
        self.button.widthAnchor.constraint(equalToConstant: 35).isActive = true
        
        self.titleLabel.centerXAnchor.constraint(equalTo: self.headerContainer.centerXAnchor).isActive = true
        self.titleLabel.centerYAnchor.constraint(equalTo: self.headerContainer.centerYAnchor).isActive = true
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true)
    }
    
    private func requestWeb(_ num: Int) {
        let item = self.items[num]
        guard let request = item.request else { return }
        
        self.selectedItem = num
        self.titleLabel.text = item.name
        DispatchQueue.main.async {
            self.menuView.scrollToItem(at: IndexPath(row: num, section: 0), at: [.centeredVertically, .centeredHorizontally], animated: true)
            self.menuView.reloadData()
        }
        self.webView.load(request)
    }
}

extension DWTermsViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let name: String = self.items[indexPath.item].name
        let width: CGFloat = name.size(withAttributes: [NSAttributedString.Key.font : self.menuFont]).width
        return CGSize(width: width + 16,
                      height: collectionView.frame.size.height)
    }
}

extension DWTermsViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! THTermsMenuViewCell
        let row = indexPath.row
        
        cell.index = row
        cell.selectedColor = self.selectedColor
        cell.diSelectedColor = self.diselectedColor
        cell.name = self.items[row].name
        cell.font = self.menuFont
        cell.bottomLineHeight = 1.2
        cell.reload(self.selectedItem)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.requestWeb(indexPath.row)
    }
}

extension DWTermsViewController: WKUIDelegate {
    
}

extension DWTermsViewController: WKNavigationDelegate {
    
}

