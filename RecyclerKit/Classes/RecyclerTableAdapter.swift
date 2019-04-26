//
//  RecyclerTableAdapter.swift
//

import UIKit

public class RecyclerTableAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public typealias OnModelViewClick = (_ indexPath: IndexPath, _ viewModel: ViewModel) -> Void
    
    public typealias OnModelViewBind = (_ indexPath: IndexPath, _ viewModel: ViewModel, _ cell: UITableViewCell) -> Void
    
    public typealias OnHeaderViewBind = (_ section: Section, _ view: UIView?) -> Void
    
    public typealias OnFooterViewBind = (_ section: Section, _ view: UIView?) -> Void
    
    public typealias OnModelViewSwipeActionsConfiguration = (_ indexPath: IndexPath, _ viewModel: ViewModel) -> UISwipeActionsConfiguration?
    
    private var tableView: UITableView
    
    public class Section: Hashable {
        
        var name: String = ""
        
        var value: Any?
        
        var viewForHeader: UIView?
        
        var viewForFooter: UIView?
        
        var models: [ViewModel] = []
        
//        var hashValue : Int {
//            return name.hashValue
//        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        public static func == (lhs: Section, rhs: Section) -> Bool {
            return lhs.name == rhs.name
        }
    }
    
    public class ViewModel {
        
        init(identifier: String, value: Any) {
            self.identifier = identifier
            self.value = value
        }
        
        init(identifier: String, value: Any, editable: Bool) {
            self.identifier = identifier
            self.value = value
            self.editable = editable
        }
        
        var identifier: String
        var value: Any
        var editable: Bool = false
    }
    
    public var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    public var modelViewBind: OnModelViewBind?
    
    public var headerViewBind: OnHeaderViewBind?
    
    public var footerViewBind: OnFooterViewBind?
    
    public var modelViewClick: OnModelViewClick?
    
    public var modelViewSwipeActionsConfiguration: OnModelViewSwipeActionsConfiguration?
    
    init(_ tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].models.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = viewModelOf(indexPath: indexPath)
        let identifier = viewModel.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        modelViewBind?(indexPath, viewModel, cell)
        return cell
    }
    
    private func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sec = sections[section]
        headerViewBind?(sec, sec.viewForHeader)
        return sec.viewForHeader
    }
    
    private func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let header = sections[section].viewForHeader else { return 0 }
        return header.frame.height > 0 ? header.frame.height : UITableView.automaticDimension
    }
    
    private func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sec = sections[section]
        footerViewBind?(sec, sec.viewForFooter)
        return sec.viewForFooter
    }
    
    private func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let footer = sections[section].viewForFooter else { return 0 }
        return footer.frame.height > 0 ? footer.frame.height : UITableView.automaticDimension
    }
    
    private func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        modelViewClick?(indexPath, viewModelOf(indexPath: indexPath))
    }
    
    private func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let viewModel = viewModelOf(indexPath: indexPath)
        return viewModel.editable
    }
    
    private func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let viewModel = viewModelOf(indexPath: indexPath)
        return modelViewSwipeActionsConfiguration?(indexPath, viewModel)
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
    
    public class Builder {
        
        private var adapter: RecyclerTableAdapter
        
        private var tableView: UITableView
        
        init(_ tableView: UITableView) {
            self.tableView = tableView
            self.adapter = RecyclerTableAdapter(tableView)
        }
        
        public func tableView(_ tableView: UITableView) -> Builder {
            self.tableView = tableView
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
        
        public func modelViewSwipeActionsConfiguration(_ configuration: @escaping OnModelViewSwipeActionsConfiguration) -> Builder {
            self.adapter.modelViewSwipeActionsConfiguration = configuration
            return self
        }
        
        public func build() -> RecyclerTableAdapter {
            return adapter
        }
        
    }
}
