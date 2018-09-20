//
//  DataExtension.swift
//  Pods
//
//  Created by Eray on 19.09.2018.
//

extension Data {
    var toJson: Any? {
        do {
            let json = try JSONSerialization.jsonObject(
                with: self,
                options: .mutableContainers
            )
            
            return json
        } catch {
            print(">>> Error Occured while converting data into JSON")
        }
        
        return nil
    }
}
