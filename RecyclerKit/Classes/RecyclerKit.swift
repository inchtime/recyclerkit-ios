//
//  RecyclerKit.swift
//

import UIKit
///
///
open class RecyclerKit {
    
    class func collectionView(_ collectionView: UICollectionView) -> RecyclerCollectionAdapter.Builder {
        return RecyclerCollectionAdapter.Builder(collectionView)
    }
    
    open class func tableView(_ tableView: UITableView) -> RecyclerTable.Builder {
        return RecyclerTable.Builder(tableView)
    }
    
}
