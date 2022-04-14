//
//  Book.swift
//  a4_Iurii_ikondrakov
//
//  Created by Iurii Kondrakov on 2022-04-07.
//
import FirebaseFirestoreSwift

struct Book: Codable {
    @DocumentID var id:String?
    
    var title:String  = ""
    var author:String = ""
    var username:String = ""
    var availability:Bool {
        get {
            self.username.isEmpty
        }
    }
}
