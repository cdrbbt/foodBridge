//
//  LogInViewController.swift
//  Food Bridge
//
//  Created by iosdev on 24.4.2018.
//  Copyright © 2018 FoodBridge. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    let userDefaults = UserDefaults.standard
    struct Formdata: Codable{
        let email: String
        let password: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func login(_ sender: UIButton) {
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        let formdata = Formdata(email: self.email.text!, password: self.password.text!)
        
        queue.async {
            guard let uploadData = try? JSONEncoder().encode(formdata) else {
                return
            }
            
            let api = (self.userDefaults.url(forKey: "apiAdress")!).appendingPathComponent("/api/auth/login")
            print(api)
            var request = URLRequest(url: api)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
                if let error = error {
                    print ("error: \(error)")
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                        let dataString = String(data: data!, encoding: .utf8)
                        print (dataString)
                        return
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print(dataString)
                    let jsonresponse = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let dictionary = jsonresponse as? [String:Any]{
                        if let nestedArray = dictionary["tokens"] as? [Any] {
                            if let firstObject = nestedArray.first {
                                if let finalDictionary = firstObject as? [String:Any]{
                                    if let token = finalDictionary["token"] as? String {
                                        self.userDefaults.set(token, forKey: "token")
                                        print(self.userDefaults.string(forKey: "token"))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            task.resume()
        }
        
    }
}
