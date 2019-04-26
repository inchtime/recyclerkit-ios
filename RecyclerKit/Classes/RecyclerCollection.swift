//
//  CollectionViewAdapter.swift
//

import UIKit

open class RecyclerCollection: NSObject {
    
    public typealias OnModelViewClick = (_ indexPath: IndexPath, _ viewModel: ViewModel) -> Void
    
    public typealias OnModelViewBind = (_ indexPath: IndexPath, _ viewModel: ViewModel, _ cell: UICollectionViewCell) -> Void
    
    public typealias OnReuseableViewBind = (_ indexPath: IndexPath, _ section: Section, _ kind: String, _ reuseableView: UICollectionReusableView) -> Void
    
    open var modelViewBind : OnModelViewBind?
    
    open var modelViewClick : OnModelViewClick?
    
    open var reuseableViewBind : OnReuseableViewBind?

    private var collectionView: UICollectionView
    
    private var adapter: Adapter = Adapter()
    
    private var identifierDefault = String(describing: UICollectionViewCell.self)
    
    public var spanCount : CGFloat = 1.0
    
    public var direction : UICollectionView.ScrollDirection = .vertical

    public var sections: [Section] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    public class Section: Hashable {
        
        public init () { }
        
        public var name: String = ""
        public var value: Any?
        public var identifierForHeader: String?
        public var heightForHeader: CGFloat = 0.0
        public var identifierForFooter: String?
        public var heightForFooter: CGFloat = 0.0
        
        public var models: [ViewModel] = []
        
//        public var hashValue : Int {
//            return name.hashValue
//        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        public static func == (lhs: RecyclerCollection.Section, rhs: RecyclerCollection.Section) -> Bool {
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
    
    
    public init(collectionView: UICollectionView/*, spanCount: Int*/) {
        self.collectionView = collectionView
        //        self.spanCount = spanCount
        super.init()
        self.adapter.holder = self
        self.collectionView.delegate = self.adapter
        self.collectionView.dataSource = self.adapter
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: identifierDefault)
    }
    
    class Adapter: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        var holder: RecyclerCollection!
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return holder.sections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return holder.sections[section].models.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let viewModel = holder.viewModelOf(indexPath: indexPath)
            
            let identifier = viewModel.identifier
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            
            holder.modelViewBind?(indexPath, viewModel, cell)
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            
            let section = holder.sections[indexPath.section]
            
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
            
            holder.reuseableViewBind?(indexPath, section, kind, view)
            
            return view
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            holder.modelViewClick?(indexPath, holder.viewModelOf(indexPath: indexPath))
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            let sec = holder.sections[section]
            if sec.heightForHeader <= 0 {
                return CGSize.zero
            }
            return CGSize(width: collectionView.frame.width, height: sec.heightForHeader)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
            let sec = holder.sections[section]
            if sec.heightForFooter <= 0 {
                return CGSize.zero
            }
            return CGSize(width: collectionView.frame.width, height: sec.heightForFooter)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let viewModel = holder.viewModelOf(indexPath: indexPath)
            let width = collectionView.frame.width
            let height = collectionView.frame.height
            var itemSize = CGSize.zero
            switch holder.direction {
            case .horizontal:
                let itemHeight = height / holder.spanCount * viewModel.spanCount
                itemSize = CGSize(width: itemHeight * viewModel.aspectRatio, height: itemHeight)
            case .vertical:
                let itemWidth = width / holder.spanCount * viewModel.spanCount
                itemSize = CGSize(width: itemWidth, height: itemWidth / viewModel.aspectRatio)
            }
            return itemSize
        }
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
    
    open class Builder {
        
        private var collection: RecyclerCollection
        
        private var collectionView: UICollectionView
        
        private var direction : UICollectionView.ScrollDirection = .vertical
        
        public init(_ collectionView: UICollectionView) {
            self.collectionView = collectionView
            self.collection = RecyclerCollection(collectionView: collectionView/*, spanCount: spanCount*/)
        }
        
        open func withLayout(_ layout: UICollectionViewLayout) -> Builder {
            collectionView.setCollectionViewLayout(layout, animated: false)
            return self
        }
        
        open func withFlowLayout(spanCount: CGFloat = 1.0, direction : UICollectionView.ScrollDirection = .vertical) -> Builder {
            
            self.collection.spanCount = spanCount
            self.collection.direction = direction
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = direction
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            collectionView.setCollectionViewLayout(layout, animated: false)
            
            return self
        }
        
        open func modelViewBind(_ modelViewBind: @escaping OnModelViewBind) -> Builder {
            self.collection.modelViewBind = modelViewBind
            return self
        }
        
        open func modelViewClick(_ modelViewClick: @escaping OnModelViewClick) -> Builder {
            self.collection.modelViewClick = modelViewClick
            return self
        }
        
        open func reuseableViewBind(_ reuseableViewBind: @escaping OnReuseableViewBind) -> Builder {
            self.collection.reuseableViewBind = reuseableViewBind
            return self
        }
        
        open func build() -> RecyclerCollection {
            return collection
        }
        
    }
}
