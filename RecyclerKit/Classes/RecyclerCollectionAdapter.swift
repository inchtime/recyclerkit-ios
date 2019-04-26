//
//  CollectionViewAdapter.swift
//

import UIKit

public class RecyclerCollectionAdapter: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public typealias OnModelViewClick = (_ indexPath: IndexPath, _ viewModel: ViewModel) -> Void
    
    public typealias OnModelViewBind = (_ indexPath: IndexPath, _ viewModel: ViewModel, _ cell: UICollectionViewCell) -> Void
    
    public typealias OnReuseableViewBind = (_ indexPath: IndexPath, _ section: Section, _ kind: String, _ reuseableView: UICollectionReusableView) -> Void
    
    private var collectionView: UICollectionView
    
    private var identifierDefault = String(describing: UICollectionViewCell.self)
    
    public var spanCount : CGFloat = 1.0
    
    public var direction : UICollectionView.ScrollDirection = .vertical
    
    public class Section: Hashable {
        
        public var name: String = ""
        public var value: Any?
        
        public var identifierForHeader: String?
        public var heightForHeader: CGFloat = 0.0
        public var identifierForFooter: String?
        public var heightForFooter: CGFloat = 0.0
        
        public var models: [ViewModel] = []
        
        public init() {
            
        }
        
//        var hashValue : Int {
//            return name.hashValue
//        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        public static func == (lhs: RecyclerCollectionAdapter.Section, rhs: RecyclerCollectionAdapter.Section) -> Bool {
            return lhs.name == rhs.name
        }
    }
    
    public class ViewModel {
        
        public var identifier: String
        public var value: Any?
        public var spanCount: CGFloat
        public var aspectRatio: CGFloat
        
        public init(identifier: String, value: Any?, spanCount: CGFloat = 1, aspectRatio: CGFloat = 1.0) {
            self.identifier = identifier
            self.value = value
            self.spanCount = spanCount
            self.aspectRatio = aspectRatio
        }
    }
    
    //    private var spanCount: Int = 1
    
    public var sections: [Section] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public var modelViewBind : OnModelViewBind?
    
    public var modelViewClick : OnModelViewClick?
    
    public var reuseableViewBind : OnReuseableViewBind?
    
    public init(collectionView: UICollectionView/*, spanCount: Int*/) {
        self.collectionView = collectionView
        //        self.spanCount = spanCount
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: identifierDefault)
    }
    
    private func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].models.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let viewModel = viewModelOf(indexPath: indexPath)
        
        let identifier = viewModel.identifier
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        modelViewBind?(indexPath, viewModel, cell)
        
        return cell
    }
    
    private func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let section = sections[indexPath.section]
        
        var identifier = ""
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            identifier = section.identifierForHeader ?? ""
        case UICollectionView.elementKindSectionFooter:
            identifier = section.identifierForFooter ?? ""
        default:
            identifier = ""
        }
        
        if identifier.isEmpty {
            return UICollectionReusableView()
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        
        reuseableViewBind?(indexPath, section, kind, view)
        
        return view
    }
    
    private func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        modelViewClick?(indexPath, viewModelOf(indexPath: indexPath))
    }
    
    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sec = sections[section]
        if sec.heightForHeader <= 0 {
            return CGSize.zero
        }
        return CGSize(width: collectionView.frame.width, height: sec.heightForHeader)
    }
    
    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let sec = sections[section]
        if sec.heightForFooter <= 0 {
            return CGSize.zero
        }
        return CGSize(width: collectionView.frame.width, height: sec.heightForFooter)
    }
    
    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = viewModelOf(indexPath: indexPath)
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        var itemSize = CGSize.zero
        switch direction {
        case .horizontal:
            let itemHeight = height / spanCount * viewModel.spanCount
            itemSize = CGSize(width: itemHeight * viewModel.aspectRatio, height: itemHeight)
        case .vertical:
            let itemWidth = width / spanCount * viewModel.spanCount
            itemSize = CGSize(width: itemWidth, height: itemWidth / viewModel.aspectRatio)
        }
        return itemSize
    }
    
    /**
     * append a section
     */
    public func append(section: Section) {
        sections.append(section)
        collectionView.reloadSections([sections.count - 1])
    }
    
    public func insert(section: Section, at i: Int) {
        sections.insert(section, at: i)
        collectionView.reloadSections([i])
    }
    
    /**
     * append models into a section
     */
    public func append(sectionIndex: Int, models: [ViewModel]) {
        let section = sections[sectionIndex]
        section.models.append(contentsOf: models)
        collectionView.reloadSections([sectionIndex])
    }
    
    /**
     * update models on section
     */
    public func update(sectionIndex: Int, models: [ViewModel]) {
        let section = sections[sectionIndex]
        section.models = models
        collectionView.reloadSections([sectionIndex])
    }
    
    private func viewModelOf(indexPath: IndexPath) -> ViewModel {
        return sections[indexPath.section].models[indexPath.item]
    }
    
    public class Builder {
        
        private var adapter: RecyclerCollectionAdapter
        
        private var collectionView: UICollectionView
        
        private var direction : UICollectionView.ScrollDirection = .vertical
        
        public init(_ collectionView: UICollectionView) {
            self.collectionView = collectionView
            self.adapter = RecyclerCollectionAdapter(collectionView: collectionView/*, spanCount: spanCount*/)
        }
        
        public func withLayout(_ layout: UICollectionViewLayout) -> Builder {
            collectionView.setCollectionViewLayout(layout, animated: false)
            return self
        }
        
        public func withFlowLayout(spanCount: CGFloat = 1.0, direction : UICollectionView.ScrollDirection = .vertical) -> Builder {
            
            self.adapter.spanCount = spanCount
            self.adapter.direction = direction
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = direction
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            collectionView.setCollectionViewLayout(layout, animated: false)
            
            return self
        }
        
        public func modelViewBind(_ modelViewBind: @escaping OnModelViewBind) -> Builder {
            self.adapter.modelViewBind = modelViewBind
            return self
        }
        
        public func modelViewClick(_ modelViewClick: @escaping OnModelViewClick) -> Builder {
            self.adapter.modelViewClick = modelViewClick
            return self
        }
        
        public func reuseableViewBind(_ reuseableViewBind: @escaping OnReuseableViewBind) -> Builder {
            self.adapter.reuseableViewBind = reuseableViewBind
            return self
        }
        
        public func build() -> RecyclerCollectionAdapter {
            return adapter
        }
        
    }
}
