//
//  ViewController.swift
//  KNNDTW_TEST

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let URL_QUERY_DATA = "http://findermacao.com/indoor-positioning/query.php"
        
        //created URL
        let requestURL = URL(string: URL_QUERY_DATA)!
        var request = URLRequest(url: requestURL)
        
        //creating http parameters
        let dateString = "2017-02-08"
        let postParameters = "date>=\(dateString)"
        let magneticDB = MagneticDB()
        
        //setting the HTTP header and adding the parameters to request body
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.httpBody = postParameters.data(using: String.Encoding.utf8)

        //creating a task to send the post request
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async {
            let session = URLSession.shared
            session.dataTask(with: request) {
                data, response, error in
                guard let data = data, let _ = response, error == nil else {
                    print("error: \(error)")
                    return
                }
                //print response value
                //print(String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) as Any)

                //parsing the response
                do {
                    //converting resonse to NSDictionary
                    let myJSON =  try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : AnyObject]
                    //parsing the json
                    if let myJSON = myJSON {
                        for parseJSON in myJSON  {
                            print("\(parseJSON.key) : \(parseJSON.value)")
                        }
                    } else {
                        print(String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) as Any)
                    }
                } catch {
                    print(error)
                }
                
                }.resume()
        }
        
        var training_samples: [knn_curve_label_pair] = [knn_curve_label_pair]()
        
        
        //some are dogs
        training_samples.append(knn_curve_label_pair(curve: [36.73102, 36.49010, 36.71643, 36.81107, 36.53139, 35.33500, 33.25994, 34.19430, 31.68965, 29.73540, 29.87481, 31.73938, 33.97005, 38.56090, 37.04065], label: "PATH_A"))
        training_samples.append(knn_curve_label_pair(curve: [36.34732, 36.45524, 36.81628, 36.87823, 36.47066, 33.66738, 34.95708, 33.27764, 31.59749, 29.86957, 30.27806, 32.66608, 36.04008, 39.13545, 38.30994], label: "PATH_A"))
        training_samples.append(knn_curve_label_pair(curve: [36.44950, 36.65504, 36.85799, 36.56808, 37.07297, 34.56391, 35.92780, 31.84803, 33.42877, 29.98551, 29.69981, 31.63249, 37.28666, 34.62840, 39.26430], label: "PATH_A"))
        
        //some are cats
        training_samples.append(knn_curve_label_pair(curve: [44.04905, 49.98119, 45.00522, 50.59539, 48.82585, 44.67606, 39.34258, 38.88962, 37.94608, 41.78757, 39.96053, 40.63711, 41.72489, 41.43045, 40.68937], label: "PATH_B"))
        training_samples.append(knn_curve_label_pair(curve: [43.62787, 44.88939, 50.25981, 51.35418, 44.65431, 48.40897, 38.88859, 37.56867, 38.56271, 39.79246, 41.35164, 41.82357, 41.85272, 41.31502, 41.01366], label: "PATH_B"))
        training_samples.append(knn_curve_label_pair(curve: [46.06822, 50.52546, 46.92852, 51.63141, 50.65045, 47.52874, 42.58990, 37.88731, 38.60579, 37.38780, 39.89268, 41.80131, 41.69234, 41.43710, 40.67597], label: "PATH_B"))
        
        
        let knn: KNNDTW = KNNDTW()
        
        knn.configure(3, max_warp: 0) //max_warp isn't implemented yet
        
        knn.train(training_samples)
        
        let prediction: knn_certainty_label_pair = knn.predict([36.54630, 36.87031, 36.62409, 37.19362, 36.86874, 34.75492])
        
        print("predicted " + prediction.label, "with ", prediction.probability*100,"% certainty")
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

