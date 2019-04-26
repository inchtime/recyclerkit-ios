//
//  CollectionViewAdapter.swift
//

import UIKit

class RecyclerCollectionAdapter: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    typealias OnModelViewClick = (_ indexPath: IndexPath, _ viewModel: ViewModel) -> Void
    
    typealias OnModelViewBind = (_ indexPath: IndexPath, _ viewModel: ViewModel, _ cell: UICollectionViewCell) -> Void
    
    typealias OnReuseableViewBind = (_ indexPath: IndexPath, _ section: Section, _ kind: String, _ reuseableView: UICollectionReusableView) -> Void
    
    private var collectionView: UICollectionView
    
    private var identifierDefault = String(describing: UICollectionViewCell.self)
    
    var spanCount : CGFloat = 1.0
    
    var direction : UICollectionView.ScrollDirection = .vertical
    
    class Section: Hashable {
        
        var name: String = ""
        var value: Any?
        
        var identifierForHeader: String?
        var heightForHeader: CGFloat = 0.0
        var identifierForFooter: String?
        var heightForFooter: CGFloat = 0.0
        
        var models: [ViewModel] = []
        
        var hashValue : Int {
            return name.hashValue
        }
        
        static func == (lhs: RecyclerCollectionAdapter.Section, rhs: RecyclerCollectionAdapter.Section) -> Bool {
            return lhs.name == rhs.name
        }
    }
    
    class ViewModel {
        var identifier: String
        var value: Any?
        var spanCount: CGFloat
        var aspectRatio: CGFloat
        
        init(identifier: String, value: Any?, spanCount: CGFloat = 1, aspectRatio: CGFloat = 1.0) {
            self.identifier = identifier
            self.value = value
            self.spanCount = spanCount
            self.aspectRatio = aspectRatio
        }
    }
    
    //    private var spanCount: Int = 1
    
    var sections: [Section] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var modelViewBind : OnModelViewBind?
    
    var modelViewClick : OnModelViewClick?
    
    var reuseableViewBind : OnReuseableViewBind?
    
    init(collectionView: UICollectionView/*, spanCount: Int*/) {
        self.collectionView = collectionView
        //        self.spanCount = spanCount
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: identifierDefault)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let viewModel = viewModelOf(indexPath: indexPath)
        
        let identifier = viewModel.identifier
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        modelViewBind?(indexPath, viewModel, cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        modelViewClick?(indexPath, viewModelOf(indexPath: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sec = sections[section]
        if sec.heightForHeader <= 0 {
            return CGSize.zero
        }
        return CGSize(width: collectionView.frame.width, height: sec.heightForHeader)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let sec = sections[section]
        if sec.heightForFooter <= 0 {
            return CGSize.zero
        }
        return CGSize(width: collectionView.frame.width, height: sec.heightForFooter)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
    func append(section: Section) {
        sections.append(section)
        collectionView.reloadSections([sections.count - 1])
    }
    
    func insert(section: Section, at i: Int) {
        sections.insert(section, at: i)
        collectionView.reloadSections([i])
    }
    
    /**
     * append models into a section
     */
    func append(sectionIndex: Int, models: [ViewModel]) {
        let section = sections[sectionIndex]
        section.models.append(contentsOf: models)
        collectionView.reloadSections([sectionIndex])
    }
    
    /**
     * update models on section
     */
    func update(sectionIndex: Int, models: [ViewModel]) {
        let section = sections[sectionIndex]
        section.models = models
        collectionView.reloadSections([sectionIndex])
    }
    
    private func viewModelOf(indexPath: IndexPath) -> ViewModel {
        return sections[indexPath.section].models[indexPath.item]
    }
    
    class Builder {
        
        private var adapter: RecyclerCollectionAdapter
        
        private var collectionView: UICollectionView
        
        private var direction : UICollectionView.ScrollDirection = .vertical
        
        init(_ collectionView: UICollectionView) {
            self.collectionView = collectionView
            self.adapter = RecyclerCollectionAdapter(collectionView: collectionView/*, spanCount: spanCount*/)
        }
        
        func withLayout(_ layout: UICollectionViewLayout) -> Builder {
            collectionView.setCollectionViewLayout(layout, animated: false)
            return self
        }
        
        func withFlowLayout(spanCount: CGFloat = 1.0, direction : UICollectionView.ScrollDirection = .vertical) -> Builder {
            
            self.adapter.spanCount = spanCount
            self.adapter.direction = direction
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = direction
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            collectionView.setCollectionViewLayout(layout, animated: false)
            
            return self
        }
        
        func modelViewBind(_ modelViewBind: @escaping OnModelViewBind) -> Builder {
            self.adapter.modelViewBind = modelViewBind
            return self
        }
        
        func modelViewClick(_ modelViewClick: @escaping OnModelViewClick) -> Builder {
            self.adapter.modelViewClick = modelViewClick
            return self
        }
        
        func reuseableViewBind(_ reuseableViewBind: @escaping OnReuseableViewBind) -> Builder {
            self.adapter.reuseableViewBind = reuseableViewBind
            return self
        }
        
        func build() -> RecyclerCollectionAdapter {
            return adapter
        }
        
    }
}
