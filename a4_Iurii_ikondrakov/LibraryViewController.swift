//
//  LibraryViewController.swift
//  a4_Iurii_ikondrakov
//
//  Created by Iurii Kondrakov on 2022-04-06.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let db = Firestore.firestore()
    var username:String = ""
    var books:[Book] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        books.removeAll()
        loadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let book = self.books[indexPath.row]
        content.text = book.title
        content.secondaryText = book.author + (!book.availability ? " - borrowed by \(book.username)" : "")
        content.image = UIImage(systemName: "book.closed.circle")
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        errorLabel.text = ""
        var book = books[indexPath.row]
        if book.availability {
            do {
                print("INFO: Updating book with ID:\(book.id ?? "undefined")")
                book.username = username
                try db.collection("library").document(book.id!).setData(from: book)
                
                books[indexPath.row] = book
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            } catch {
                book.username = ""
                print("ERROR: Failed to update the book with ID:\(book.id ?? "undefined")")
                print(error)
            }
        } else {
            if book.username == username {
                errorLabel.text = "You have already borrowed this book"
            } else {
                errorLabel.text = "This book is already borrowed by \(book.username)"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            errorLabel.text = ""
            var book = books[indexPath.row]
            if !book.availability {
                if book.username == username {
                    do {
                        book.username = ""
                        print("INFO: Making book avaliable with ID:\(book.id ?? "undefined")")
                        try db.collection("library").document(book.id!).setData(from: book)
                        
                        books[indexPath.row] = book
                        self.tableView.reloadRows(at: [indexPath], with: .middle)
                    } catch {
                        book.username = username
                        print("ERROR: Failed to update the book with ID:\(book.id ?? "undefined")")
                        print(error)
                    }
                } else {
                    errorLabel.text = "This book is borrowed by \(book.username)"
                }
            } else {
                errorLabel.text = "This book is not borrowed by anyone"
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private func loadData() {
        // get books from Firestore
        db.collection("library").getDocuments { books, error in
            if let err = error {
                print("ERROR: Failed to retrieve books")
                print(err)
            } else {
                for document in books!.documents {
                    do {
                        self.books.append(try document.data(as: Book.self))
                    } catch {
                        print("ERROR: Failed to convert a document to book")
                        print(error)
                    }
                }
                print("INFO: Loaded \(self.books.count) books")
                print("INFO: Refreshing TableView")
                self.tableView.reloadData()
            }
        }
    }
}
