//
//  RTSearchBar.swift
//  RTSearchBar
//
//  Created by Ravi Tripathi on 23/11/19.
//  Copyright © 2019 Ravi Tripathi. All rights reserved.
//

import UIKit

public protocol RTSearchBarDelegate: UISearchBarDelegate {
    func didChange(text: String)
    func didEndEditing(text: String)
    func didSelect(withData data: Any)
    func didClear()
}

extension RTSearchBarDelegate {
    func didClear() {}
    func didEndEditing() {}
}

public protocol RTSearchBarDataSource {
    func getData() -> [Any]?
    func textToBeShown(forData data: Any) -> String?
}

@IBDesignable
open class RTSearchBar: UISearchBar {
    var tableView = UITableView(frame: CGRect.zero)
    
    private var RSBDelegate: RTSearchBarDelegate?
    override public var delegate: UISearchBarDelegate? {
        get {
            return self.RSBDelegate
        }
        set {
            self.RSBDelegate = newValue as! RTSearchBarDelegate?
        }
    }
    
    public var dataSource: RTSearchBarDataSource?
    var data: [Any]?
    var actualArray: [Any]?
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        tableView.removeFromSuperview()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.searchTextField.addTarget(self, action: #selector(RTSearchBar.textFieldDidChange), for: .editingChanged)
        
        self.searchTextField.addTarget(self, action: #selector(RTSearchBar.textFielDidEndEditing), for: .editingDidEnd)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.data = self.dataSource?.getData()
        createTableView()
    }
    
    @objc func textFielDidEndEditing() {
        if let text = self.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
            tableView.isHidden = true
            RSBDelegate?.didEndEditing(text: text)
        }
    }
    
    @objc open func textFieldDidChange(){
        if let text = self.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
//            Removed did Paste functionality as it can be handled on the implementer's side
//            if text ==  UIPasteboard.general.string {
//                RSBDelegate?.didPaste(text: text)
//                tableView.isHidden = true
//            } else {
                RSBDelegate?.didChange(text: text)
                tableView.isHidden = false
//            }
        } else {
            RSBDelegate?.didClear()
            tableView.isHidden = true
        }
    }
    
    func createTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AutoCompleteCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.window?.addSubview(tableView)
        reload()
    }
    
    public func reload() {
        self.data = dataSource?.getData()
        self.updateSearchTableView()
    }
    
}

extension RTSearchBar: UITableViewDelegate, UITableViewDataSource {
    
    func updateSearchTableView() {
        superview?.bringSubviewToFront(tableView)
        var tableHeight: CGFloat = 0
        tableHeight = tableView.contentSize.height
        
        // Set a bottom margin of 10p
        if tableHeight < tableView.contentSize.height {
            tableHeight -= 10
        }
        
        // Set tableView frame
        var tableViewFrame = CGRect(x: 0, y: 0, width: frame.size.width - 4, height: tableHeight)
        tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)
        tableViewFrame.origin.x += 2
        tableViewFrame.origin.y += frame.size.height + 2
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            self?.tableView.frame = tableViewFrame
        })
        
        //Setting tableView style
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 5.0
        tableView.separatorColor = UIColor.lightGray
        
        if self.isFirstResponder {
            superview?.bringSubviewToFront(self)
        }
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.reloadData()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteCell", for: indexPath) as UITableViewCell
        guard let count = self.data?.count, indexPath.row < count else {
            return cell
        }
        guard let data = self.data?[indexPath.row] else {
            return cell
        }
        if let value = self.dataSource?.textToBeShown(forData: data) {
            let highlightRange = (value as NSString).range(of: self.text!, options: .caseInsensitive)
            let stringToDisplay = NSMutableAttributedString(string: value)
            stringToDisplay.setAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], range: highlightRange)
            cell.textLabel?.attributedText = stringToDisplay
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let count = self.data?.count, indexPath.row < count else {
            return
        }
        if let data = self.data?[indexPath.row] {
            tableView.isHidden = true
            self.text = self.dataSource?.textToBeShown(forData: data)
            self.RSBDelegate?.didSelect(withData: data)
        }
    }
}
