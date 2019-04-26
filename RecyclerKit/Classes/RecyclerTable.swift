//
//  RecyclerTableAdapter.swift
//

import UIKit

open class RecyclerTable: NSObject {
    
    public typealias OnModelViewClick = (_ indexPath: IndexPath, _ viewModel: ViewModel) -> Void
    
    public typealias OnModelViewBind = (_ indexPath: IndexPath, _ viewModel: ViewModel, _ cell: UITableViewCell) -> Void
    
    public typealias OnHeaderViewBind = (_ section: Section, _ view: UIView?) -> Void
    
    public typealias OnFooterViewBind = (_ section: Section, _ view: UIView?) -> Void
    
    public typealias OnModelViewSwipeActionsConfiguration = (_ indexPath: IndexPath, _ viewModel: ViewModel) -> UISwipeActionsConfiguration?
    
    open var modelViewBind: OnModelViewBind?
    
    open var headerViewBind: OnHeaderViewBind?
    
    open var footerViewBind: OnFooterViewBind?
    
    open var modelViewClick: OnModelViewClick?
    
    open var modelViewSwipeActionsConfiguration: OnModelViewSwipeActionsConfiguration?

    private var tableView: UITableView
    
    private var adapter: Adapter = Adapter()
    
    open var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    public init(_ tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.adapter.holder = self
        self.tableView.delegate = adapter
        self.tableView.dataSource = adapter
    }
    
    public class Section: Hashable {
        
        public init () { }
        
        public var name: String = ""
        public var value: Any?
        public var viewForHeader: UIView?
        public var viewForFooter: UIView?
        public var models: [ViewModel] = []
        
        public var hashValue : Int {
            return name.hashValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        public static func == (lhs: Section, rhs: Section) -> Bool {
            return lhs.name == rhs.name
        }
    }
    
    public class ViewModel {
        
        public init(identifier: String, value: Any) {
            self.identifier = identifier
            self.value = value
        }
        
        public init(identifier: String, value: Any, editable: Bool) {
            self.identifier = identifier
            self.value = value
            self.editable = editable
        }
        
        public var identifier: String
        public var value: Any
        public var editable: Bool = false
    }
    
    class Adapter: NSObject, UITableViewDelegate, UITableViewDataSource {
        
        var holder: RecyclerTable!
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return holder.sections.count
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return holder.sections[section].models.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let viewModel = holder.viewModelOf(indexPath: indexPath)
            let identifier = viewModel.identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            holder.modelViewBind?(indexPath, viewModel, cell)
            return cell
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let sec = holder.sections[section]
            holder.headerViewBind?(sec, sec.viewForHeader)
            return sec.viewForHeader
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            guard let header = holder.sections[section].viewForHeader else { return 0 }
            return header.frame.height > 0 ? header.frame.height : UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            let sec = holder.sections[section]
            holder.footerViewBind?(sec, sec.viewForFooter)
            return sec.viewForFooter
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            guard let footer = holder.sections[section].viewForFooter else { return 0 }
            return footer.frame.height > 0 ? footer.frame.height : UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            holder.modelViewClick?(indexPath, holder.viewModelOf(indexPath: indexPath))
        }
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            let viewModel = holder.viewModelOf(indexPath: indexPath)
            return viewModel.editable
        }
        
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let viewModel = holder.viewModelOf(indexPath: indexPath)
            return holder.modelViewSwipeActionsConfiguration?(indexPath, viewModel)
        }
    }
    
    /**
     * append a section
     */
    public func append(section: Section) -> Int {
        sections.append(section)
        tableView.reloadSections([sections.count - 1], with: .fade)
        return sections.count
    }
    
    /**
     * append models into a section
     */
    public func append(sectionIndex: Int, models: [ViewModel]) {
        tableView.beginUpdates()
        let section = sections[sectionIndex]
        let count = section.models.count
        var indexPaths: [IndexPath] = []
        for (index, _) in models.enumerated() {
            indexPaths.append(IndexPath(row: index + count, section: sectionIndex))
        }
        section.models.append(contentsOf: models)
        tableView.insertRows(at: indexPaths, with: .fade)
        tableView.endUpdates()
    }
    
    public func update(sectionIndex: Int, models: [ViewModel]) {
        let section = sections[sectionIndex]
        section.models = models
        tableView.reloadSections([sectionIndex], with: .fade)
    }
    
    private func viewModelOf(indexPath: IndexPath) -> ViewModel {
        return sections[indexPath.section].models[indexPath.item]
    }
    
    open class Builder {
        
        private var table: RecyclerTable
        
        private var tableView: UITableView
        
        public init(_ tableView: UITableView) {
            self.tableView = tableView
            self.table = RecyclerTable(tableView)
        }
        
        open func tableView(_ tableView: UITableView) -> Builder {
            self.tableView = tableView
            return self
        }
        
        open func modelViewBind(_ modelViewBind: @escaping OnModelViewBind) -> Builder {
            self.table.modelViewBind = modelViewBind
            return self
        }
        
        open func modelViewClick(_ modelViewClick: @escaping OnModelViewClick) -> Builder {
            self.table.modelViewClick = modelViewClick
            return self
        }
        
        open func modelViewSwipeActionsConfiguration(_ configuration: @escaping OnModelViewSwipeActionsConfiguration) -> Builder {
            self.table.modelViewSwipeActionsConfiguration = configuration
            return self
        }
        
        open func build() -> RecyclerTable {
            return table
        }
        
    }
}
