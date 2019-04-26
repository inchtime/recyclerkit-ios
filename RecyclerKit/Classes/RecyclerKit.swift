//
//  RecyclerKit.swift
//

import UIKit
///
///
public class RecyclerKit {
    
    class func collectionView(_ collectionView: UICollectionView) -> RecyclerCollectionAdapter.Builder {
        return RecyclerCollectionAdapter.Builder(collectionView)
    }
    
    class func tableView(_ tableView: UITableView) -> RecyclerTableAdapter.Builder {
        return RecyclerTableAdapter.Builder(tableView)
    }
    
}
