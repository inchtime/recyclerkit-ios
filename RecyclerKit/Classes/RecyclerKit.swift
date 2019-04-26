//
//  RecyclerKit.swift
//

import UIKit
///
///
class RecyclerKit {
    
    public class func collectionView(_ collectionView: UICollectionView) -> RecyclerCollectionAdapter.Builder {
        return RecyclerCollectionAdapter.Builder(collectionView)
    }
    
    public class func tableView(_ tableView: UITableView) -> RecyclerTableAdapter.Builder {
        return RecyclerTableAdapter.Builder(tableView)
    }
    
}
