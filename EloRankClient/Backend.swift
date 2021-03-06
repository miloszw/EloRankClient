//
//  Backend.swift
//  EloRankClient
//
//  Created by Milosz Wielondek on 26/03/15.
//  Copyright (c) 2015 Milosz Wielondek. All rights reserved.
//

import Foundation
import Alamofire

private let defaultServerURL = "http://localhost:8080"
private var userServerURL = ""

var serverURL: String {
    get {
        if userServerURL != "" {
            return userServerURL
        } else {
            return defaultServerURL
        }
    }
    set {
        userServerURL = newValue
    }
}

class Backend {
    
    class func getPolls(completionHandler: (polls: [Poll]?) -> ()) {

        Alamofire.request(.GET, serverURL+"/polls")
            .responseJSON { (_,_,data,_) in
                if let parsed = data as? [NSDictionary] {
                    var polls = parsed.map { (var poll) -> Poll in
                        return Poll(id: poll["id"] as Int,
                                    name: poll["name"] as String,
                                    alternativesCount: poll["alternativesCount"] as Int)
                    }
                    completionHandler(polls: polls)
                } else {
                    completionHandler(polls: nil)
                }
        }
    }
    
    class func getAlternatives(forPollId pollId: Int, completionHandler: (alternatives: [Alternative]?) -> ()) {

        Alamofire.request(.GET, serverURL+"/polls/\(pollId)")
            .responseJSON { (_,_,data,_) in
                if let parsed = data as? [NSDictionary] {
                    var alternatives = (parsed[0]["alternatives"] as? [NSDictionary])!.map { (var alt) -> Alternative in
                        // TODO: implement name serverside/db
                        return Alternative(id: alt["id"] as Int, name: alt["name"] as String, url: serverURL + "/" + (alt["url"] as String),
                            score: alt["score"] as Int, rankedTimes: alt["ranked_times"] as Int)
                    }
                    completionHandler(alternatives: alternatives)
                }
        }
    }
    
    class func getChallenge(forPollId pollId: Int, completionHandler: (alternativesId: NSDictionary?) -> ()) {
        Alamofire.request(.GET, serverURL+"/polls/\(pollId)/challenge").responseJSON { (_,_,data,_) in
            if let parsed = data as? NSDictionary {
                completionHandler(alternativesId: parsed)
            }
        }
    }
    
    class func postChallengeResponse(challengeId: Int, results: Int) {
        let challenge = [
            "id": challengeId,
            "result": results
        ]
        Alamofire.request(.POST, serverURL+"/polls/challenge/\(challengeId)", parameters: challenge, encoding: .JSON)
            .responseString { (_,_,response,_) in
                println("server response: \(response)")
        }
    }
}